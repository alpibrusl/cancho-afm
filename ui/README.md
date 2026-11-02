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

and serve `ui/` with any static server (`python3 -m http.server 8765`, which is not cancho: a cancho-web server is the next step). `live_tty` prints 8 lines and exits because the output is flushed at exit, so
the shell loop restarts it; its counter `t` restarts at 0 each time, so the page may miss a point when two readings in a row carry the same `t`.

**Measured:** the twin path was run end to end and the page drew it (`Source: twin`, charts growing). The board path was run on the real Pi against the board loaded with this repository's bitstream: it
identified `afm_top`, wrote nothing, and printed `"source":"board"` lines through the loop into `live.json` (all zeros, the board being idle with nothing wired). **Not measured:** the page reading
`live.json` served from the Pi, and any live reading with a fork and a scan running.
