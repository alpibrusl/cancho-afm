# hw/amp: simulations behind docs/amplifier.md

ngspice netlists (ngspice 47). `opamp.lib` is a behavioural single-pole op-amp, **not a vendor model**. Run one with `ngspice -b xy_amp_b.cir`; the numbers it
prints are the `RESULT` lines.

| File | What |
|---|---|
| `opamp.lib` | the op-amp: gain, gain-bandwidth, output resistance, output swing |
| `xy_amp.cir`, `run_xy.sh` | X/Y driver, variant A (feedback before the isolation resistor): works only if the op-amp's output resistance is low |
| `xy_amp_b.cir`, `run_xy_b.sh` | X/Y driver, variant B (the design): gain, mid-code offset, bandwidth, step response, swept over Cf, load capacitance and output resistance |
| `z_amp.cir` | Z driver, same compensation, gain 4 |
| `fork_fe.cir` | the fork's drive attenuator, a model of the fork, the compensation path and the receive chain, swept over the compensation capacitor |
| `tia_chain.cir` | the receive chain alone, from a current source: transimpedance and corners |
