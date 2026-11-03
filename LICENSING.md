# Licensing

Proposed 2026-11-02 and confirmed by the owner in the same session ("go"): European licences, because the project is European and the owner asked for EU licences.

| What | Where | Licence |
|---|---|---|
| Software and gateware: the cancho programs, the generator and the SystemVerilog it makes, the host, the twin, the tests, scripts | `sim/`, `gen/`, `host/`, `tests/`, `ui/`, `bench/`, `hw/kicad/*.cho`, `hw/kicad/*.py`, `hw/kicad/*.sh` | **EUPL-1.2** (`LICENSE`, the same text as the cancho compiler's) |
| Hardware: the schematic, the board, the netlists and simulations, the bill of materials | `hw/` (`amp.kicad_sch`, `amp.kicad_pcb`, `amp_bom.csv`, `hw/amp/`) | **CERN-OHL-S-2.0** (strongly reciprocal; EUPL-1.2 is compatible with it as a code licence, not as a hardware one) |
| Documentation: the design, the tutorial, the page, the lists | `docs/`, `README.md` | **CC BY 4.0** |

The full texts are in the repository, copied unmodified from the licensors: `LICENSE` (EUPL-1.2), `LICENSE-HARDWARE` (CERN-OHL-S-2.0, from CERN's Open Hardware Repository) and `LICENSE-DOCS` (CC BY 4.0, from creativecommons.org).

Bought parts keep their makers' licences and are not covered here. The tuning fork route and the paper this project follows are the authors' (the paper's PDF is not redistributed: `.gitignore`).
