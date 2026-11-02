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
