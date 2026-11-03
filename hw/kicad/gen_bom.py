"""Prints the bill of materials of hw/kicad/amp.kicad_sch as CSV, from its exported netlist: value, footprint, quantity, references, and what to buy.
   python3 -I hw/kicad/gen_bom.py /tmp/amp.net > hw/kicad/amp_bom.csv      (the netlist: kicad-cli sch export netlist --format kicadsexpr)"""
import re, sys, collections, csv

BUY = {  # (value, footprint name) -> what to buy; the footprint says how it is mounted
    ('330p', 'C_Disc_D5.0mm_W2.5mm_P5.00mm'): 'ceramic C0G/NP0, 50 V, 5 mm pitch (the compensation capacitors set the amplifier\'s stability: not X7R)',
    ('680p', 'C_Disc_D5.0mm_W2.5mm_P5.00mm'): 'ceramic C0G/NP0, 50 V, 5 mm pitch (as above)',
    ('1p', 'C_Disc_D5.0mm_W2.5mm_P5.00mm'): 'ceramic C0G/NP0, 50 V, 5 mm pitch, +-0.25 pF or better',
    ('10p', 'C_Disc_D5.0mm_W2.5mm_P5.00mm'): 'ceramic C0G/NP0, 50 V, 5 mm pitch',
    ('1.5-5p trim', 'C_Disc_D5.0mm_W2.5mm_P5.00mm'): 'trimmer capacitor 1.5-5 pF, through hole (the footprint is a PLACEHOLDER: take the pitch from the part\'s datasheet)',
    ('100n', 'C_Disc_D5.0mm_W2.5mm_P5.00mm'): 'ceramic X7R, 50 V, 5 mm pitch (decoupling)',
    ('100n', 'C_Rect_L7.2mm_W3.0mm_P5.00mm_FKS2_FKP2_MKS2_MKP2'): 'film (PET/PP) 100 nF, 63 V or more, 5 mm pitch (signal coupling in the fork path)',
    ('10u', 'C_Disc_D6.0mm_W4.4mm_P5.00mm'): 'radial multilayer ceramic 10 uF, X7R, 25 V or more, 5 mm pitch, NOT polarised (the -12 V rail reverses the sense an electrolytic needs)',
    ('1N5819', 'D_DO-41_SOD81_P10.16mm_Horizontal'): 'Schottky diode 1 A, DO-41 (reverse-supply protection, across the rails)',
    ('BAT54S', 'SOT-23'): 'BAT54S dual series Schottky, SOT-23 (surface mount)',
    ('500mA', 'Fuse_1206_3216Metric'): 'fuse or resettable PTC 500 mA, 1206 (surface mount)',
    ('9.53k', 'R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal'): 'metal film 1 %, 0207 (E96 value)',
    ('69.8k', 'R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal'): 'metal film 1 %, 0207 (E96 value: it sets the X/Y gain 7.98)',
    ('30.1k', 'R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal'): 'metal film 1 %, 0207 (E96 value: it sets the Z gain 4.01)',
    ('49.9k', 'R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal'): 'metal film 1 %, 0207 (E96 value: the fork drive divider 1/50.9)',
    ('1k', 'Potentiometer_Bourns_3296W_Vertical'): 'multi-turn trimmer 1 k, Bourns 3296W style (sets VREF to 1.43 V)',
    ('OPA2134PA', 'DIP-8_W7.62mm'): 'OPA2134PA dual FET op-amp, DIP-8 (the simulation\'s reference)',
    ('LM4040-2.5', 'SOT-23'): 'LM4040 2.5 V shunt reference, SOT-23 (surface mount); B grade (0.2 %) or better',
}
t = open(sys.argv[1]).read()
comps = re.findall(r'\(comp\s*\(ref "([^"]+)"\)\s*\(value "([^"]*)"\)\s*\(footprint "([^"]*)"\)', t)
groups = collections.defaultdict(list)
for ref, value, fp in comps:
    name = fp.split(':')[1] if ':' in fp else fp
    key = (value, name)
    if name.startswith('PinHeader'):
        key = ('header', name)
    if name.startswith('R_Axial') and key not in BUY:
        key = (value, name)
    groups[key].append(ref)
w = csv.writer(sys.stdout, lineterminator='\n')
w.writerow(['value', 'footprint', 'quantity', 'references', 'what to buy'])
def order(k):
    ref = groups[k][0]
    return (re.match(r'[A-Z]+', ref).group(0), int(re.search(r'\d+', ref).group(0)))
for key in sorted(groups, key=order):
    value, name = key
    refs = sorted(groups[key], key=lambda r: int(re.search(r'\d+', r).group(0)))
    if value == 'header':
        what = 'pin header 2.54 mm, %s (a piezo or DAC lead, or a screw terminal of the same pitch)' % ('3 pins' if '1x03' in name else '2 pins')
    elif key in BUY:
        what = BUY[key]
    elif name.startswith('R_Axial'):
        what = 'metal film 1 %, 0207'
    else:
        what = '??? no purchase text for this part: add it to BUY'
        sys.stderr.write('no BUY entry for %r\n' % (key,))
    w.writerow([value, name, len(refs), ' '.join(refs), what])
