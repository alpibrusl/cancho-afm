# Bench bring-up of afm_top over the board's serial port (first run 2026-11-02, 19 of 19 checks passed). Reads the identifier first and stops
# if it is not afm_top's, so it changes nothing on some other design. It writes only harmless registers (SAMPLE_DIV, a signed read-back
# word, and the motor enable bit with MOTOR_MAX = 0, which must refuse the command). A throwaway bench tool in Python for the Raspberry Pi
# (standard library only); superseded by host/bringup.cho (the same checks in cancho), which passed 17 of 17 on the same board.
import os, termios, time, struct, sys
fd = os.open("/dev/ttyUSB1", os.O_RDWR | os.O_NOCTTY | os.O_NONBLOCK)
a = termios.tcgetattr(fd)
a[0] = 0; a[1] = 0; a[2] = termios.CS8 | termios.CREAD | termios.CLOCAL; a[3] = 0
a[4] = a[5] = termios.B115200
a[6][termios.VMIN] = 0; a[6][termios.VTIME] = 0
termios.tcsetattr(fd, termios.TCSANOW, a)
termios.tcflush(fd, termios.TCIOFLUSH)
def xfer(req, want, timeout=1.0):
    termios.tcflush(fd, termios.TCIFLUSH)
    os.write(fd, bytes(req))
    got = b""; t = time.time()
    while len(got) < want and time.time() - t < timeout:
        try:
            got += os.read(fd, 16)
        except BlockingIOError:
            time.sleep(0.002)
    return got
def wr(i, v):
    r = xfer([0x57, 0x40, 0, 0, i * 4] + list(struct.pack(">I", v & 0xFFFFFFFF)), 1)
    return r[0] if r else None
def rd(i):
    r = xfer([0x52, 0x40, 0, 0, i * 4], 5)
    if len(r) != 5: return None, None
    return struct.unpack(">I", r[1:])[0], r[0]
fails = 0
def check(name, ok, detail=""):
    global fails
    print(("PASS " if ok else "FAIL ") + name + (" " + detail if detail else ""))
    if not ok: fails += 1
v, c = rd(0);  check("identifier is afm_top's (0xAF500001)", v == 0xAF500001 and c == 0, hex(v) if v is not None else "no answer")
if v != 0xAF500001:
    print("stopping: not our design on the port"); sys.exit(2)
v, c = rd(1);  check("CTRL is 0 at power-on", v == 0)
v, c = rd(14); check("ZMAX is 0 at power-on (fails closed)", v == 0)
v, c = rd(47); check("MOTOR_MAX is 0 at power-on (the motor cannot move)", v == 0)
v, c = rd(3);  check("SAMPLE_DIV default 103", v == 103, str(v))
v, c = rd(4);  check("TUNING default 536870912", v == 536870912, str(v))
v, c = rd(44); check("MOTOR_RATE default 27000", v == 27000, str(v))
check("write SAMPLE_DIV answers OKAY", wr(3, 120) == 0)
v, c = rd(3);  check("SAMPLE_DIV reads back 120", v == 120); wr(3, 103)
check("write to read-only STATUS is refused (SLVERR)", wr(2, 1) == 2)
check("write to read-only ID is refused", wr(0, 1) == 2)
v, c = rd(60); check("read of an unmapped register is refused", c == 2)
check("signed read-back of a 32-bit word", (wr(8, 0xFFFFFFF6) == 0) and rd(8)[0] == 0xFFFFFFF6); wr(8, 0)
# the motor fails closed: enabled but MOTOR_MAX = 0, a command is refused and the position does not move
wr(1, 0x20)
wr(43, 1); time.sleep(0.05)
v, c = rd(45); check("motor command refused while MOTOR_MAX = 0", v is not None and (v >> 2) & 1 == 1 and v & 1 == 0, bin(v) if v is not None else "")
v, c = rd(46); check("motor position still 0", v == 0)
wr(1, 0)
v, c = rd(45); check("motor disabled again", v is not None and (v >> 1) & 1 == 0)
# status, counters idle
v, c = rd(2);  check("STATUS idle (no fault, no overflow)", v == 0, hex(v) if v is not None else "")
v, c = rd(40); check("no ADC samples while ADC run is off", v == 0)
# repeat the identifier read many times: framing stays in sync
ok = all(rd(0)[0] == 0xAF500001 for _ in range(50))
check("50 identifier reads in a row", ok)
print("failures:", fails)
sys.exit(0 if fails == 0 else 1)
