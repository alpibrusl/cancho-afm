"""Renders docs/h2-scanner.png: the HS profile's 64 x 64 twin scan behind different Z scanners. usage: make_h2_figure.py out.png scan.txt label [scan.txt label]..."""
import sys, numpy as np
import matplotlib; matplotlib.use("Agg")
import matplotlib.pyplot as plt
def load(fn):
    g=np.full((64,64),np.nan);b=g.copy()
    for l in open(fn).read().splitlines()[1:]:
        t=l.split()
        if len(t)!=3 or t[0]=="frame_us": continue
        a,p,z=map(int,t)
        if p<64: g[a,p]=z
        else: b[a,127-p]=z
    return g,b
args=sys.argv[2:]; items=[(args[i],args[i+1]) for i in range(0,len(args),2)]
fig,ax=plt.subplots(1,len(items),figsize=(3.2*len(items),3.9),dpi=110)
lo,hi=2400,3300
for a,(fn,lab) in zip(ax,items):
    g,b=load(fn); a.imshow(g,cmap="magma",vmin=lo,vmax=hi,interpolation="nearest"); a.set_xticks([]); a.set_yticks([])
    a.set_title("%s\ntrace-retrace rms %.0f pm"%(lab,np.nanstd(g-b)),fontsize=9)
fig.suptitle("Twin, HS profile (0.5 MHz cantilever, 250 kHz loop): the Z scanner decides. A prediction, not a measurement.",fontsize=9)
fig.tight_layout(); fig.savefig(sys.argv[1])
