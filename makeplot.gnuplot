set terminal png size 800,600

set output 'vf-plot.png'

mu=0.23285
set arrow 1 from 0,mu to 5000,mu nohead dt "."

plot 'out.csv' with points

