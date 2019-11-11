function  stdVar = LoadstdVar(DataPath)
% [stdVar] = LoadstdVar(DataPath)
% 
% LoadstdVar - loads experiment variables in structure 
% DataPath - path to Data;

cond = nargin <= 2;
if ~cond
    coder.internal.assert(cond,'MATLAB:narginchk:tooManyInputs');
end

% Validate inputs
validateattributes(DataPath,{'char'},{'nonempty'},'LoadCycleData','DataPath');

fileID = fopen([DataPath 'standard.var']);
lines = textscan(fileID, '%s','delimiter', '\n');
for indx=1:length(lines{1})
    % get string
    Str=char(lines{1}(indx));
    
    % find separation symbol ' - '
    separation = ' - ';    
    k = strfind(Str,separation);
    
    % get value and name string
    value = Str(1:k-1);
    field = Str(k+length(separation):end);
    
    % check value if number convert if string leave it
	[num, status] = str2num(value);
    if status == 1
        value = num;
    end
    
    % correct field name, remove bad symblos: '-',' '
    k=strfind(field, '-');
    field(k)=[];
    k=strfind(field, ' ');
    field(k)=[];
    
    % make variable in structure
    stdVar.(sprintf('%s',field)) = value;  
end

end