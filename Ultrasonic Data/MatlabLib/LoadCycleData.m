function  [Data,DataFormat] = LoadCycleData(DataPath,stdVar,ChNr,SigNr,varargin)
% [Data,DataFormat] = LoadCycleData(DataPath,stdVar,ChNr,SigNr,varargin)
% 
% LoadCycleData - loads Data from Cycle mode.
% DataPath - path to Data;
% stdVar - experiment setup structure from standart.var file;
% ChNr - loads data from selected channel 1 or 2;
% SigNr - loads data for specified excitation (gencode) signals;
% optional input:
% 'LoadAllAvg' - loads all data.
% 'LoadingBar' - shows loading procces bar.
% 'LoadRange' - loads only specific range of data [s1 s2].
% 'LoadRawData' - loads raw ADC data 

cond = nargin >= 4;
if ~cond
    coder.internal.assert(cond,'MATLAB:narginchk:notEnoughInputs');
end

cond = nargin <= 9;
if ~cond
    coder.internal.assert(cond,'MATLAB:narginchk:tooManyInputs');
end

% extract the parameters from the input argument list
[LoadAllAvg,LoadingBar,AscanLength,s1,s2,LoadRawData] = parse_inputs(DataPath,stdVar,ChNr,SigNr,varargin{:});

if LoadingBar == true
    h = waitbar(0,'Initializing waitbar...');
end

if LoadAllAvg == true
    Data=zeros(length(SigNr),(stdVar.TestCycNr),(stdVar.AvgSamplesNumber),(s2-s1+1));
    DataFormat={'SigNr','TestCycNr','AvgNr','Data'};    
else
    Data=zeros(length(SigNr),(stdVar.TestCycNr),(s2-s1+1));
    DataFormat={'SigNr','TestCycNr','Data'};
end

for SigNo=1:length(SigNr)
    fname=sprintf('%sCycADCgenCod%dCh%d.bin',DataPath,SigNr(SigNo),ChNr);
    Dfile = fopen(fname,'r'); 
    for CycNo=1:(stdVar.TestCycNr)  
        for AvgNo=1:(stdVar.AvgSamplesNumber)
            TT=double(fread(Dfile,AscanLength, '*uint16'));
            TT=TT(s1:s2); 
            if LoadRawData == false
                TT=(TT-mean(TT))/1024;
            end
            DataAvg(AvgNo,:)=TT;
        end

        if (stdVar.AvgSamplesNumber)>1
            MyAvgArr=AlignAll(DataAvg,(stdVar.AvgSamplesNumber),1);% Align to first
            MyAvg=mean(MyAvgArr);
        else
            MyAvg=DataAvg;
        end
        
        if LoadAllAvg == true
            Data(SigNo,CycNo,:,:)=DataAvg;
        else
            Data(SigNo,CycNo,:)=MyAvg;
        end

        if LoadingBar == true
            perc = 100-(((stdVar.TestCycNr)-CycNo)/(stdVar.TestCycNr)*100);
            waitbar(perc/100,h,sprintf('Loading Scan Data %2.2f%%',perc))
        end
    end
    fclose(Dfile);  
    if LoadingBar == true
        close(h);
    end
end

if length(SigNr) == 1
    z = size(Data);
    Data=reshape(Data,z(2:end));
    DataFormat(1)=[];
    if ((stdVar.TestCycNr) == 1) && (LoadAllAvg == true)
        z = size(Data);
        DataFormat(1)=[];
        Data=reshape(Data,z(2:end));
    end
elseif (stdVar.TestCycNr) == 1
    z = size(Data);
    z(2)=[];
	DataFormat(2)=[];
    Data=reshape(Data,z);
end



%--------------------------------------------------------------------------
function [LoadAllAvg,LoadingBar,AscanLength,s1,s2,LoadRawData] = parse_inputs(DataPath,stdVar,ChNr,SigNr,varargin)

% Validate inputs
validateattributes(DataPath,{'char'},{'nonempty'},'LoadCycleData','DataPath');
validateattributes(stdVar,{'struct'},{'nonempty'},'LoadCycleData','stdVar');
validateattributes(ChNr,{'numeric'},{'nonnan','integer','real','scalar','nonempty','positive','nonzero','<=',2},'LoadCycleData','ChNr');
validateattributes(SigNr,{'numeric'},{'nonnan','integer','real','vector','nonempty','positive','nonzero','<=',stdVar.GenCodeNo},'LoadCycleData','SigNr');

LoadAllAvg = false;
LoadingBar = false;
LoadRawData = false;
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
    if strfind(varargin{indx},'LoadRawData')
        LoadRawData = true;
        deleteIndx = [deleteIndx indx];
    end 
end
varargin(deleteIndx)=[];

AscanLength=(stdVar.Smax)-(stdVar.Smin);
s1=1;
s2=s1+AscanLength-1;
DefaultRange = [s1 s2];
p = inputParser;
addParameter(p,'LoadRange',DefaultRange);

parse(p,varargin{1:end});
validateattributes(p.Results.LoadRange,{'numeric'},{'row','numel',2,'nonnan','integer','real','vector','nonempty','positive','nonzero','<=',stdVar.Smax},'LoadCycleData','LoadRange');
validateattributes(p.Results.LoadRange(2),{'numeric'},{'nonnan','integer','real','nonempty','positive','nonzero','>',p.Results.LoadRange(1)},'LoadRange','s2');

s1 = p.Results.LoadRange(1);
s2 = p.Results.LoadRange(2);
