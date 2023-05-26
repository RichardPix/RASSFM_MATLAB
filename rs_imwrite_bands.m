function rs_imwrite_bands(varargin)
% rs_imwrite - Write an ENVI image with differnt bands with names (Copy Right - Zhe Zhu, Sept. 4th 2018)
% Examples
% rs_imwrite(image,'filename',info,n_names, fillv); 
% Input
%   image: image matrix
%   filename: File names
%   info: Image properties and cartographic information for ENVI or GeoTIFF file
%   n_names   : Band names
%   fillv: a self-defined fill value. % Added by Yongquan Zhao on February 09, 2022.

if nargin < 4
    fprintf('Failed! Less Than Three Variables! \n');
    return
elseif nargin == 4    
    % Create input variables
    image = varargin{1};
    fname = varargin{2};
    info = varargin{3};
    n_names = varargin{4};
    
    im_size=size(image);
    im_size(3)=size(image,3);
    
    % ENVI data format numbers
    d = [1 2 3 4 5 12];
    
    % Check user input
    if ~ischar(fname)
        error('fname should be a char string');
    end
    
    cl=class(image);
    switch cl
        case 'uint8'
            t = d(1);
        case 'int16'
            t = d(2);
        case 'int32'
            t = d(3);
        case 'single'
            t = d(4);
        case 'double'
            t = d(5);
        case 'uint16'
            t = d(6);
        otherwise
            error('Data type not recognized');
    end
    
    % update info
    info.samples = im_size(2);
    info.lines = im_size(1);
    info.bands = im_size(3);
    info.data_type = t;
    
    try multibandwrite(image,fname,info.interleave);
        fprintf('Write ENVI Images %s',fname);
        fprintf((' . '));
    catch
        fprintf('Images Failed! Not ENVI Variables! \n');
        return
    end
    
    % Write header file
    fprintf((' . '));
%     fid = fopen(strcat(fname,'.hdr'),'w');
    [filepath,name,~] = fileparts(fname); % exclude file extensions.
    fid = fopen(strcat(filepath, '\', name, '.hdr'),'r');
    
    fprintf(fid,'%s \n','ENVI');
    n_field = fieldnames(info);
    n_value = struct2cell(info);
    
    for i = 1:length(n_field)-1  % leave band names to be filled in the next step.
        n_field{i} = strrep(n_field{i},'_',' ');
        if ischar(n_value{i})
            fprintf(fid,'%s = %s \n',n_field{i},n_value{i});
        else
            fprintf(fid,'%s = %d \n',n_field{i},n_value{i});
        end
    end
    
    % band names    
    fprintf(fid,'band names = {');
    if ischar(n_names)
        fprintf(fid,'%s',n_names);
    else
        for i=1:length(n_names)
            if isstring(n_names(i)) % ischar(n_names(i))
                str_n = char(n_names(i));
            else
                str_n = num2str(n_names(i));
            end
            fprintf(fid,'%s',str_n);
            if i < length(n_names)
                fprintf(fid,',');
            end
        end
    end
    fprintf(fid,'}\n');
   
    fclose(fid);
    fprintf((' . \n'));
elseif nargin == 5    
    % Create input variables
    image = varargin{1};
    fname = varargin{2};
    info = varargin{3};    
    n_names = varargin{4};    
    fillv = varargin{5};
    
    im_size=size(image);
    im_size(3)=size(image,3);
    
    % ENVI data format numbers
    d = [1 2 3 4 5 12];
    
    % Check user input
    if ~ischar(fname)
        error('fname should be a char string');
    end
    
    cl=class(image);
    switch cl
        case 'uint8'
            t = d(1);
        case 'int16'
            t = d(2);
        case 'int32'
            t = d(3);
        case 'single'
            t = d(4);
        case 'double'
            t = d(5);
        case 'uint16'
            t = d(6);
        otherwise
            error('Data type not recognized');
    end
    
    % update info
    info.samples = im_size(2);
    info.lines = im_size(1);
    info.bands = im_size(3);
    info.data_type = t;
    
    % write image data.
    try multibandwrite(image,fname,info.interleave);
        fprintf('Write ENVI Images %s',fname);
        fprintf((' . '));
    catch
        fprintf('Images Failed! Not ENVI Variables! \n');
        return
    end
    
    % Write header file
    fprintf((' . '));
%     fid = fopen(strcat(fname,'.hdr'),'w');
    [filepath,name,~] = fileparts(fname); % exclude file extensions.
    fid = fopen(strcat(filepath, '\', name, '.hdr'),'w');
    
    
    fprintf(fid,'%s \n','ENVI');
    n_field = fieldnames(info);
    n_value = struct2cell(info);
    
    for i = 1:length(n_field)-1 % leave band names and fill value to be filled in the next step.
        n_field{i} = strrep(n_field{i},'_',' ');
        if ischar(n_value{i})
            fprintf(fid,'%s = %s \n',n_field{i},n_value{i});
        else
            fprintf(fid,'%s = %d \n',n_field{i},n_value{i});
        end
    end
    
    % band names
    fprintf(fid,'band names = {');
    if ischar(n_names)
        fprintf(fid,'%s',n_names);
    else
        for i=1:length(n_names)
            if iscell(n_names(i)) % isstring(n_names(i)) % ischar(n_names(i))
                str_n = char(n_names(i));
            else
                str_n = num2str(n_names(i));
            end
            fprintf(fid,'%s',str_n);
            if i < length(n_names)
                fprintf(fid,',');
            end
        end
    end
    fprintf(fid,'}\n');
    
    % fill value
    fprintf(fid,'%s = %d \n', 'data ignore value',fillv);
    
    fclose(fid);
    fprintf((' . \n'));
else
    fprintf('Failed! Too Many Variables! \n');
    return
end