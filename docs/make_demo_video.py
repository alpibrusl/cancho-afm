import json, re, sys, os
import matplotlib; matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
S=sys.argv[1]
R=[json.loads(l) for l in open(S+"/vid/live.jsonl")]
txt=open(S+"/vid/demo.txt").read().splitlines()
img=[]
k=[i for i,l in enumerate(txt) if l.startswith("image")][0]
for l in txt[k+1:]:
    if re.fullmatch(r"[\d ]+",l.strip()): img.append([int(v) for v in l.split()])
img=np.array(img)
n=len(R); amp=np.array([r["amp"] for r in R]); z=np.array([r["z_pm"] for r in R])
X=np.array([r["x"] for r in R]); Y=np.array([r["y"] for r in R])
facts=[l for l in txt[2:7]]
bg="#0f1419"; fg="#e6e6e6"; ac="#4fc3f7"; ac2="#ffb74d"
plt.rcParams.update({"figure.facecolor":bg,"axes.facecolor":"#161c23","axes.edgecolor":"#445","text.color":fg,"axes.labelcolor":fg,"xtick.color":fg,"ytick.color":fg,"font.size":11})
STEP=6; frames=list(range(STEP,n+1,STEP))+[n]*20
for fi,m in enumerate(frames):
    fig=plt.figure(figsize=(12.8,7.2),dpi=100)
    gs=fig.add_gridspec(3,2,left=.06,right=.97,top=.80,bottom=.11,hspace=.55,wspace=.18)
    fig.text(.06,.93,"cancho-afm  -  automatic AFM, run on the software twin",fontsize=20,weight="bold")
    fig.text(.06,.885,"A prediction of this software, not a measurement. No fork, amplifier or tip has been built or tested yet.",color=ac2,fontsize=11)
    fig.text(.06,.845,f"scan reading {min(m,n):3d}/{n}   ctrl=0x{R[min(m,n)-1]['ctrl']:02X}   source: {R[0]['source']}",family="monospace",fontsize=11,color=ac)
    a=fig.add_subplot(gs[0,0]); a.plot(amp[:m],color=ac,lw=1.2); a.set_xlim(0,n); a.set_ylim(amp.min()-300,amp.max()+300); a.set_title("fork amplitude (lock-in, counts)",fontsize=11,loc="left")
    b=fig.add_subplot(gs[1,0]); b.plot(z[:m],color=ac2,lw=1.2); b.set_xlim(0,n); b.set_ylim(z.min()-8,z.max()+8); b.set_title("Z height (pm), loop holds amplitude",fontsize=11,loc="left")
    c=fig.add_subplot(gs[2,0]); c.plot(X[:m],color="#9ccc65",lw=1); c.set_xlim(0,n); c.set_title("X scan position (DAC counts)",fontsize=11,loc="left"); c.set_xlabel("reading")
    d=fig.add_subplot(gs[:,1])
    p=min(1,m/n); npx=int(round(img.size*p)); shown=np.full(img.size,np.nan); shown[:npx]=img.ravel()[:npx]
    d.imshow(shown.reshape(img.shape),cmap="magma",vmin=img.min(),vmax=img.max(),aspect="equal",interpolation="nearest")
    d.set_title("image built line by line (Z, pm)",fontsize=11,loc="left"); d.set_xticks([]); d.set_yticks([])
    if m>=n:
        cb=fig.colorbar(d.images[0],ax=d,fraction=.046,pad=.03); cb.set_label("Z (pm)")
        fig.text(.06,.02,"twin found: fork f0 = 32781.5 Hz (twin's 32781.4), Q 495 (500)  |  contact at Z = 2704 pm  |  grating period 5.9 px (true 6)  |  0 refused writes",fontsize=10,color=fg)
    fig.savefig(f"{S}/frames/f{fi:04d}.png"); plt.close(fig)
print(len(frames))
