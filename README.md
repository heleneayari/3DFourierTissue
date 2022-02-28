# 3DFourierTissue

About
=====

This is  a Matlab code for calculating cell volume in 3D tissue using Fourier Transform (developed on version R2017a).
All details can be found in our article:
"Measuring the average cell size and width of its distribution in cellular tissues using Fourier Transform",
published in EPJE.

## FourierImageAnalysisModel


This is the class used to do all the Fourier analysis.
A program using this class will first start with creating a new object of this class.
FIA = FourierImageAnalysisModel;
And then applying the convenient methods to apply the Fourier Transform and then calculate 
cell size.
FIA.performFft;
FIA.interp3D;  
FIA.calculateWavelength;

Main properties:

+ Image (2D/3D), image on which the FFT will be applied
+ FftEnergy : square norm of Fourier coefficients
+ windowing : boolean to apply a windowing function before appplying FFT, in order to avoid edge artifacts (default 1)
+ keepzero : boolean to put to zero or not the zero frequency value, (default 0)
+ Resolution :  a  3 component vector in units chosen/pixel  (for exemple if unit is µm frequency would be given in  1/µm) (default,[1 1 1])
+ qr : the frequency vector (default,linspace(0,0.5,512))
+ Msz : Radial normalized energy density as defined in the article
+ Wavelength : Cell size as given by the more robust formula proposed in the article :$
f_{peak}=\frac{\int_{f_1}^{f_2}k*e_n(k)\,dk}{\int_{f_1}^{f_2}e_n(k)\,dk}$
+ freq = 1/Wavelength
+ Wavelengthmax : wavelength given by the position of the maximum of the peak in the Fourier space.

Main methods:
+ performFft : Calculate FFT on image
+ interp3D : Interpolate the FFT values on a spherical grid $(r,\theta,\phi)$, and perform  a summation on $\theta$ and $\phi$ on a shell
+ calculateWavelength : for calculating wavelength and wavelengthmax

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
