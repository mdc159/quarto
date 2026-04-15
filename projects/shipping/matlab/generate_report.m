function generate_report(formats, output_dir)
%GENERATE_REPORT  Generate shipping analysis reports in multiple formats.
%   GENERATE_REPORT() generates all four formats (PDF, DOCX, HTML, PPTX)
%   in output/reports/.
%
%   GENERATE_REPORT(formats) generates only the specified formats.
%   formats is a cell array, e.g. {'pdf','docx','html-file','pptx'}.
%
%   GENERATE_REPORT(formats, output_dir) uses a custom output directory.

    if nargin < 1 || isempty(formats)
        formats = {'pdf', 'docx', 'html-file', 'pptx'};
    end
    if nargin < 2 || isempty(output_dir)
        output_dir = fullfile(fileparts(mfilename('fullpath')), 'output', 'reports');
    end
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end

    % Add all subdirectories to path
    this_dir = fileparts(mfilename('fullpath'));
    addpath(this_dir);
    addpath(fullfile(this_dir, 'src'));
    addpath(fullfile(this_dir, 'report'));

    % Generate all figures and run analysis
    fprintf('=== Generating figures and running analysis ===\n');
    [fig_dir, results] = report_figures(output_dir);
    fprintf('Figures saved to: %s\n\n', fig_dir);

    % Generate each format
    for i = 1:length(formats)
        fmt = formats{i};
        fprintf('=== Generating %s report ===\n', upper(fmt));
        t_start = tic;

        if strcmp(fmt, 'pptx')
            report_pptx(output_dir, fig_dir, results);
        else
            report_content(fmt, output_dir, fig_dir, results);
        end

        fprintf('  Done in %.1f s.\n\n', toc(t_start));
    end

    % Summary
    fprintf('=== Report Generation Complete ===\n');
    fprintf('Output directory: %s\n', output_dir);
    d = dir(fullfile(output_dir, 'shipping_failure*'));
    for i = 1:length(d)
        fprintf('  %s  (%d KB)\n', d(i).name, round(d(i).bytes/1024));
    end
end
