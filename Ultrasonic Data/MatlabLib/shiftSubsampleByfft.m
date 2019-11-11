function [ ArrShifted ] = shiftSubsampleByfft( ArrIn, ShiftSubsamples)
%FFTSHIFT (ArrIn, ShiftSubsamples)
% is used to produce the subsample-shifted array ArrIn version
% fft uis used for shift, therefore shift is cyclic
% ShiftSubsamples must be given in subsamples i.e. 1.05
% POSITIVE ShiftSubsamples values shift LEFT
% NEGATIVE ShiftSubsamples values shift RIGHT
% size of ArrIn must be (1,:)
Nmax=length(ArrIn);

Hnmax=floor(Nmax/2);
fs=1;
% df=1/Nmax;
SArrIn=fft(ArrIn);
%Faxis=[((1:(Hnmax+1))-1)*df (((Hnmax+2):Nmax)-(Nmax+1))*df];

nr=(1:Hnmax+1)-1;
f(1:Hnmax+1)=fs/Nmax*nr;
nr=(Hnmax+2:Nmax)-(Nmax+1);
f(Hnmax+2:Nmax)=fs/Nmax*nr;

phaseaxis=1i.*2.*pi.*f.*ShiftSubsamples;
ArrShifted=real(ifft(SArrIn.*exp(phaseaxis)));
end

