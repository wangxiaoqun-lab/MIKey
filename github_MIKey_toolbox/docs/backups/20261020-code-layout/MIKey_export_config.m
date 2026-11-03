function filename = MIKey_export_config(filename, input)
% Write all effective settings as one editable .m configuration function.
% Loading the file evaluates that user-owned MATLAB function.
cfg=MIKey_config(input);
if isstring(filename) && isscalar(filename),filename=char(filename);end
if ~ischar(filename) || ~isrow(filename) || isempty(filename)
    error('MIKey:ConfigExport','Specify one output .m filename.');
end
[~,~,extension]=fileparts(filename);
if isempty(extension),filename=[filename '.m'];end
file=java.io.File(filename);filename=char(file.getCanonicalPath());
[folder,name,extension]=fileparts(filename);
if ~strcmpi(extension,'.m') || ~isvarname(name)
    error('MIKey:ConfigExport','Use a valid MATLAB function filename ending in .m.');
end
reserved={'MIKey','MIKey_config','MIKey_defaults','MIKey_run','run_mikey', ...
    'MIKey_export_config','MIKey_load_config_function'};
if any(strcmpi(name,reserved))
    error('MIKey:ConfigExport','Do not replace a toolbox entry point with a configuration: %s',name);
end
if ~exist(folder,'dir'),error('MIKey:ConfigExport','Output folder does not exist: %s',folder);end
lines={['function cfg = ' name '()'], ...
    '% GUI-exported MIKey settings. Edit parameters in this file only.', ...
    '% Run with run_mikey(''/absolute/path/to/this_file.m'').', ...
    '% Run Step 1 alone, prepare masks manually, then change cfg.steps to 2:10.', ...
    '% Paths must refer to the server where processing will run.', ...
    'cfg = struct();'};
names=fieldnames(cfg);
for i=1:numel(names)
    lines{end+1}=['cfg.' names{i} ' = ' literal(cfg.(names{i})) ';']; %#ok<AGROW>
end
lines{end+1}='end';
% Prepare all literals before opening a file; atomically replace only on success.
temporary=[tempname(folder) '.m'];
cleanup=onCleanup(@()removeTemporary(temporary)); %#ok<NASGU>
fid=fopen(temporary,'w','n','UTF-8');
if fid<0,error('MIKey:ConfigExport','Cannot write configuration: %s',filename);end
closer=onCleanup(@()fclose(fid));
for i=1:numel(lines),fprintf(fid,'%s\n',lines{i});end
clear closer;
[ok,message]=movefile(temporary,filename,'f');
if ~ok,error('MIKey:ConfigExport','Cannot save configuration %s: %s',filename,message);end
end

function text = literal(value)
if ischar(value)
    if isrow(value) && all(double(value)>=32 & double(value)<=126)
        text=['''' strrep(value,'''','''''') ''''];
    elseif isempty(value) && isequal(size(value),[0 0])
        text='''''';
    else
        text=['reshape(char(' mat2str(double(value(:)')) '),' mat2str(size(value)) ')'];
    end
elseif isnumeric(value) || islogical(value)
    shape=size(value);flat=value;
    if ndims(value)>2,flat=reshape(value,1,[]);end
    if islogical(flat),text=['logical(' mat2str(double(flat)) ')'];
    else,text=mat2str(full(flat),17,'class');end
    if issparse(value),text=['sparse(' text ')'];end
    if ndims(value)>2,text=['reshape(' text ',' mat2str(shape) ')'];end
elseif isstring(value)
    if any(ismissing(value(:))),error('MIKey:ConfigExport','Missing strings cannot be exported; use explicit text.');end
    text=['reshape(string(' literal(cellstr(value(:)')) '),' mat2str(size(value)) ')'];
elseif iscell(value)
    parts=cell(1,numel(value));
    for i=1:numel(value),parts{i}=literal(value{i});end
    text=['reshape({' strjoin(parts,',') '},' mat2str(size(value)) ')'];
elseif isstruct(value)
    fields=fieldnames(value);elements=cell(1,max(1,numel(value)));
    for j=1:numel(elements)
        pairs=cell(1,2*numel(fields));
        for i=1:numel(fields)
            pairs{2*i-1}=literal(fields{i});
            if isempty(value),item=[];else,item=value(j).(fields{i});end
            pairs{2*i}=['{' literal(item) '}'];
        end
        elements{j}=['struct(' strjoin(pairs,',') ')'];
    end
    if isempty(value),text=['repmat(' elements{1} ',' mat2str(size(value)) ')'];
    else,text=['reshape([' strjoin(elements,',') '],' mat2str(size(value)) ')'];end
else
    error('MIKey:ConfigExport','Unsupported configuration value type: %s',class(value));
end
end

function removeTemporary(filename)
if exist(filename,'file'),delete(filename);end
end
