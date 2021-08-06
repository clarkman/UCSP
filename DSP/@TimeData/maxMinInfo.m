function maxMinInfo(obj, t1, t2);

y=segment(obj,t1,t2);
ampMax=max(y.samples)
ampMin=min(y.samples)
e=energyAvg(obj,0.2);
z=segment(e,t1,t2);
energyMax=max(z.samples)
energyMin=min(z.samples)
