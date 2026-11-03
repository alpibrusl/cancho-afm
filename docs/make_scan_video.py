"""Renders docs/scan-twin.mp4 from `cancho run host/scan_twin.cho ...` output (see that file's header); usage: make_scan_video.py scan.txt frames_dir [label]"""
import sys, numpy as np
import matplotlib; matplotlib.use("Agg")
import matplotlib.pyplot as plt
lines=open(sys.argv[1]).read().splitlines()[1:]
rows=[l.split() for l in lines if len(l.split())==3]
fu=[int(l.split()[1]) for l in lines if l.startswith("frame_us")]
label=sys.argv[3] if len(sys.argv)>3 else "64 x 64 scan on the software twin"
fps="  Predicted %.1f frames/s (trace+retrace)."%(1e6/fu[0]) if fu else ""
N=64
fwd=np.full((N,N),np.nan); bwd=np.full((N,N),np.nan)
for ln,px,z in ((int(a),int(b),int(c)) for a,b,c in rows):
    if px<N: fwd[ln,px]=z
    elif px<2*N: bwd[ln,2*N-1-px]=z
NM=45.8   # nm per pixel: 100 DAC codes, ASSUMED 16 bits over 30 um (docs/converters.md)
ext=[0,N*NM/1000,N*NM/1000,0]
bg="#0f1419";fg="#e6e6e6"
plt.rcParams.update({"figure.facecolor":bg,"axes.facecolor":"#161c23","axes.edgecolor":"#445","text.color":fg,"axes.labelcolor":fg,"xtick.color":fg,"ytick.color":fg,"font.size":11})
lo,hi=np.nanmin(fwd),np.nanmax(fwd)
frames=list(range(1,N+1))+[N]*40
for fi,m in enumerate(frames):
    fig=plt.figure(figsize=(12.8,7.2),dpi=100)
    fig.text(.05,.93,"cancho-afm - "+label,fontsize=20,weight="bold")
    fig.text(.05,.885,"Made-up sample, noise on. Twin prediction, not a measurement."+fps,color="#ffb74d",fontsize=11)
    a=fig.add_axes([.05,.10,.48,.74]); img=fwd.copy(); img[m:,:]=np.nan
    im=a.imshow(img,cmap="magma",vmin=lo,vmax=hi,extent=ext,interpolation="nearest"); a.set_xlabel("x (um)"); a.set_ylabel("y (um)")
    a.set_title("height Z (pm), trace direction",loc="left",fontsize=11)
    cb=fig.colorbar(im,ax=a,fraction=.046,pad=.02); cb.set_label("Z (pm)")
    a.axhline(m*NM/1000,color="#4fc3f7",lw=.8)
    b=fig.add_axes([.62,.52,.35,.32]); xs=(np.arange(N)+.5)*NM/1000
    r=m-1; b.plot(xs,fwd[r],color="#4fc3f7",label="trace"); b.plot(xs,bwd[r],color="#ffb74d",label="retrace")
    b.set_ylim(lo-20,hi+20); b.set_title(f"line {m}: trace vs retrace (loop lag shows as the gap)",loc="left",fontsize=11); b.set_xlabel("x (um)"); b.set_ylabel("Z (pm)"); b.legend(loc="upper right",facecolor="#161c23",edgecolor="#445",labelcolor=fg,fontsize=9)
    c=fig.add_axes([.62,.10,.35,.30]); c.plot(np.arange(1,m+1),np.nanmean(fwd[:m],axis=1),color="#9ccc65"); c.set_xlim(1,N); c.set_ylim(np.nanmin(np.nanmean(fwd,axis=1))-10,np.nanmax(np.nanmean(fwd,axis=1))+10)
    c.set_title("mean Z per line (the terrace at line 26, particles)",loc="left",fontsize=11); c.set_xlabel("line"); c.set_ylabel("Z (pm)")
    fig.text(.05,.02,"scale ASSUMED: 100 DAC codes = 45.8 nm per pixel (16 bits over 30 um), so the image is 2.9 um across; Z in pm from the 16 pm per code DAC",fontsize=9,color=fg)
    fig.savefig(f"{sys.argv[2]}/s{fi:04d}.png"); plt.close(fig)
