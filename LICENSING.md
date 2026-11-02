# Licensing

Proposed 2026-11-02 and confirmed by the owner in the same session ("go"): European licences, because the project is European and the owner asked for EU licences.

| What | Where | Licence |
|---|---|---|
| Software and gateware: the cancho programs, the generator and the SystemVerilog it makes, the host, the twin, the tests, scripts | `sim/`, `gen/`, `host/`, `tests/`, `ui/`, `bench/`, `hw/kicad/*.cho`, `hw/kicad/*.py`, `hw/kicad/*.sh` | **EUPL-1.2** (`LICENSE`, the same text as the cancho compiler's) |
| Hardware: the schematic, the board, the netlists and simulations, the bill of materials | `hw/` (`amp.kicad_sch`, `amp.kicad_pcb`, `amp_bom.csv`, `hw/amp/`) | **CERN-OHL-S-2.0** (strongly reciprocal; EUPL-1.2 is compatible with it as a code licence, not as a hardware one) |
| Documentation: the design, the tutorial, the page, the lists | `docs/`, `README.md` | **CC BY 4.0** |

**Not yet in the repository:** the full texts of CERN-OHL-S-2.0 and CC BY 4.0. They are to be added as `LICENSE-HARDWARE` and `LICENSE-DOCS`, copied from the licensors' own pages (CERN's Open Hardware Repository and Creative Commons), not retyped; until they are, the hardware and
the documents are not yet licensed to anyone but the owner, whatever this table says. The EUPL text is there.

Bought parts keep their makers' licences and are not covered here. The tuning fork route and the paper this project follows are the authors' (the paper's PDF is not redistributed: `.gitignore`).
