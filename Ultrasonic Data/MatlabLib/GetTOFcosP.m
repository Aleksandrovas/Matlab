function  ToF = GetTOFcosP(Ascan,Ref);
%function  [ToF] = GetTOFcosP(Ascan,Ref);
%used to get TOF in subsamples using cosine aproximation
%size of both Ascan and Ref must be the same
%range defined internally
% locates POSITIVE max of xcorr
% ToF is ABSOLUTE!!!!!
% POSITIVE ToF mean that Ascan is shifted RIGHT(delay) relative to Ref
% NEGATIVE ToF mean that Ascan is shifted LEFT(advanced) relative to Ref
AscanLength=length(Ascan);
%%xcorr
MyXcor=xcorr(Ascan,Ref);
% MyXcor=XcoorInTime(Ascan,Ref);
%MyXcor=abs(hilbert(xcorr(Ascan,Ref)));
%determine rough max pos
% [~,IH] = max(abs(hilbert(MyXcor)));
% [~,Iz] = max(abs(MyXcor(IH-1:IH+1)));
% I=Iz+IH-2;
%   [~,I] = max(abs(MyXcor));%
[~,I] = max(MyXcor);%
% if I==1,
%     size(MyXcor)
%     figure(100)
%     plot(MyXcor);
% end;
MyXcor=MyXcor*sign(MyXcor(I));
%determine accurate max pos by Cos interpolation
alpha=acos((MyXcor(I-1)+MyXcor(I+1))/(2*MyXcor(I)));
beta=atan((MyXcor(I-1)-MyXcor(I+1))/(2*MyXcor(I)*sin(alpha)));
Px=-beta/alpha;
% TOF0 detecton and assignment
ToF=(I+Px);%/fsampl;
% %check >
% figure(1)
% nnn=1:length(MyXcor);
% [~,~,~,~,PAmp0,~]=find123max(MyXcor)
% plot(nnn,MyXcor,'-x',ToF,PAmp0,'o',[ToF-3 ToF+3],[MyXcor(I) MyXcor(I)]);
% xlim([ToF-30 ToF+30]);
% %xlim([ToF-3 ToF+3]);
% % if sign(MyXcor(I))<0, ylim([PAmp0*1.03 PAmp0*0.8]);
% % else ylim([PAmp0*0.8 PAmp0*1.03]);
% % end;
% %<check

ToF=ToF-AscanLength;
%ToF=ToF-length(MyXcor)/2-1;

