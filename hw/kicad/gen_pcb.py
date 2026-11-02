"""Makes hw/kicad/amp.kicad_pcb from the KiCad netlist of amp.kicad_sch: every footprint named in the schematic, copied from KiCad's own libraries,
placed in rows by function, its pads on the nets of the schematic, a board outline and a ground pour on both layers. NO TRACKS: placement only.
   python3 -I gen_pcb.py NETLIST FOOTPRINT_LIB_DIR [ROUTES] > amp.kicad_pcb
With PADS_OUT=path it also writes the pads file hw/kicad/route.cho reads; ROUTES is route.cho's output (tracks and vias), added to the board.
(NETLIST: kicad-cli sch export netlist --format kicadsexpr; FOOTPRINT_LIB_DIR: KiCad's footprints directory, holding the .pretty folders.)"""
import re, sys, os

class S(str):          # a quoted string, kept apart from a bare atom
    pass

def parse(text):
    tok = re.findall(r'\(|\)|"(?:[^"\\]|\\.)*"|[^\s()]+', text)
    pos = 0
    def one():
        nonlocal pos
        pos += 1
        out = []
        while tok[pos] != ')':
            if tok[pos] == '(':
                out.append(one())
            else:
                t = tok[pos]
                out.append(S(t[1:-1]) if t.startswith('"') else t)
                pos += 1
        pos += 1
        return out
    return one()

def dump(n, ind=0):
    if isinstance(n, S):
        return '"' + n.replace('"', '\\"') + '"' if False else '"' + str(n) + '"'
    if not isinstance(n, list):
        return str(n)
    return '(' + ' '.join(dump(c) for c in n) + ')'

def sub(node, name):
    return [c for c in node if isinstance(c, list) and c and c[0] == name]

netlist = parse(open(sys.argv[1]).read())
libdir = sys.argv[2]
comps = {}
for c in sub(sub(netlist, 'components')[0], 'comp'):
    ref = str(sub(c, 'ref')[0][1])
    comps[ref] = dict(value=str(sub(c, 'value')[0][1]), fp=str(sub(c, 'footprint')[0][1]), uuid=str(sub(c, 'tstamps')[0][1]))
nets, pad_net = {}, {}
for n in sub(sub(netlist, 'nets')[0], 'net'):
    name = str(sub(n, 'name')[0][1])
    code = len(nets) + 1
    nets[name] = code
    for nd in sub(n, 'node'):
        pad_net[(str(sub(nd, 'ref')[0][1]), str(sub(nd, 'pin')[0][1]))] = (code, name)

# ---- groups: a row each, in this order ----
groups = [
    ['J1', 'R1', 'R2', 'C1', 'R3', 'J4'],
    ['J2', 'R4', 'R5', 'C2', 'R6', 'J5'],
    ['J3', 'R7', 'R8', 'C3', 'R9', 'J6'],
    ['U1', 'C4', 'C5', 'C6', 'C7', 'U2', 'C8', 'C9', 'C10', 'C11'],
    ['R10', 'U3', 'R11', 'R12', 'RV1'],
    ['J7', 'F1', 'F2', 'D1', 'D2'],
    ['J10', 'C12', 'R13', 'R14', 'J8', 'R15', 'R16', 'C13', 'R17', 'C14'],
    ['C15', 'R18', 'R19', 'R20', 'C16', 'R21', 'D3', 'J9', 'J11', 'R22', 'R23'],
    ['U4', 'C17', 'C18', 'C19', 'C20', 'U5', 'C21', 'C22', 'C23', 'C24'],
]
missing = set(comps) - {r for g in groups for r in g}
assert not missing, f"parts without a place: {sorted(missing)}"

uid = [0]
def u():
    uid[0] += 1
    return '"00000000-0000-4000-9000-%012d"' % uid[0]

def load(fp):
    lib, name = fp.split(':')
    path = os.path.join(libdir, lib + '.pretty', name + '.kicad_mod')
    return parse(open(path).read())

def extent(mod):
    """the courtyard's (x0, y0, x1, y1), else the pads' and lines' box"""
    xs, ys = [], []
    for node in mod:
        if isinstance(node, list) and node and node[0] in ('fp_rect', 'fp_line', 'fp_circle', 'fp_poly') and any(isinstance(l, list) and l[:1] == ['layer'] and l[1] == 'F.CrtYd' for l in node):
            for sub_ in node:
                if isinstance(sub_, list) and sub_[0] in ('start', 'end', 'center'):
                    xs.append(float(sub_[1])); ys.append(float(sub_[2]))
                if isinstance(sub_, list) and sub_[0] == 'pts':
                    for xy in sub_[1:]:
                        xs.append(float(xy[1])); ys.append(float(xy[2]))
    if not xs:
        for node in mod:
            if isinstance(node, list) and node and node[0] == 'pad':
                at = sub(node, 'at')[0]; size = sub(node, 'size')[0]
                xs += [float(at[1]) - float(size[1]) / 2, float(at[1]) + float(size[1]) / 2]
                ys += [float(at[2]) - float(size[2]) / 2, float(at[2]) + float(size[2]) / 2]
    return min(xs), min(ys), max(xs), max(ys)

GAP, MARGIN, MAXW = 3.0, 6.0, 175.0
placed = []
y = MARGIN
width = 0
for g in groups:
    x = MARGIN
    row_h = 0
    items = []
    for ref in g:
        mod = load(comps[ref]['fp'])
        x0, y0, x1, y1 = extent(mod)
        items.append((ref, mod, x0, y0, x1, y1))
    # wrap a long group into rows
    for it in items:
        ref, mod, x0, y0, x1, y1 = it
        if x + (x1 - x0) > MAXW and x > MARGIN:
            x = MARGIN
            y += row_h + GAP
            row_h = 0
        placed.append((ref, mod, x - x0, y - y0))
        x += (x1 - x0) + GAP
        row_h = max(row_h, y1 - y0)
        width = max(width, x)
    y += row_h + GAP + 2
W, H = width + MARGIN - GAP, y + MARGIN - 2


# ---- the pads, for the router (micrometres): "net x y radius layers route"; layers 0 through-hole, 1 front copper only; route 0 for the poured ground and for pads on no net ----
if os.environ.get('PADS_OUT'):
    lines = ['%d %d' % (round(W * 1000), round(H * 1000))]
    for ref, mod, dx, dy in placed:
        for node in mod:
            if isinstance(node, list) and node and node[0] == 'pad':
                at, size = sub(node, 'at')[0], sub(node, 'size')[0]
                code, name = pad_net.get((ref, str(node[1])), (0, None))
                r = max(float(size[1]), float(size[2])) / 2
                if str(node[3]) == 'rect':
                    r = (float(size[1]) ** 2 + float(size[2]) ** 2) ** 0.5 / 2     # a square pad reaches its corner
                through = str(node[2]) in ('thru_hole', 'np_thru_hole')
                owner = code if code else 250
                route = 0 if (name is None or name == '/GND') else 1
                lines.append('%d %d %d %d %d %d' % (owner, round((dx + float(at[1])) * 1000), round((dy + float(at[2])) * 1000), round(r * 1000), 0 if through else 1, route))
    open(os.environ['PADS_OUT'], 'w').write('\n'.join(lines) + '\n')

out = []
out.append('(kicad_pcb (version 20241229) (generator "cancho-afm") (generator_version "1")')
out.append('  (general (thickness 1.6) (legacy_teardrops no))')
out.append('  (paper "A3")')
out.append('  (layers (0 "F.Cu" signal) (2 "B.Cu" signal) (9 "F.Adhes" user "F.Adhesive") (11 "B.Adhes" user "B.Adhesive") (13 "F.Paste" user) (15 "B.Paste" user) (5 "F.SilkS" user "F.Silkscreen") (7 "B.SilkS" user "B.Silkscreen") (1 "F.Mask" user) (3 "B.Mask" user) (17 "Dwgs.User" user "User.Drawings") (19 "Cmts.User" user "User.Comments") (25 "Edge.Cuts" user) (27 "Margin" user) (31 "F.CrtYd" user "F.Courtyard") (29 "B.CrtYd" user "B.Courtyard") (35 "F.Fab" user) (33 "B.Fab" user))')
out.append('  (setup (pad_to_mask_clearance 0) (pcbplotparams (layerselection 0x00010fc_ffffffff) (outputdirectory "")))')
out.append('  (net 0 "")')
for name, code in nets.items():
    out.append('  (net %d "%s")' % (code, name))
for ref, mod, dx, dy in placed:
    c = comps[ref]
    body = []
    for node in mod[2:]:
        if isinstance(node, list) and node and node[0] in ('version', 'generator', 'generator_version', 'embedded_fonts'):
            continue
        if isinstance(node, list) and node and node[0] == 'property' and node[1] == 'Reference':
            node = [node[0], S('Reference'), S(ref)] + node[3:]
        if isinstance(node, list) and node and node[0] == 'property' and node[1] == 'Value':
            node = [node[0], S('Value'), S(c['value'])] + node[3:]
        if isinstance(node, list) and node and node[0] == 'pad':
            num = str(node[1])
            if (ref, num) in pad_net:
                code, name = pad_net[(ref, num)]
                node = node + [['net', code, S(name)]]
            node = node + [['uuid', S(u().strip('"'))]]
        body.append(node)
    head = [S(c['fp']), ['layer', S('F.Cu')], ['uuid', S(u().strip('"'))], ['at', '%.3f' % dx, '%.3f' % dy], ['path', S('/' + c['uuid'])]]
    out.append('  ' + dump(['footprint'] + head + body))

if len(sys.argv) > 3:
    for line in open(sys.argv[3]):
        f = line.split()
        if f and f[0] == 'S':
            layer, net_, x1, y1, x2, y2 = f[1], int(f[2]), *[int(v) / 1000 for v in f[3:7]]
            out.append('  (segment (start %.3f %.3f) (end %.3f %.3f) (width 0.25) (layer "%s") (net %d) (uuid %s))' % (x1, y1, x2, y2, 'F.Cu' if layer == '0' else 'B.Cu', net_, u()))
        elif f and f[0] == 'V':
            out.append('  (via (at %.3f %.3f) (size 0.8) (drill 0.4) (layers "F.Cu" "B.Cu") (net %s) (uuid %s))' % (int(f[2]) / 1000, int(f[3]) / 1000, f[1], u()))
        elif f and f[0] == 'F':
            sys.stderr.write("router could not finish net %s\n" % f[1])
x0, y0, x1, y1 = 0, 0, W, H
for (a, b, c_, d) in [(x0, y0, x1, y0), (x1, y0, x1, y1), (x1, y1, x0, y1), (x0, y1, x0, y0)]:
    out.append('  (gr_line (start %.2f %.2f) (end %.2f %.2f) (stroke (width 0.1) (type default)) (layer "Edge.Cuts") (uuid %s))' % (a, b, c_, d, u()))
for layer in ('F.Cu', 'B.Cu'):
    out.append('  (zone (net %d) (net_name "/GND") (layer "%s") (uuid %s) (hatch edge 0.5) (connect_pads yes (clearance 0.5)) (min_thickness 0.25) (filled_areas_thickness no) (fill yes (thermal_gap 0.5) (thermal_bridge_width 0.5)) (polygon (pts (xy 0.5 0.5) (xy %.2f 0.5) (xy %.2f %.2f) (xy 0.5 %.2f))))' % (nets['/GND'], layer, u(), W - 0.5, W - 0.5, H - 0.5, H - 0.5))
out.append(')')
print('\n'.join(out))
sys.stderr.write("board %.1f x %.1f mm, %d footprints, %d nets\n" % (W, H, len(placed), len(nets)))
