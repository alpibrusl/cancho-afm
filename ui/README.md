# ui: the console page (cancho-ui)

`afm.cui` is a [cancho-ui](https://github.com/alpibrusl/cancho-ui) component. It reads `twin.json` from its own origin (`requires Network;`, nothing else) and shows the run of the
**software twin**: the resonance found, the loop gains chosen, the approach, the image of the grating, and the amplitude figure, Z and X during a second scan. A prediction of this
software, not a measurement.

```sh
# 1. the twin runs the whole automatic procedure and writes the document (cancho)
cancho run host/twin_export.cho host/session.cho host/script.cho host/run_twin.cho host/proto.cho host/twin_link.cho sim/board.cho sim/lockin.cho \
    sim/pid.cho sim/raster.cho sim/raster_sine.cho sim/plant.cho sim/tune.cho sim/approach.cho host/regs.cho --std > ui/twin.json
# 2. the page: check, build, serve (cancho-ui is a separate repository; build it once with cargo build --release)
cancho-ui check ui/afm.cui && cancho-ui build ui/afm.cui -o ui/afm.js
cd ui && python3 -m http.server 8765        # open http://localhost:8765/index.html
```

`index.html` is the host page; `afm.js` is generated. What cancho-ui gives here: `Chart` (line and bar, with a text alternative and a data table), `net.get` and `json.get` / `json.items`.
What it lacks for this: **no image or heat-map element** (the topography is shown as a line chart of its pixels, line after line), **no way to index a list** (so the page cannot replay a trace
frame by frame), and `Network` reads the page's own origin only (so a live page needs the Pi to serve `twin.json`-shaped documents, e.g. with `every 1000 Load;` polling, or `subscribe` for a stream).

## The live console (`live.cui`, `live.html`)

`live.cui` polls `live.json` every 500 ms and draws the history (the last 600 readings) of the amplitude figure, Z and X. The document is one line of JSON written by one of two producers, and says which in
its `source` field (`twin` is a prediction of this software; `board` is a read-only reading of the real instrument):

```sh
# the twin, paced (here, no hardware): 900 lines, one every 0.25 s
cancho run host/live_twin.cho host/live_json.cho host/session.cho host/script.cho host/run_twin.cho host/proto.cho host/twin_link.cho sim/board.cho sim/lockin.cho \
    sim/pid.cho sim/raster.cho sim/raster_sine.cho sim/plant.cho sim/tune.cho sim/approach.cho host/regs.cho --std \
  | while IFS= read -r l; do printf '%s\n' "$l" > ui/live.json.tmp && mv ui/live.json.tmp ui/live.json; sleep 0.25; done

# the real board, on the Pi (edition-8 compiler; the board must run afm_top; this READS only and never writes a register)
cancho build host/live_tty.cho host/live_json.cho host/proto.cho host/regs.cho --std -o live_tty
cd ui && while :; do ../live_tty | while IFS= read -r l; do printf '%s\n' "$l" > live.json.tmp && mv live.json.tmp live.json; sleep 0.25; done; done
```

and serve `ui/` with any static server (`python3 -m http.server 8765`), or with the cancho server below. `live_tty` prints 8 lines and exits because the output is flushed at exit, so
the shell loop restarts it; its counter `t` restarts at 0 each time, so the page may miss a point when two readings in a row carry the same `t`.

**Measured:** the twin path was run end to end and the page drew it (`Source: twin`, charts growing). The board path was run on the real Pi against the board loaded with this repository's bitstream: it
identified `afm_top`, wrote nothing, and printed `"source":"board"` lines through the loop into `live.json` (all zeros, the board being idle with nothing wired). **Not measured:** the page reading
`live.json` served from the Pi, and any live reading with a fork and a scan running.

### The server in cancho (`host/serve.cho`)

One program on the Pi replaces the loop and the static server: it checks the board's identifier, then every turn (at most 250 ms) READS the seven live registers and answers `GET /live.json` (the latest reading,
`source: "board"`, `Cache-Control: no-store`), and `GET /`, `/live.html`, `/live.js` (read from `/home/alfonso/afm-build/ui`, a literal in the source because `narrow` takes one; a file over 48 KiB is cut).
Anything else is 404, anything but GET is 405. It uses the `http.server` package of the compiler repository (`packages/http-server/server.cho`, passed on the command line as a module), with a second poller for the serial
port so the server's own is not disturbed; it is not cancho-web (which adds routes, schemas and OpenAPI, none of which one JSON document needs).

```sh
cancho build host/serve.cho host/live_json.cho host/proto.cho host/regs.cho <cancho>/packages/http-server/server.cho --std -o serve     # on the Pi (edition 8)
./serve 8765        # then open http://<pi>:8765/ ; there is no authentication: do not expose it beyond a trusted network
```

**Measured, on the Pi against the real board:** `/live.json` 200 with `"source":"board"`; `/` 200 `text/html`, `/live.js` 200 `text/javascript` (30,454 bytes); an unknown path 404; a POST 405; the page
opened through an SSH tunnel read it and showed `Source: board`, reading 71 and rising. The readings were all zeros (the board idle, nothing wired). `cancho authority` lists `net_in("")` (unbounded: the port is an
argument, as in the compiler's own `examples/api`), `tty_open("/dev")`, `fs_read("/home/alfonso/afm-build/ui")`, `conn_*`, `poll`, `clock`; no foreign code, no writes. **Not measured:** load, long runs, a reading during a scan.

### Before the console can write: put cancho-gateway in front

`serve.cho` reads only and has no authentication. When the console gains write access (starting a scan, moving the motor, changing limits) or is reachable beyond a trusted network, run
[cancho-gateway](https://github.com/alpibrusl/cancho-gateway) in front of it on the Pi (TLS 1.3, an API key, rate limits, an access log), with the write routes admitted only on the authenticated path. Keep the identifier
check and the register limits in `serve.cho`, so a gateway mistake cannot bypass them. Decided 2026-11-02; not built, and the gateway has not been run for this (its own README calls it a working slice, its TLS server not independently reviewed).

## The last scan (`scan.cui`, `scan.html`)

`scan.cui` polls `scan.json` every 5 s and prints the analysis of the last scan: roughness, the step, the grating, the particles and the drift, with the document's `source` (`twin`: a prediction). The levelled image is `scan.png`, an `<img>` of the host page `scan.html`, which also sets its text alternative from `scan.json`: `cancho-ui` has no image element yet (docs/image-processing.md, I5). Both files are written by the twin's analysis:

```sh
cancho build host/scan_twin.cho sim/*.cho host/regs.cho gen/ir.cho gen/pid_ir.cho gen/raster_ir.cho gen/lockin_ir.cho host/proto.cho host/twin_link.cho host/script.cho host/run_twin.cho \
    host/session.cho host/image.cho host/metrics.cho host/features.cho host/drift.cho host/report.cho host/png.cho --std -o scan_twin
./scan_twin 1 0 500 5 > ui/scan.json        # profile 1 (the high-speed cantilever), ideal Z scanner, 500 kHz, mode 5: the document
./scan_twin 1 0 500 6 > ui/scan.png         # mode 6: the levelled image
cancho-ui check ui/scan.cui && cancho-ui build ui/scan.cui -o ui/scan.js
cd ui && python3 -m http.server 8765        # open http://localhost:8765/scan.html
```
