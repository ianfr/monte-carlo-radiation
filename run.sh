#!/bin/bash

rm Viewfactor
rm *.csv
rm *.png

nvc++ Viewfactor.cu -o Viewfactor

./Viewfactor

gnuplot makeplot.gnuplot

gnuplot makehist.gnuplot