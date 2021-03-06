%% This code is written for measuring locally cell size in an aggregate 
% compressed in between two plates see Fig. 9 of our article

clear;
close all;
clc;
%%
folder='/data1/thoman/ownCloud/Git/3DFourierTissue/';
cd(folder)
file=dir([folder,'*.tif']);
%%
for uu=1:length(file)
    %%
    h=figure;
    hold on
    h2=figure;
    hold on
    title('Areas selected for Fourier calculations')
    axis off
    axis equal
    info=imfinfo([folder,file(uu).name]);
    im1=imread([folder,file(uu).name],1);
    th=graythresh(im1);
    
    imt=tiffread([folder,file(uu).name]);
    
 
        pz=1;

    im=zeros([size(imt(1).data), length(imt)]);
    for ii=1:length(info)
        ima=imt(ii).data;
        BW=imbinarize(ima,th);
        ima(BW)=0;
        im(:,:,ii)=ima;       
    end
   
    figure(h2)
    imagesc(im(:,:,25))
    colormap(gray)
    %%
    %% The aggregate can be modelled as a cylinder, we will first find 
    %the center  and radius of the circle of the base of the cylinder
    % uncomment this code to calculate it, or directly load the result
    
%     sz=size(im1);
%     th=graythresh(im1);
%     BW=im2bw(im1,th);
%     BW=imfill(1-BW,'holes');
%     [B,L] = bwboundaries(BW,'noholes');
%     figure
%     imagesc(im(:,:,1))
%     axis equal
%     axis off
%     colormap(gray)
%     hold on
%     boundary=[];
%     for k = 1:length(B)
%         boundary = cat(1,boundary,B{k});
%     
%     end
%     ind=boundary(:,1)==1|boundary(:,2)==1|boundary(:,1)==sz(2)|boundary(:,2)==sz(1);
%     boundary(ind,:)=[];
%    % plot(boundary(:,2), boundary(:,1), '+w', 'LineWidth', 2)
%     [z,R]= fitcircle(boundary);
%      plot(z(2),z(1),'g+')
%     viscircles([z(2) z(1)],R,'Color','g')
%    % save([folder,'circle.mat'],'z','R')
%     pause
    load([folder,'circle.mat'])
    figure(h2)
    viscircles([z(2) z(1)],R,'Color','g');
    plot(z(2),z(1),'g+')
 
    %% We will divide our image in boxes of size Box  on a polar grid 
    Box=128;
    vecr=0:20:R;
    dtheta=Box/2/R;
    vecmth=0:dtheta:2*pi;
    qr=linspace(0,0.5,512);
    lambda=nan(length(vecr),length(vecmth));
    intens=nan(length(vecr),length(vecmth));
    
    
    
    cc=1;
    FFTs=zeros(length(qr),length(vecr));
    for r=vecr
        disp(r);
  
  % we will now calculate the Fourier transform on each of this box      
        if r==0
            posrect=[z(1)-Box/2 z(2)-Box/2 Box Box];
            clear imc
            imc=zeros(Box+1,Box+1,size(im,3));
            figure(h2)
            rectangle('Position',posrect,'EdgeColor','r') 
            for ii=1:size(im,3)
                imc(:,:,ii)=imcrop(im(:,:,ii),posrect);
            end

            
            FIA = FourierImageAnalysisModel('image',imc, 'qr',qr,'Resolution', [1/info(1).XResolution, 1/info(1).YResolution , pz]);
            FIA.performFft;
            FIA.interp3D;          
            FFTs(:,cc)=FIA.Msz'+FFTs(:,cc);
            FIA.calculateWavelength;
            lambda(cc,1)=FIA.Wavelength;
            
        else
            dtheta=Box/r;
            cc2=1;
            for theta=0:dtheta:2*pi
                cbox=[z(1)+r*cos(theta) z(2)+r*sin(theta)];
                posrect=[cbox(1)-Box/2 cbox(2)-Box/2 Box Box];
 
                clear imc
              %  imc=zeros(Box+1,Box+1,size(im,3));
                for ii=1:size(im,3)                   
                    imc(:,:,ii)=imcrop(im(:,:,ii),posrect);
      
                end
                    sz=size(imc);
                    if sz(1)==(Box+1) &&sz(2)==(Box+1)
                           
                figure(h2)
                rectangle('Position',posrect,'EdgeColor','r') 
% CAREFUL info(1).XResolution is given in pixels/??m and the
% FourierImageAnalysisModel want the pixel size ??m/pixel
                    FIA = FourierImageAnalysisModel('image',imc,'qr',qr,  'Resolution', [1/info(1).XResolution, 1/info(1).YResolution,pz]);
                    FIA.performFft;
                    FIA.interp3D;
                    FFTs(:,cc)=FIA.Msz'+FFTs(:,cc); 
                    FIA.calculateWavelength; 
                    lambda(cc,cc2)=FIA.Wavelength;                 

                    
                end
                FFTs(:,cc)=FFTs(:,cc)/(cc2);
                cc2=cc2+1;              
            end          
        end
        cc=cc+1;       
    end
    clear lambdam
    figure
    plot(qr,FFTs)
    NN=sum(~isnan(lambda),2);
    lambdam=nanmedian(lambda,2);
    lambdas=nanstd(lambda,0,2)./sqrt(NN);

    makePretty
    figure(h)
    h.Name='cellsizeasfunctionofr';
    figToolbarFix
    errorbar(vecr/info(1).XResolution,lambdam,lambdas)
    xlabel('radial distance ($\mu m$)')
    ylabel('Cell size ($\mu m$)')
    set(gca,'Xlim',[0 160], 'Ylim',[9 14])
    box off
    figure(h2)
    h2.Name='areaselected';
    figToolbarFix

    
%     close all
%     clearvars -except folder uu file
end




