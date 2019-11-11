%used to read Izograf ADC BINARY data
%scan step is assumed x,x,x,x,x -xLarge y- then x-x-x-x-x
%otherwise change cycle nesting
% need proper reference from epoxy
% iterative deconvolution processing
clear all;

%DataPath='Z:\Research\BGA\2013_01_11BGA_STR710\';
%DataPath='Z:\Research\PCB\2_side_white_top_3\pulse\';
%DataPath='Z:\Research\PCB\2_side_white_top_4\chirp50usdly\';
%DataPath='Z:\Research\PCB\2_side_white_top_3\pulseBarePCBnoTopCopperLong\';
%DataPath='Z:\Research\PCB\2_side_white_top_3\chirpBarePCBnoTopCopperLong\';
%DataPath='Z:\Research\Stripping\dibond\dibondWater5MHz2\';
%DataPath='Z:\Research\Stripping\dibond\dibondAir1MHz2\';
%DataPath='z:\Research\Stripping\thinPlastic\thinPlasticw20MHz\';%1 / AscanLength
%DataPath='Z:\Research\Stripping\billlabel\billLabel20MHz\';
%DataPath='Z:\Research\PCB\2_side_serg_desra\';%150/100
%DataPath='Z:\Research\Sticker\5MHz\';
% DataPath='y:\Research\Concrete\';%300 1500/3000 decim4
%DataPath='z:\Research\JapanPCB\200x200_01mm_binAir\';% decim 10
% DataPath='Z:\Research\Stripping\billlabel\BillLabelOnPerspex\5MHz\';%200;200 decim 2
%DataPath='Z:\Research\Concrete\Fibre\';
%DataPath='Z:\Research\Concrete\ConcreteTests\PF03C34L_HoleScan\';
% DataPath='Z:\Research\Concrete\ConcreteTests\DC05C30N_WholeScan\';
%DataPath='Y:\Research\Concrete\2013_10_28\Chirp\';
% DataPath='E:\Svilainiui\Concrete\conc_test\2014_01_03_Slab_38mm_RXintoSmooth\';
DataPath='z:\Research\ADECON\expData\GFRPreflection2sigCW_Chirp\';%

[StepXsize,StepYsize,NrOfXst,NrOfYst,Znr1,Znr2,fsampl] = LoadVariables([DataPath 'standard.var']);
NrOfYst=50;%%%%%%%%%
decimationCoef=10;%10
AscanLength=Znr2-Znr1+1;
X=((1:NrOfXst)-1)*StepXsize*1000;
Y=((1:NrOfYst)-1)*StepYsize*1000;
dt=1/fsampl;    % sampling period
C=1482.5;%1481.5;%348 Air Vol;% ultrasound speed, enter manually
Zoffset=1;%180%1500;%
sigLen=AscanLength;6000;100%AscanLength;
%make sure it is 2N (necessary for FFT shift)
%if mod(sigLen,2), sigLen=sigLen-1;end;
%make sure it is 2N (necessary for FFT shift) and can be decimated
sigLen=floor(sigLen/(decimationCoef*2))*(decimationCoef*2)
Z1=Zoffset;
Z2=Z1+sigLen-1;
%load "reference" (actually same data)
%DataXY = LoadBINxyDecimate([DataPath 'ADC1.bin'],NrOfXst,NrOfYst,AscanLength,Z1,Z2,decimationCoef);
DataXY = LoadBINxyDecimate([DataPath 'ScanADCgenCod1Ch1.bin'],NrOfXst,NrOfYst,AscanLength,Z1,Z2,decimationCoef);
%DataXY = LoadBINxy([DataPath 'ADC1.bin'],NrOfXst,NrOfYst,AscanLength,Z1,Z2);
fsampl=fsampl/decimationCoef;
sigLen=floor(sigLen/decimationCoef);
nr=0:sigLen-1;
t=dt*(nr-1);    % time axis
Z=t*C*1000;
f=fsampl*nr/sigLen;

%low pass
% [B,A] = butter(5,5e6/(fsampl/2),'high');
% for ynr=1:NrOfYst,
%     for xnr=1:NrOfXst,
%         DataXY(xnr,:,ynr)=filtfilt(B,A,DataXY(xnr,:,ynr));
%     end;
% end;

XposNr=10;%enter manually to select Xpos for alingnment
YposNr=10;%enter manually to select Ypos for alingnment

BscX=squeeze(DataXY(XposNr,:,:));
figure(1)
% plot(Bsc')
% title('Ascan along X');xlabel('z, mm');ylabel('ampl V');
% grid on
%pcolor(Z,X,BscX);
pcolor(BscX);
shading interp;colormap hot;
title('Bscan along X before alignment');xlabel('z, mm');ylabel('x, mm');
grid on
colorbar
%axis image

% CC= squeeze(std(DataXY,[],2)); CCbottom=mean(mean(CC))
% CCbottom=mean(mean(CC))/1.4;
% CCN=CC; nrCC=find(CC<CCbottom); CCN(nrCC)=CCbottom;clear nrCC;

figure(2)
pcolor(X,Y,squeeze(std(DataXY,[],2))');
%pcolor(squeeze(std(DataXY,[],2))');
%pcolor(squeeze(20*log10(std(DataXY,[],2)))');
%pcolor(X,Y,20*log10(flipud(CCN)));
% pcolor(X,Y,((CCN')));
shading interp;colormap hot;
title('Cscan before stripping');xlabel('x, mm');ylabel('y, mm');
grid on
colorbar
axis image

%%front face alignment
[DataXYaligned,ToF2D] = AlignAll(DataXY,XposNr,YposNr);

%reference now can be averaged
Ref=squeeze(mean(mean(DataXY,1),3));
tref=((1:length(Ref))-1)/fsampl;

%% can process from here
% clear all
% load BGA_STR710

figure(3);
%plot(tref,Ref2D',tref,Ref,'k');
%plot(tref,Ref,'k');
plot(Ref,'k');
title('reference Ascan');%xlabel('x, mm');ylabel('U, V');
grid on
%clear Ref2D

%Read in the main array

% BscX=squeeze(DataXY(:,:,YposNr));
% BscY=squeeze(DataXY(XposNr,:,:));
% 
% figure(4)
% % plot(Bsc')
% % title('Ascan along X');xlabel('z, mm');ylabel('ampl V');
% % grid on
% %pcolor(Z,X,BscX);
% pcolor(BscX);
% shading interp;colormap hot;
% title('Bscan along X');xlabel('z, mm');ylabel('x, mm');
% grid on
% colorbar
% %axis image
% 
% figure(5)
% % plot(Bsc')
% % title('Ascan along Y');xlabel('z, mm');ylabel('ampl V');
% % grid on
% %pcolor(Z,Y,BscY');
% pcolor(BscY');
% shading interp;colormap hot;
% title('Bscan along Y');xlabel('z, mm');ylabel('x, mm');
% grid on
% colorbar
% %axis image

% H2D=(ToF2D-mean(mean(ToF2D))).*C*1000/2;%height in mm
% Cmax=squeeze(std(DataXY(:,290:390,:),[],2));
% 
% %plot aligned B-scan
% figure(6)
% % plot(MyXcor)
% % pcolor(T,F,abs(S));
% %pcolor(X,Y,ToF2D');
% pcolor(X,Y,Cmax');
% %pcolor(Cmax');
% %surfl(H2D);
% shading interp; colormap hot;
% title('C-scan after alignment');xlabel('x, mm');ylabel('y, mm');
% colorbar
% % axis([0.55e-5 0.95e-5 0 5e6])
% %caxis([min(min(ToF2D))*10 max(max(ToF2D))]);
% %caxis([0.16e-5 max(max(ToF2D))])
% grid on
% 
% figure(7)
% % plot(MyXcor)
% % pcolor(T,F,abs(S));
% pcolor(X,Y,ToF2D');
% shading interp; colormap hot;
% title('Cscan ToF');xlabel('x, mm');ylabel('y, mm');
% colorbar
% % axis([0.55e-5 0.95e-5 0 5e6])
% %caxis([min(min(ToF2D))*10 max(max(ToF2D))]);
% %caxis([0.16e-5 max(max(ToF2D))])
% grid on

%%now strip-off the reference/average signal
for ynr=1:NrOfYst,
    
    for xnr=1:NrOfXst,
        %DataXYstriped(xnr,:,ynr)=DataXY(xnr,:,ynr)-Ref;
        DataXYstripped(xnr,:,ynr)=DataXYaligned(xnr,:,ynr)-Ref;
        CscanStripped(xnr,ynr)=(std(DataXYstripped(xnr,:,ynr),[],2));
    end;
end;
%CscanStripped=squeeze(std(DataXYstriped(:,:,:),[],2)); 

% CCSbottom=mean(mean(CscanStripped))*2
% CscanStrippedN=CscanStripped; nrCCS=find(CscanStripped>CCSbottom); CscanStrippedN(nrCCS)=CCSbottom;

%plot remainder C-scan
figure(8)
% plot(MyXcor)
% pcolor(T,F,abs(S));
%pcolor(X,Y,flipud(CscanStrippedN));
pcolor(X,Y,CscanStripped');
shading interp; colormap hot;
title('Cscan stripped');xlabel('x, mm');ylabel('y, mm');
colorbar
axis image
% axis([0.55e-5 0.95e-5 0 5e6])
%caxis([min(min(ToF2D))*10 max(max(ToF2D))]);
%caxis([0.16e-5 max(max(ToF2D))])
grid on

for ynr=1:NrOfYst,
    ynr
    for xnr=1:NrOfXst,
        HilberEnvelopeDataXY(xnr,:,ynr)=abs(hilbert(DataXYstripped(xnr,:,ynr)));
        %HilberEnvelopeDataXY(xnr,:,ynr)=abs(hilbert(DataXY(xnr,:,ynr)));
        %HilberEnvelopeDataXY(xnr,:,ynr)=abs(hilbert(Data_cor(xnr,:,ynr)));
        
        
    end;
end;

% figure(9)
% % plot(MyXcor)
% %pcolor(squeeze(DataXYstriped(:,1:558,150)));
% pcolor(squeeze(DataXY(:,:,50)));
% shading interp; colormap hot;
% title('Bscan stripped');xlabel('x, mm');ylabel('y, mm');
% colorbar
% % axis([0.55e-5 0.95e-5 0 5e6])
% %caxis([min(min(ToF2D))*10 max(max(ToF2D))]);
% %caxis([0.16e-5 max(max(ToF2D))])
% grid on
