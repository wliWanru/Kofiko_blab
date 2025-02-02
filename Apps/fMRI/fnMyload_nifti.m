function hdr = fnMyload_nifti(niftifile,hdronly,NumFrames)
% hdr = load_nifti(niftifile,hdronly)
%
% Loads nifti header and volume. The volume is stored
% in hdr.vol. Columns and rows are not swapped.
%
% Handles compressed nifti (nii.gz) by issuing a unix command to
% uncompress the file to a temporary file, which is then deleted.
%
% Dimensions are in mm and msec
% hdr.pixdim(1) = physical size of first dim (eg, 3.125 mm or 2000 ms)
% hdr.pixdim(2) = ...
%
% The sform and qform matrices are stored in hdr.sform and hdr.qform.
%
% hdr.vox2ras is the vox2ras matrix based on sform (if valid), then
% qform.
%
% Handles data structures with more than 32k cols by looking for
% hdr.dim(2) = -1 in which case ncols = hdr.glmin. This is FreeSurfer
% specific, for handling surfaces. When the total number of spatial
% voxels equals 163842, then the volume is reshaped to
% 163842x1x1xnframes. This is for handling the 7th order icosahedron
% used by FS group analysis.
%
% See also: load_nifti_hdr.m
%


%
% load_nifti.m
%
% Original Author: Doug Greve
% CVS Revision Info:
%    $Author: greve $
%    $Date: 2010/07/01 17:32:42 $
%    $Revision: 1.15.2.1 $
%
% Copyright (C) 2002-2007,
% The General Hospital Corporation (Boston, MA).
% All rights reserved.
%
% Distribution, usage and copying of this software is covered under the
% terms found in the License Agreement file named 'COPYING' found in the
% FreeSurfer source code root directory, and duplicated here:
% https://surfer.nmr.mgh.harvard.edu/fswiki/FreeSurferOpenSourceLicense
%
% General inquiries: freesurfer@nmr.mgh.harvard.edu
% Bug reports: analysis-bugs@nmr.mgh.harvard.edu
%

hdr = [];

if(nargin < 1 | nargin > 3)
    fprintf('hdr = load_nifti(niftifile,<hdronly>,NumFrames)\n');
    return;
end

if(~exist('hdronly','var')) hdronly = []; end
if(~exist('NumFrames','var')) NumFrames =0; end


if(isempty(hdronly)) hdronly = 0; end

% unzip if it is compressed
ext = niftifile((strlen(niftifile)-2):strlen(niftifile));
if(strcmpi(ext,'.gz'))
    % Need to create unique file name (harder than it looks)
    rand('state', sum(100*clock));
    gzipped =  round(rand(1)*10000000 + ...
        sum(int16(niftifile))) + round(cputime);
    ind = findstr(niftifile, '.');
    new_niftifile = sprintf('/tmp/tmp%d.nii', gzipped);
    %fprintf('Uncompressing %s to %s\n',niftifile,new_niftifile);
    if(strcmp(computer,'MAC') || strcmp(computer,'MACI') || ismac)
        unix(sprintf('gunzip -c %s > %s', niftifile, new_niftifile));
    else
        unix(sprintf('zcat %s > %s', niftifile, new_niftifile)) ;
    end
    niftifile = new_niftifile ;
else
    gzipped = -1 ;
end

hdr = load_nifti_hdr(niftifile);
if(isempty(hdr))
    if(gzipped >=0) unix(sprintf('rm %s', niftifile)); end
    return;
end

% Check for ico7
nspatial = prod(hdr.dim(2:4));
IsIco7 = 0;
if(nspatial == 163842) IsIco7 = 1; end

% If only header is desired, return now
if(hdronly)
    if(gzipped >=0) unix(sprintf('rm %s', niftifile)); end
    if(IsIco7)
        % Reshape
        hdr.dim(2) = 163842;
        hdr.dim(3) = 1;
        hdr.dim(4) = 1;
    end
    return;
end

% Get total number of voxels
dim = hdr.dim(2:end);
ind0 = find(dim==0);
dim(ind0) = 1;
nvoxels = prod(dim);

% Open to read the pixel data
fp = fopen(niftifile,'r',hdr.endian);

% Get past the hNumBytestoRead = eader
fseek(fp,round(hdr.vox_offset),'bof');
if NumFrames == 0
    switch(hdr.datatype)
        % Note: 'char' seems to work upto matlab 7.1, but 'uchar' needed
        % for 7.2 and higher.
        case   2, [hdr.vol nitemsread] = fread(fp,inf,'uchar');
        case   4, [hdr.vol nitemsread] = fread(fp,inf,'short');
        case   8, [hdr.vol nitemsread] = fread(fp,inf,'int');
        case  16, [hdr.vol nitemsread] = fread(fp,inf,'float');
        case  64, [hdr.vol nitemsread] = fread(fp,inf,'double');
        case 512, [hdr.vol nitemsread] = fread(fp,inf,'ushort');
        case 768, [hdr.vol nitemsread] = fread(fp,inf,'uint');
        otherwise,
            fprintf('ERROR: data type %d not supported',hdr.datatype);
            hdr = [];
            return;
    end
    
    fclose(fp);
    if(gzipped >=0)
        %fprintf('Deleting temporary uncompressed file %s\n',niftifile);
        unix(sprintf('rm %s', niftifile));
    end
    
    % Check that that many voxels were read in
    if(nitemsread ~= nvoxels)
        fprintf('ERROR: %s, read in %d voxels, expected %d\n',...
            niftifile,nitemsread,nvoxels);
        hdr = [];
        return;
    end
    
    if(IsIco7)
        fprintf('load_nifti: ico7 reshaping\n');
        hdr.dim(2) = 163842;
        hdr.dim(3) = 1;
        hdr.dim(4) = 1;
        dim = hdr.dim(2:end);
    end
    
    hdr.vol = reshape(hdr.vol, dim');
    if(hdr.scl_slope ~= 0)
        fprintf('Rescaling NIFTI: slope = %g, intercept = %g\n',...
            hdr.scl_slope,hdr.scl_inter);
        %fprintf('    Good luck, this has never been tested ... \n');
        hdr.vol = hdr.vol * hdr.scl_slope  + hdr.scl_inter;
    end
else
    fprintf('Reading only %d first frames !!!\n',NumFrames);
    iNewNumFrames = min(NumFrames,dim(4));
    NumVoxelsToRead =nspatial*iNewNumFrames;
    
    switch(hdr.datatype)
        % Note: 'char' seems to work upto matlab 7.1, but 'uchar' needed
        % for 7.2 and higher.
        case   2, [hdr.vol nitemsread] = fread(fp,NumVoxelsToRead,'uchar');
        case   4, [hdr.vol nitemsread] = fread(fp,NumVoxelsToRead,'short');
        case   8, [hdr.vol nitemsread] = fread(fp,NumVoxelsToRead,'int');
        case  16, [hdr.vol nitemsread] = fread(fp,NumVoxelsToRead,'float');
        case  64, [hdr.vol nitemsread] = fread(fp,NumVoxelsToRead,'double');
        case 512, [hdr.vol nitemsread] = fread(fp,NumVoxelsToRead,'ushort');
        case 768, [hdr.vol nitemsread] = fread(fp,NumVoxelsToRead,'uint');
        otherwise,
            fprintf('ERROR: data type %d not supported',hdr.datatype);
            hdr = [];
            return;
    end
    
    fclose(fp);
    if(gzipped >=0)
        %fprintf('Deleting temporary uncompressed file %s\n',niftifile);
        unix(sprintf('rm %s', niftifile));
    end
 
    if(IsIco7)
        fprintf('load_nifti: ico7 reshaping\n');
        hdr.dim(2) = 163842;
        hdr.dim(3) = 1;
        hdr.dim(4) = 1;
        dim = hdr.dim(2:end);
    end
    dim(4) = iNewNumFrames;
    hdr.vol = reshape(hdr.vol, dim');
    if(hdr.scl_slope ~= 0)
        fprintf('Rescaling NIFTI: slope = %g, intercept = %g\n',...
            hdr.scl_slope,hdr.scl_inter);
        %fprintf('    Good luck, this has never been tested ... \n');
        hdr.vol = hdr.vol * hdr.scl_slope  + hdr.scl_inter;
    end
end

return;





