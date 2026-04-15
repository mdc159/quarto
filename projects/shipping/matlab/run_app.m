% run_app.m — Launch the nitrogen shipping explorer app
thisDir = fileparts(mfilename('fullpath'));
addpath(thisDir);
addpath(fullfile(thisDir, 'src'));
nitrogen_shipping_app();
