## Background
Based on the Python code from Chapter 4 "Thermal Radiation" in "Monte-Carlo Simulation" by Alan Stevens.

This **GPU-accelerated C++ code** calculates the proportion of isotropically emitted radiation from a 
horizontal rectangle (XY plane) that is absorbed by a vertical rectangle (YZ plane) which shares an edge.

This proportion is known as the view factor, and normally it would require evaluating a 4-dimensional
integral but here we use a 'hit-or-miss' monte carlo approach by simulating rays being emitted from
the horizontal surface.

## Results

mean view factor: 0.232858
standard deviation: 0.000792459
standard error: 1.12071e-05

Histogram showing the distribution of calculated view factors:
![](GPU/output/vf-hist.png)

Scatter plot showing the calculated view factor for each trial with the horizontal line representing the mean:
![](GPU/output/vf-plot.png)

## Speedup
For 5000 trials with 10^5 iterations each:

Serial C++ runtime: 36.196s

GPU C++ runtime: 0.181s

**200x speedup**!

GPU is an RTX 3060, CPU is an i9-11900k.

