% RUN_ANALYSIS  Entry point for nitrogen shipping analysis.
%   Adds the shipping directory to the path and runs the main analysis.

this_dir = fileparts(mfilename('fullpath'));
addpath(this_dir);
addpath(fullfile(this_dir, 'src'));
addpath(fullfile(this_dir, 'report'));

run(fullfile(this_dir, 'nitrogen_shipping_analysis.m'));
