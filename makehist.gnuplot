# adapted from stack overflow

n=500 #number of intervals
max=0.3 #max value
min=0. #min value
width=(max-min)/n #interval width
#function used to map a value to the intervals
hist(x,width)=width*floor(x/width)+width/2.0
set boxwidth width*0.9
set style fill solid 0.5 # fill style

set terminal png size 800,600

set output 'vf-hist.png'

#count and plot
plot "vf.csv" u (hist($1,width)):(1.0) smooth freq w boxes lc rgb"green" notitle