"""Renders docs/hs-vs-fork.mp4: the twin's tuning-fork scan and its high-speed scan of the same sample, side by side in simulated REAL time.
usage: make_hs_video.py fork_scan.txt hs_scan.txt frames_dir   (the scan files are host/scan_twin.cho's output for profiles 0 and 1)"""
import sys, numpy as np
import matplotlib; matplotlib.use("Agg")
import matplotlib.pyplot as plt
N=64; FPS=20; SECONDS=12; HOLD=3
def load(fn):
    L=open(fn).read().splitlines()
    g=np.full((N,N),np.nan); head=L[0]; fu=None
    for l in L[1:]:
        t=l.split()
        if t and t[0]=="frame_us": fu=int(t[1]); continue
        if len(t)==3:
            a,p,z=map(int,t)
            if p<N: g[a,p]=z
    return g,fu,head
fork,fu_f,_=load(sys.argv[1]); hs,fu_h,hh=load(sys.argv[2])
win=hh.split("window ")[1].split(",")[0]
tf=fu_f/1e6; th=fu_h/1e6   # seconds per frame, trace + retrace, as the twin counts clocks
bg="#0f1419";fg="#e6e6e6";ac="#4fc3f7";warn="#ffb74d"
plt.rcParams.update({"figure.facecolor":bg,"axes.facecolor":"#161c23","axes.edgecolor":"#445","text.color":fg,"axes.labelcolor":fg,"xtick.color":fg,"ytick.color":fg,"font.size":11})
lo,hi=2400,3300
def partial(g,frac):
    out=np.full_like(g,np.nan); n=int(frac*N*N); flat=g.ravel().copy(); o=np.full(N*N,np.nan); o[:n]=flat[:n]; return o.reshape(N,N)
total=(SECONDS+HOLD)*FPS
for i in range(total):
    t=min(i/FPS,SECONDS)
    fig=plt.figure(figsize=(12.8,7.2),dpi=100)
    fig.text(.04,.93,"cancho-afm: the same sample, two instruments, in real (simulated) time",fontsize=19,weight="bold")
    fig.text(.04,.885,"Software twin: a prediction, not a measurement. No fork, cantilever, photodiode or scanner has been built or tested.",color=warn,fontsize=11)
    ax1=fig.add_axes([.04,.20,.43,.62]); ax2=fig.add_axes([.53,.20,.43,.62])
    ff=(t/tf)%1.0 if t<tf else 1.0
    ax1.imshow(partial(fork,ff),cmap="magma",vmin=lo,vmax=hi,interpolation="nearest")
    nf=int(t/th); fh=(t%th)/th
    ax2.imshow(partial(hs,fh if nf<9999 else 1.0),cmap="magma",vmin=lo,vmax=hi,interpolation="nearest")
    for a in (ax1,ax2): a.set_xticks([]); a.set_yticks([])
    ax1.set_title("tuning fork: 32.8 kHz, Q 500, 64-sample window\n%.0f s per 64 x 64 frame"%tf,fontsize=11,loc="left")
    ax2.set_title("high speed: 0.5 MHz, %s-sample window, 4.5 MS/s\n%.2f s per 64 x 64 frame (%.1f frames/s)"%(win,th,1/th),fontsize=11,loc="left")
    ax1.text(.02,.96,"frame 1: %d%%"%int(100*ff),transform=ax1.transAxes,color="white",fontsize=11,va="top",bbox=dict(fc="#000a",ec="none"))
    ax2.text(.02,.96,"frame %d: %d%%"%(nf+1,int(100*fh)),transform=ax2.transAxes,color="white",fontsize=11,va="top",bbox=dict(fc="#000a",ec="none"))
    fig.text(.04,.125,"simulated time  %5.2f s"%t,family="monospace",fontsize=16,color=ac)
    fig.text(.04,.085,"Frames finished: fork %d, high-speed %d.  Frame = trace + retrace; 20 loop updates per pixel (high speed), 60 (fork)."%(int(t//tf),nf),fontsize=10)
    fig.text(.04,.04,"Not modelled: photodiode and laser noise, liquid damping, the real scanner (the twin's ideal one is used), tip shape, drift.\nThe sample is invented; each high-speed frame repeats the one twin image.",fontsize=9,color=fg)
    fig.savefig("%s/v%04d.png"%(sys.argv[3],i)); plt.close(fig)
print(total)
