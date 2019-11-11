function  [DataXZY,DataFormat] = LoadScanData(DataPath,stdVar,ChNr,SigNr,varargin)
% [DataXZY,DataFormat] = LoadScanData(DataPath,stdVar,ChNr,SigNr,varargin)
% 
% LoadCycleData - loads Data from Cycle mode.
% DataPath - path to Data;
% stdVar - structure from standart.var file;
% ChNr - loads data from selected channel 1 or 2;
% SigNr - loads data from specified gencode signals;
% optional input:
% 'LoadAllAvg' - loads all data.
% 'LoadingBar' - shows loading procces bar.
% 'LoadRange' - loads only specific range of data [s1 s2].
% 'LoadArea' - loads data only from specific area [x1,x2,y1,y2,z1,z2].

cond = nargin >= 4;
if ~cond
    coder.internal.assert(cond,'MATLAB:narginchk:notEnoughInputs');
end

cond = nargin <= 10;
if ~cond
    coder.internal.assert(cond,'MATLAB:narginchk:tooManyInputs');
end

% extract the parameters from the input argument list
[LoadAllAvg,LoadingBar,AscanLength,s1,s2,LoadArea,XX,YY,ZZ] = parse_inputs(DataPath,stdVar,ChNr,SigNr,varargin{:});

NrOfXst=stdVar.Xsteps+1;
NrOfYst=stdVar.Ysteps+1;
%NrOfZst=stdVar.Zsteps+1; % phyton software not support this mode (3D data in signle xxx.bin file)
NrOfZst=1;

if LoadingBar == true
    h = waitbar(0,'Initializing waitbar...');
end

if LoadAllAvg == true
    DataXZY=zeros(length(SigNr),NrOfXst,(stdVar.AvgSamplesNumber),(s2-s1+1),NrOfYst,NrOfZst);
    DataFormat={'SigNr','X','AvgNr','Data','Y','Z'};
else
    DataXZY=zeros(length(SigNr),NrOfXst,(s2-s1+1),NrOfYst,NrOfZst);
    DataFormat={'SigNr','X','Data','Y','Z'};
end

if NrOfZst == 1
    DataFormat(end)=[];
    if NrOfYst == 1
        DataFormat(end)=[];
    end
end


for SigNo=1:length(SigNr)
    fname=sprintf('%sScanADCgenCod%dCh%d.bin',DataPath,SigNr(SigNo),ChNr);
    Dfile = fopen(fname,'r'); 
    for zstep=1:NrOfZst
        for ystep=1:NrOfYst
            for xstep=1:NrOfXst
                for AvgNo=1:(stdVar.AvgSamplesNumber)
                    TT=double(fread(Dfile,AscanLength, '*uint16'));
                    TT=TT(s1:s2);
                    TT=(TT-mean(TT))/1024;
                    DataAvg(AvgNo,:)=TT;
                end
                
                if LoadArea == true
                    if (zstep >= ZZ(end)) && (ystep >= YY(end)) && (xstep > XX(end))
                        break
                    end
                end

                if ((stdVar.AvgSamplesNumber)>1) && (LoadAllAvg == true)
                    DataXZY(SigNo,xstep,:,:,ystep,zstep)=DataAvg;
                elseif ((stdVar.AvgSamplesNumber)>1) && (LoadAllAvg == false) 
                    MyAvgArr=AlignAll(DataAvg,(stdVar.AvgSamplesNumber),1);% Align to first
                    DataXZY(SigNo,xstep,:,ystep,zstep)=mean(MyAvgArr);
                else
                    DataXZY(SigNo,xstep,:,ystep,zstep)=DataAvg;
                end
                
                if LoadingBar == true
                    perc = 100-((NrOfXst-xstep)/NrOfXst*100);
                    waitbar(perc/100,h,sprintf('Loading Scan Data %2.2f%%',perc))
                end
            end 
        end
    end
    fclose(Dfile);  
    if LoadingBar == true
        close(h);
    end
end

if length(SigNr) == 1
    z = size(DataXZY);
    DataXZY=reshape(DataXZY,z(2:end));
    DataFormat(1)=[];
end  

if LoadArea == true 
    sz={''};
    for indx=1:length(DataFormat)
        if strfind(DataFormat{indx},'X')
            sz{indx}=XX;
        elseif strfind(DataFormat{indx},'Y')
            sz{indx}=YY;
        elseif strfind(DataFormat{indx},'Z')
            sz{indx}=ZZ;
        else
            sz{indx}=':';
        end
    end
    DataXZY=DataXZY(sz{:});
end




%--------------------------------------------------------------------------
function [LoadAllAvg,LoadingBar,AscanLength,s1,s2,LoadArea,XX,YY,ZZ] = parse_inputs(DataPath,stdVar,ChNr,SigNr,varargin)

% Validate inputs
validateattributes(DataPath,{'char'},{'nonempty'},'LoadCycleData','DataPath');
validateattributes(stdVar,{'struct'},{'nonempty'},'LoadCycleData','stdVar');
validateattributes(ChNr,{'numeric'},{'nonnan','integer','real','scalar','nonempty','positive','nonzero','<=',2},'LoadCycleData','ChNr');
validateattributes(SigNr,{'numeric'},{'nonnan','integer','real','vector','nonempty','positive','nonzero','<=',stdVar.GenCodeNo},'LoadCycleData','SigNr');

LoadAllAvg = false;
LoadingBar = false;
LoadArea = false;
deleteIndx=[];
for indx=1:length(varargin)
    if strfind(varargin{indx},'LoadAllAvg')
        LoadAllAvg = true;
        deleteIndx = [deleteIndx indx];
    end
    if strfind(varargin{indx},'LoadingBar')
        LoadingBar = true; 
        deleteIndx = [deleteIndx indx];
    end
    if strfind(varargin{indx},'LoadArea')
        LoadArea = true; 
    end
end
varargin(deleteIndx)=[];

AscanLength=(stdVar.Smax)-(stdVar.Smin);
s1=1;
s2=s1+AscanLength-1;
DefaultRange = [s1 s2];

NrOfXst=stdVar.Xsteps+1;
NrOfYst=stdVar.Ysteps+1;
%NrOfZst=stdVar.Zsteps+1; % phyton software not support this mode (3D data in signle xxx.bin file)
NrOfZst=1;
DefaultArea = [1,NrOfXst,1,NrOfYst,1,NrOfZst];

p = inputParser;
addParameter(p,'LoadRange',DefaultRange);
addParameter(p,'LoadArea',DefaultArea);

parse(p,varargin{1:end});

validateattributes(p.Results.LoadRange,{'numeric'},{'row','numel',2,'nonnan','integer','real','vector','nonempty','positive','nonzero','<=',stdVar.Smax},'LoadCycleData','LoadRange');
validateattributes(p.Results.LoadRange(2),{'numeric'},{'nonnan','integer','real','nonempty','positive','nonzero','>',p.Results.LoadRange(1)},'LoadRange','s2');
s1 = p.Results.LoadRange(1);
s2 = p.Results.LoadRange(2);

validateattributes(p.Results.LoadArea,{'numeric'},{'row','nonnan','integer','real','vector','nonempty','positive','nonzero'},'LoadCycleData','LoadArea');
validateattributes(p.Results.LoadArea(2),{'numeric'},{'>=',p.Results.LoadArea(1),'<=',NrOfXst},'LoadArea','x2');
validateattributes(p.Results.LoadArea(4),{'numeric'},{'>=',p.Results.LoadArea(3),'<=',NrOfYst},'LoadArea','y2');
validateattributes(p.Results.LoadArea(6),{'numeric'},{'>=',p.Results.LoadArea(5),'<=',NrOfZst},'LoadArea','z2');
XX = [p.Results.LoadArea(1):p.Results.LoadArea(2)];
YY = [p.Results.LoadArea(3):p.Results.LoadArea(4)];
ZZ = [p.Results.LoadArea(5):p.Results.LoadArea(6)];

