# Videos of the twin

Five short videos, all **predictions of this software, not measurements**: the sample parameters that are not from a paper are labelled as stand-ins in each video and in the document named below.

| file | shows | design and numbers |
|---|---|---|
| `hs_twin.mp4` | the high-speed twin: frame rate, Z range, Q control in air | `docs/high-speed.md` |
| `hs_dynamic.mp4` | a moving sample imaged at high speed | `docs/high-speed.md`, `docs/dynamics.md` |
| `force_curves_twin.mp4` | force curves of a supported bilayer, analysed live; dynamic force spectroscopy | `docs/dynamics.md` |
| `diffusion_tracking_twin.mp4` | particles of a known D imaged at 10.3 and 1.55 frames/s, tracked, D read back | `docs/dynamics.md` |
| `fv_side_by_side_twin.mp4` | a 32 x 32 force-volume map of a made-up gel/fluid bilayer filling in beside each pixel's live curve | `docs/dynamics.md`, "Force-volume map" |

**Provenance.** The data in each video come from the cancho programs of this repository (`host/scan_twin.cho`, `host/curve_twin.cho`, `host/fv_twin.cho`, the tracking and diffusion tests); `tests/fvmap.sh` reproduces the numbers quoted in the last one. The frames were drawn and encoded with a throw-away Python (PIL) and ffmpeg script that is **not** in this repository, because this project keeps its tools in cancho; the videos are a presentation of the twin's output, not part of any gate. If a video and the document disagree, the document is right.
