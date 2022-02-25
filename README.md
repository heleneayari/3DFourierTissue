# 3DFourierTissue

About
=====

Matlab code for calculating cell volume in 3D tissue using Fourier Transform.
All details can be found in our article:
"Measuring the average cell size and width of its distribution in cellular tissues using Fourier Transform",
published in EPJE.

## FourierImageAnalysisModel


This is the class used to do all the Fourier analysis.
A program using this class will first start with creating a new object of this class.
FIA = FourierImageAnalysisModel;
And then applying the convenient methods to apply the Fourier Transform and then calculate the 
cell size.
FIA.performFft;
FIA.interp3D;  
FIA.calculateWavelength;

Main properties:

+ 

Main methods:
+

## Computing local volume

One can use the FourierImageAnalysisModel class to compute locally cell volume inside a compressed aggregate.
You can load the following example 'local_fft3D' which runs on one of our  image 
'HCT116_PressureShock_15kPa_6kDa_before_satck_z1um-01_1.tif'

In this experiment, the aggregates have a cylindrical shape, we can therefore easily plot cellsize as a function
of the radial distance from the center of the aggregate.

First we will find the center and radius of our aggregate, then divide the image in boxes taken on a polar grid.
And we will average all the results obtained for different $\theta$.




# Authors

Tess Homan (t.a.m.homan@tue.nl)
Hélène Delanoë-Ayari (helene.ayari@univ-lyon1.fr)


# License

GNU General Public License v3.0
