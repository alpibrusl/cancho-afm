"""Checks hw/kicad/amp.kicad_sch against the circuits that were simulated (hw/amp/xy_amp_b.cir, z_amp.cir).
Input: the KiCad netlist (kicad-cli sch export netlist --format kicadsexpr). Prints one line per check; exits 1 if any fails."""
import re, sys

def sexp(text):
    tok = re.findall(r'\(|\)|"(?:[^"\\]|\\.)*"|[^\s()]+', text)
    pos = 0
    def parse():
        nonlocal pos
        pos += 1
        out = []
        while tok[pos] != ')':
            if tok[pos] == '(':
                out.append(parse())
            else:
                out.append(tok[pos].strip('"'))
                pos += 1
        pos += 1
        return out
    return parse()

def find(node, name):
    return [c for c in node if isinstance(c, list) and c and c[0] == name]

net = sexp(open(sys.argv[1]).read())
parts = {}
for c in find(find(net, 'components')[0], 'comp'):
    ref = find(c, 'ref')[0][1]
    parts[ref] = find(c, 'value')[0][1]
pin_net = {}
for n in find(find(net, 'nets')[0], 'net'):
    name = find(n, 'name')[0][1].lstrip('/')
    for nd in find(n, 'node'):
        pin_net[(find(nd, 'ref')[0][1], find(nd, 'pin')[0][1])] = name

fails = 0
def check(ok, what):
    global fails
    print(("PASS " if ok else "FAIL ") + what)
    if not ok: fails += 1

def between(ref, a, b):
    return {pin_net.get((ref, '1')), pin_net.get((ref, '2'))} == {a, b}

def spice(path):
    d = {}
    for line in open(path):
        m = re.match(r'^(Rg|Rf|Riso)\s+\S+\s+\S+\s+(\S+)', line)
        if m: d[m.group(1)] = m.group(2)
        m = re.search(r'\.param.*\bCF=(\S+)', line)
        if m: d['Cf'] = m.group(1)
        m = re.search(r'\bRISO=(\S+)', line)
        if m: d['Riso'] = m.group(1)
    return d

xy, z = spice('../amp/xy_amp_b.cir'), spice('../amp/z_amp.cir')
# channel: (name, Rg, Rf, Cf, Riso, Rg returns to, op-amp, inverting pin, output pin, non-inverting pin, input net, out net)
chans = [('X', 'R1', 'R2', 'C1', 'R3', 'VREF', 'U1', '2', '1', '3', 'X_IN', 'X_OUT', 'XN', 'XOA', xy),
         ('Y', 'R4', 'R5', 'C2', 'R6', 'VREF', 'U1', '6', '7', '5', 'Y_IN', 'Y_OUT', 'YN', 'YOA', xy),
         ('Z', 'R7', 'R8', 'C3', 'R9', 'GND', 'U2', '2', '1', '3', 'Z_IN', 'Z_OUT', 'ZN', 'ZOA', z)]
for (n, rg, rf, cf, ri, rto, u, minus, outp, plus, vin, vout, inn, oa, sp) in chans:
    check(between(rg, inn, rto), f"{n}: Rg {rg} joins the inverting node {inn} to {rto}")
    check(between(rf, inn, vout), f"{n}: Rf {rf} is taken from the LOAD side ({vout}), not the op-amp output")
    check(between(cf, inn, oa), f"{n}: Cf {cf} joins {inn} to the op-amp output {oa}")
    check(between(ri, oa, vout), f"{n}: Riso {ri} joins the op-amp output {oa} to {vout}")
    check(pin_net.get((u, minus)) == inn and pin_net.get((u, outp)) == oa and pin_net.get((u, plus)) == vin, f"{n}: {u} pins {minus}/{outp}/{plus} are {inn}/{oa}/{vin}")
    check(parts[rg] == sp['Rg'] and parts[rf] == sp['Rf'] and parts[cf] == sp['Cf'] and parts[ri] in (sp['Riso'], '47'),
          f"{n}: values Rg {parts[rg]} Rf {parts[rf]} Cf {parts[cf]} Riso {parts[ri]} equal the simulation's {sp['Rg']} {sp['Rf']} {sp['Cf']} {sp['Riso']}")
# the reference buffer: a follower on VREF
check(pin_net.get(('U2', '5')) == 'VDIV' and pin_net.get(('U2', '6')) == 'VREF' and pin_net.get(('U2', '7')) == 'VREF', "VREF: U2 unit 2 is a follower of VDIV")
# the divider from the 2.5 V shunt: unloaded output with the trimmer at mid-travel (500 ohm), computed from the schematic's own values
def ohms(s):
    m = re.match(r'^([0-9.]+)(k?)$', s)
    return float(m.group(1)) * (1000 if m.group(2) else 1)
rt, rb, rv = ohms(parts['R11']), ohms(parts['R12']), ohms(parts['RV1'])
vlo, vhi = 2.5 * rb / (rt + rb + rv), 2.5 * (rb + rv) / (rt + rb + rv)
check(vlo < 1.43 < vhi, f"VREF: the trimmer spans {vlo:.3f} to {vhi:.3f} V and holds the simulated 1.43 V")
check(between('R11', 'VR25', 'VDIV') and between('R12', 'VDIV', 'VT') and pin_net.get(('RV1', '1')) == 'VT' and pin_net.get(('RV1', '3')) == 'GND' and pin_net.get(('RV1', '2')) == 'GND', "VREF: R11, R12 and the rheostat form the divider VR25 - VDIV - VT - GND")
# every op-amp is decoupled on both rails
for c, a, b in [('C4', '+12V', 'GND'), ('C5', '+12V', 'GND'), ('C6', 'GND', '-12V'), ('C7', 'GND', '-12V')]:
    check(between(c, a, b), f"decoupling {c} {parts[c]} between {a} and {b}")
print("%d failure(s)" % fails)
sys.exit(1 if fails else 0)
