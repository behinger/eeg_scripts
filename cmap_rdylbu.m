function colormap = cmap_rdylbu(ncol)
if nargin == 0
    ncol = 64;
end
if ncol < 11
    
    cbrew_list{3} = [
        252   141    89;
        255   255   191;
        145   191   219];
    cbrew_list{4} = [
        215    25    28;
        253   174    97;
        171   217   233;
        44   123   182;
        ];
    cbrew_list{5} = [
        215    25    28;
        253   174    97;
        255   255   191;
        171   217   233;
        44   123   182];
    cbrew_list{6} = [
        215    48    39;
        252   141    89;
        254   224   144;
        224   243   248;
        145   191   219;
        69   117   180];
    cbrew_list{7} = [
        215    48    39;
        252   141    89;
        254   224   144;
        255   255   191;
        224   243   248;
        145   191   219;
        69   117   180];
    cbrew_list{8} = [
        215    48    39;
        244   109    67;
        253   174    97;
        254   224   144;
        224   243   248;
        171   217   233;
        116   173   209;
        69   117   180];
    cbrew_list{9} = [
        215    48    39;
        244   109    67;
        253   174    97;
        254   224   144;
        255   255   191;
        224   243   248;
        171   217   233;
        116   173   209;
        69   117   180];
    cbrew_list{10} = [
        165     0    38;
        215    48    39;
        244   109    67;
        253   174    97;
        254   224   144;
        224   243   248;
        171   217   233;
        116   173   209;
        69   117   180;
        49    54   149;
        ];
    colormap = cbrew_list{ncol};
else
    cbrew_init=[
        165     0    38;
        215    48    39;
        244   109    67;
        253   174    97;
        254   224   144;
        255   255   191;
        224   243   248;
        171   217   233;
        116   173   209;
        69   117   180;
        49    54   149];
    
    colormap=local_interpolate_cbrewer(cbrew_init, 'cubic', ncol);
    
end
colormap=colormap./255;
% invert it
colormap = colormap(end:-1:1,:);

end

function [interp_cmap]=local_interpolate_cbrewer(cbrew_init, interp_method, ncolors)
%
% INTERPOLATE_CBREWER - interpolate a colorbrewer map to ncolors levels
%
% INPUT:
%   - cbrew_init: the initial colormap with format N*3
%   - interp_method: interpolation method, which can be the following:
%               'nearest' - nearest neighbor interpolation
%               'linear'  - bilinear interpolation
%               'spline'  - spline interpolation
%               'cubic'   - bicubic interpolation as long as the data is
%                           uniformly spaced, otherwise the same as 'spline'
%   - ncolors=desired number of colors
%
% Author: Charles Robert
% email: tannoudji@hotmail.com
% Date: 14.10.2011


% just to make sure, in case someone puts in a decimal
ncolors=round(ncolors);

% How many data points of the colormap available
nmax=size(cbrew_init,1);

% create the associated X axis (using round to get rid of decimals)
a=(ncolors-1)./(nmax-1);
X=(round([0 a:a:(ncolors-1)]));
X2=0:ncolors-1;

z=interp1(X,cbrew_init(:,1),X2,interp_method);
z2=interp1(X,cbrew_init(:,2),X2,interp_method);
z3=interp1(X,cbrew_init(:,3),X2, interp_method);
interp_cmap=round([z' z2' z3']);

end