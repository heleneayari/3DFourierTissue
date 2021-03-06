classdef FourierImageAnalysisModel < handle
    properties
        Image
        DeltaT=1;
        FftEnergy
        FftTotalEnergy
        Resolution=[1 1 1]; % units chosen/pixel  (for exemple if unit is µm frequency would be given in  1/µm
        ImageSize
        FftImageSize
        FftImageCenter
        qr
        dqr
        qth
        freq
        Fsz
        Fszdth
        keepzero
        Msz
        Mszdth
        Msznn
        Msr
        V
        Wavelength
        Wavelengthmax
        Wavelengthnum
        WavelengthAmplitude
        Width50
        Widthnum50
        Windowing
        Wt
        WX
        WY
        WZ
    end
    
    methods
        function FIA = FourierImageAnalysisModel(varargin)
            p = inputParser;
            addParameter(p, 'Image', @isnumeric);
            addParameter(p, 'Resolution',[1, 1, 1], @isnumeric);
            addParameter(p, 'qr',linspace(0,0.5,512), @isnumeric);
            addParameter(p, 'DeltaT',1, @isnumeric);
            addParameter(p, 'keepzero', 0, @isnumeric);
            addParameter(p, 'Windowing', 1, @isnumeric);
            parse(p, varargin{:});
            
            FIA.Image = p.Results.Image;
            FIA.Resolution = p.Results.Resolution;
            FIA.qr=p.Results.qr;
            FIA.DeltaT = p.Results.DeltaT;
            FIA.keepzero=p.Results.keepzero;
            FIA.Windowing=p.Results.Windowing;
            FIA.ImageSize = size(FIA.Image);
            
            
        end
        
        
        
        
        function FIA = performFft(FIA)
            if FIA.Windowing
                im_win = windowing(FIA.Image);
            else
                im_win=FIA.Image;
            end
            
            im_fft = fftn(im_win,FIA.ImageSize);
            if ~FIA.keepzero
                im_fft(1)=0;
            end
            
            im_fft_shift = fftshift(im_fft);%
            FIA.FftEnergy = abs(im_fft_shift).^2;
            FIA.FftTotalEnergy = sum(FIA.FftEnergy(:));
            FIA.FftImageSize = size(FIA.FftEnergy);
            FIA.FftImageCenter = (FIA.FftImageSize + bitget(abs(FIA.FftImageSize),1))/2 + ~bitget(abs(FIA.FftImageSize),1);
            
            
        end
        function FIA=cutCenter(FIA,nb)
            
            if length(FIA.FftImageSize)==3
                FIA.FftEnergy(FIA.FftImageCenter(1)-nb:FIA.FftImageCenter(1)+nb,FIA.FftImageCenter(2)-nb:FIA.FftImageCenter(2)+nb,FIA.FftImageCenter(3)-nb:FIA.FftImageCenter(3)+nb)=0;
            else
                FIA.FftEnergy(FIA.FftImageCenter(1)-nb:FIA.FftImageCenter(1)+nb,FIA.FftImageCenter(2)-nb:FIA.FftImageCenter(2)+nb)=NaN;
            end
        end
        
        
        function FIA=interp3D(FIA)
            
            if mod(FIA.FftImageSize(2),2)==0
                wx=(-FIA.FftImageSize(2)/2:1:(FIA.FftImageSize(2)/2-1))/(FIA.FftImageSize(2)*FIA.Resolution(1));
            else
                wx=(-(FIA.FftImageSize(2)-1)/2:1:(FIA.FftImageSize(2)-1)/2)/(FIA.FftImageSize(2)*FIA.Resolution(1));
            end
            if mod(FIA.FftImageSize(1),2)==0
                wy=(-FIA.FftImageSize(1)/2:1:(FIA.FftImageSize(1)/2-1))/(FIA.FftImageSize(1)*FIA.Resolution(2));
            else
                wy=(-(FIA.FftImageSize(1)-1)/2:1:(FIA.FftImageSize(1)-1)/2)/(FIA.FftImageSize(1)*FIA.Resolution(2));
            end
            if mod(FIA.FftImageSize(3),2)==0
                wz=(-FIA.FftImageSize(3)/2:1:(FIA.FftImageSize(3)/2-1))/(FIA.FftImageSize(3)*FIA.Resolution(3));
            else
                wz=(-(FIA.FftImageSize(3)-1)/2:1:(FIA.FftImageSize(3)-1)/2)/(FIA.FftImageSize(3)*FIA.Resolution(3));
            end
            
            [FIA.WX,FIA.WY,FIA.WZ]=meshgrid(wx,wy,wz);
            pasth=pi/100;
            pasph=pi/100;
            FIA.dqr=mean(diff(FIA.qr));
            [theta,phi,rt]=meshgrid(-pi:pasth:pi,-pi/2:pasph:pi/2,FIA.qr);
            [x,y,z] = sph2cart(theta,phi,rt);
            ind=z>max(wz)|z<min(wz);
            
            
            FIA.V=interp3(FIA.WX,FIA.WY,FIA.WZ,FIA.FftEnergy,x,y,z,'linear',NaN);
            FIA.V(ind)=NaN;
            Vavph=nanmean(FIA.V,1);
            Vavthph=nanmean(squeeze(Vavph),1);
            Vrsum=Vavthph*4*pi.*FIA.qr.^2;
            FIA.Msz=Vrsum/nansum(Vrsum)/FIA.dqr;
            FIA.Msznn=Vrsum/FIA.dqr;
            FIA.Mszdth=Vavthph/nansum(Vavthph,2);
            
            
        end
        
        function FIA = calculateWavelength(FIA)
            
            [psz, ii] = max(FIA.Msz);
            FIA.Wavelengthnum=ii;
            FIA.Wavelengthmax = 1/FIA.qr(ii);
            FIA.WavelengthAmplitude = psz;
            perc=0.5;
            i1=find(diff(sign(FIA.Msz(1:ii)-psz*perc))~=0&~isnan(diff(sign(FIA.Msz(1:ii)-psz*perc))));
            i2=find(diff(sign(FIA.Msz(ii:end)-psz*perc))~=0&~isnan(diff(sign(FIA.Msz(ii:end)-psz*perc))));
            
            if ii==1
                FIA.Wavelength=NaN;
            else
                if ~isempty(i1)&&~isempty(i2)
                    Width(1)=i1(end);
                    Width(2)=i2(1)+ii;
                    FIA.Widthnum50=Width;
                    FIA.Width50=(Width-1)*FIA.dqr+FIA.qr(1);
                    ind50=FIA.Widthnum50(1):FIA.Widthnum50(2);
                    qm50=sum(FIA.qr(ind50).*FIA.Msz(ind50))/sum(FIA.Msz(ind50));
                    FIA.Wavelength=1/qm50;
                    FIA.freq=qm50;
                else
                    FIA.Wavelength=FIA.Wavelengthmax;
                end
            end
            
            
            
        end
        
        
        function FIA = interpolateFft2D(FIA)
            if mod(FIA.FftImageSize(2),2)==0
                wx=(-FIA.FftImageSize(2)/2:1:(FIA.FftImageSize(2)/2-1))/(FIA.FftImageSize(2)*FIA.Resolution(1));
            else
                wx=(-(FIA.FftImageSize(2)-1)/2:1:(FIA.FftImageSize(2)-1)/2)/(FIA.FftImageSize(2)*FIA.Resolution(1));
            end
            if mod(FIA.FftImageSize(1),2)==0
                wy=(-FIA.FftImageSize(1)/2:1:(FIA.FftImageSize(1)/2-1))/(FIA.FftImageSize(1)*FIA.Resolution(2));
            else
                wy=(-(FIA.FftImageSize(1)-1)/2:1:(FIA.FftImageSize(1)-1)/2)/(FIA.FftImageSize(1)*FIA.Resolution(2));
            end
            
            [FIA.WX,FIA.WY]=meshgrid(wx,wy);
            FIA.qth = linspace(0, 2*pi, 200);
            FIA.dqr=mean(diff(FIA.qr));
            [QTheta, QRho] = meshgrid(FIA.qth, FIA.qr); % create a grid with radial points
            [QX, QY] = pol2cart(QTheta, QRho);    % the same grid in cartesian coordinates
            
            if length(FIA.FftImageSize)==3
                for ii=1:FIA.FftImageSize(3)
                    FIA.Fsz(:,:,ii) = interp2(FIA.WX, FIA.WY, FIA.FftEnergy(:,:,ii), QX, QY);
                    Fszavth=nanmean(FIA.Fsz(:,:,ii),2);
                    Fszrsum=Fszavth.*2.*pi.*FIA.qr';
                    Fszavr=nanmax(QRho.*FIA.Fsz(:,:,ii),[],1);
                    FIA.Msr(ii,:)=Fszavr'/nansum(Fszavr,2);
                    FIA.Msz(ii,:)=Fszrsum/nansum(Fszrsum)/FIA.dqr;
                    FIA.Mszdth(ii,:)=Fszavth/nansum(Fszavth);
                end
                if mod(FIA.FftImageSize(3),2)==0
                    FIA.Wt=(-FIA.FftImageSize(3)/2:1:(FIA.FftImageSize(3)/2-1))/(FIA.FftImageSize(3)*FIA.DeltaT);
                else
                    FIA.Wt=(-(FIA.FftImageSize(3)-1)/2:1:(FIA.FftImageSize(3)-1)/2)/(FIA.FftImageSize(3)*FIA.DeltaT);
                end
            else
                
                FIA.Fsz = interp2(wx, wy, FIA.FftEnergy, QX, QY);
                Fszavth=nanmean(FIA.Fsz,2);
                Fszavr=nanmean(FIA.Fsz,1)';
                Fszrsum=Fszavth.*2.*pi.*FIA.qr';
                FIA.Msz=Fszrsum/nansum(Fszrsum,1)/FIA.dqr;
                FIA.Mszdth=Fszrsum/nansum(Fszrsum,1);
                FIA.Msr=Fszavr/nansum(Fszavr,1);
            end
            
        end
    end
    
end