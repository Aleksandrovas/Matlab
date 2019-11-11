function  [AlignedArray,ToFmap] = AlignAll(ArrayToAlign,NrXToAlign,NrYToAlign)
% [AlignedArray,ToFmap] = AlignAll(ArrayToAlign,NrXToAlign,NrYToAlign)
% used to align Izograf BIN data
% data in ArrayToAlign is (NrOfXst,AscanLength,NrOfYst) size
% returns AlignedArray, aligned according to NrXToAlign,NrYToAlign position
% also returns ToFmap

[NrOfXst,AscanLength,NrOfYst]=size(ArrayToAlign);
%%TOF0 detection
Ref=(ArrayToAlign(NrXToAlign,:,NrYToAlign));
MyXcor=xcorr(ArrayToAlign(NrXToAlign,:,NrYToAlign),Ref);
%determine rough max pos
[xxx,I] = max(MyXcor);
%determine accurate max pos by Parabolic interpolation
Px=(MyXcor(I-1)-MyXcor(I+1))/(2*(MyXcor(I-1)-2*MyXcor(I)+MyXcor(I+1)));
% TOF0 detecton and assignment
TOF0=(I+Px);%/fsampl;

%%alignment
for ynr=1:NrOfYst,
    for xnr=1:NrOfXst,
        %ToF position determination and alignment
        MyXcor=xcorr(ArrayToAlign(xnr,:,ynr),Ref);
        %determine rough max pos
        [xxx,I] = max(MyXcor);
        %determine accurate max pos by Parabolic interpolation
        Px=(MyXcor(I-1)-MyXcor(I+1))/(2*(MyXcor(I-1)-2*MyXcor(I)+MyXcor(I+1)));
        % TOF
        TOF=(I+Px);%/fsampl;
        %align with NrXToAlign,NrYToAlign-th A-scan
        DeltaTOF=TOF-TOF0;
        ToFmap(xnr,ynr)=TOF;
        %AlignedArray(xnr,:,ynr)=shiftByfft(ArrayToAlign(xnr,:,ynr),DeltaTOF,fsampl);
        AlignedArray(xnr,:,ynr)=shiftSubsampleByfft(ArrayToAlign(xnr,:,ynr),DeltaTOF);
    end;
end;

