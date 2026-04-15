function verify_report(output_dir)
%VERIFY_REPORT  Verify generated reports exist and pass structural checks.
%   VERIFY_REPORT(output_dir) checks all expected output files, validates
%   file sizes, and extracts figure dimensions from the PDF for visual
%   review. Generates a verification summary as a text file.
%
%   This function performs automated checks. Visual verification of layout
%   and formatting should be done by opening the HTML report in a browser
%   and reviewing screenshots.

    if nargin < 1
        output_dir = fullfile(fileparts(mfilename('fullpath')), 'reports');
    end

    fprintf('=== Report Verification ===\n\n');

    issues = {};

    %% 1. Check all expected output files exist
    expected_files = {
        'shipping_failure_analysis.pdf'
        'shipping_failure_analysis.docx'
        'shipping_failure_analysis.html'
        'shipping_failure_analysis.pptx'
    };

    fprintf('--- File Existence ---\n');
    for i = 1:length(expected_files)
        fpath = fullfile(output_dir, expected_files{i});
        if isfile(fpath)
            d = dir(fpath);
            fprintf('  [PASS] %-45s  %6d KB\n', expected_files{i}, round(d.bytes/1024));
            if d.bytes < 100*1024
                issues{end+1} = sprintf('%s is suspiciously small (%d KB)', expected_files{i}, round(d.bytes/1024)); %#ok<AGROW>
            end
        else
            fprintf('  [FAIL] %-45s  MISSING\n', expected_files{i});
            issues{end+1} = sprintf('%s is missing', expected_files{i}); %#ok<AGROW>
        end
    end

    %% 2. Check all expected figure PNGs exist
    fig_dir = fullfile(output_dir, 'figures');
    expected_figs = {
        'fig_baseline_cycle.png'
        'fig_failure_cycle.png'
        'fig_three_regimes.png'
        'fig_min_dp_sweep.png'
        'fig_case_comparison.png'
        'fig_pcrack_sensitivity.png'
        'fig_failure_boundary.png'
        'fig_failure_surface.png'
    };

    fprintf('\n--- Figure PNGs ---\n');
    for i = 1:length(expected_figs)
        fpath = fullfile(fig_dir, expected_figs{i});
        if isfile(fpath)
            info = imfinfo(fpath);
            aspect = info.Width / info.Height;
            fprintf('  [PASS] %-35s  %4dx%4d  aspect=%.2f\n', ...
                expected_figs{i}, info.Width, info.Height, aspect);

            % Flag figures with extreme aspect ratios
            if aspect > 3.0
                issues{end+1} = sprintf('%s has extreme aspect ratio %.2f (may look squished in report)', ...
                    expected_figs{i}, aspect); %#ok<AGROW>
            end
            if info.Width < 1000 || info.Height < 500
                issues{end+1} = sprintf('%s is low resolution (%dx%d)', ...
                    expected_figs{i}, info.Width, info.Height); %#ok<AGROW>
            end
        else
            fprintf('  [FAIL] %-35s  MISSING\n', expected_figs{i});
            issues{end+1} = sprintf('%s is missing', expected_figs{i}); %#ok<AGROW>
        end
    end

    %% 3. Check figure sizing in PDF context
    fprintf('\n--- Figure Sizing (at 6.5 in page width) ---\n');
    for i = 1:length(expected_figs)
        fpath = fullfile(fig_dir, expected_figs{i});
        if isfile(fpath)
            info = imfinfo(fpath);
            aspect = info.Width / info.Height;
            page_w = 6.5;
            rendered_h = page_w / aspect;
            status = 'OK';
            if rendered_h > 8.5
                status = 'OVERFLOW - taller than page!';
                issues{end+1} = sprintf('%s renders at %.1f in tall — overflows page', ...
                    expected_figs{i}, rendered_h); %#ok<AGROW>
            elseif rendered_h > 6.0
                status = 'WARNING - very tall, may push content to next page';
            elseif rendered_h < 1.5
                status = 'WARNING - very short, may be hard to read';
            end
            fprintf('  %-35s  %.1f x %.1f in  %s\n', ...
                expected_figs{i}, page_w, rendered_h, status);
        end
    end

    %% 4. Generate HTML verification page for browser review
    html_verify_path = fullfile(output_dir, 'verification_review.html');
    fid = fopen(html_verify_path, 'w');
    fprintf(fid, '<!DOCTYPE html>\n<html><head>\n');
    fprintf(fid, '<title>Report Verification Review</title>\n');
    fprintf(fid, '<style>\n');
    fprintf(fid, 'body { font-family: Arial, sans-serif; max-width: 900px; margin: 0 auto; padding: 20px; }\n');
    fprintf(fid, 'img { max-width: 100%%; border: 1px solid #ccc; margin: 10px 0; }\n');
    fprintf(fid, '.fig-container { margin: 20px 0; padding: 10px; background: #f9f9f9; }\n');
    fprintf(fid, '.fig-info { color: #666; font-size: 0.9em; }\n');
    fprintf(fid, 'h2 { border-bottom: 2px solid #333; padding-bottom: 5px; }\n');
    fprintf(fid, '.issue { color: #c00; font-weight: bold; }\n');
    fprintf(fid, '.pass { color: #080; }\n');
    fprintf(fid, '</style>\n</head><body>\n');
    fprintf(fid, '<h1>Report Verification Review</h1>\n');
    fprintf(fid, '<p>Generated: %s</p>\n', datestr(now, 'yyyy-mm-dd HH:MM:SS')); %#ok<TNOW1,DATST>

    % Issues summary
    if isempty(issues)
        fprintf(fid, '<p class="pass">All automated checks passed.</p>\n');
    else
        fprintf(fid, '<h2>Issues Found</h2>\n<ul>\n');
        for i = 1:length(issues)
            fprintf(fid, '<li class="issue">%s</li>\n', issues{i});
        end
        fprintf(fid, '</ul>\n');
    end

    % Show each figure at rendered size
    fprintf(fid, '<h2>Figure Review (at report page width)</h2>\n');
    fprintf(fid, '<p>Each figure is shown at 650px width (simulating 6.5 in page width at 100 dpi). Check for:</p>\n');
    fprintf(fid, '<ul>\n');
    fprintf(fid, '<li>Text readability (axis labels, legends, annotations)</li>\n');
    fprintf(fid, '<li>Proper aspect ratio (not squished or stretched)</li>\n');
    fprintf(fid, '<li>Color contrast and line visibility</li>\n');
    fprintf(fid, '<li>Overall layout balance</li>\n');
    fprintf(fid, '</ul>\n');

    for i = 1:length(expected_figs)
        fpath = fullfile(fig_dir, expected_figs{i});
        if isfile(fpath)
            info = imfinfo(fpath);
            aspect = info.Width / info.Height;
            rendered_h = 6.5 / aspect;
            fprintf(fid, '<div class="fig-container">\n');
            fprintf(fid, '<h3>%d. %s</h3>\n', i, strrep(expected_figs{i}, '_', ' '));
            fprintf(fid, '<p class="fig-info">%dx%d px | aspect %.2f | renders at 6.5 x %.1f in</p>\n', ...
                info.Width, info.Height, aspect, rendered_h);
            fprintf(fid, '<img src="figures/%s" width="650">\n', expected_figs{i});
            fprintf(fid, '</div>\n');
        end
    end

    % Links to generated reports
    fprintf(fid, '<h2>Generated Reports</h2>\n<ul>\n');
    for i = 1:length(expected_files)
        if isfile(fullfile(output_dir, expected_files{i}))
            fprintf(fid, '<li><a href="%s">%s</a></li>\n', expected_files{i}, expected_files{i});
        end
    end
    fprintf(fid, '</ul>\n');

    fprintf(fid, '</body></html>\n');
    fclose(fid);

    %% 5. Summary
    fprintf('\n--- Summary ---\n');
    if isempty(issues)
        fprintf('  All automated checks PASSED.\n');
    else
        fprintf('  %d issues found:\n', length(issues));
        for i = 1:length(issues)
            fprintf('    - %s\n', issues{i});
        end
    end
    fprintf('\n  Visual verification page: %s\n', html_verify_path);
    fprintf('  Open in browser to review figure layout at report scale.\n');

    % Write verification result to a marker file
    marker_path = fullfile(output_dir, '.verification_done');
    fid = fopen(marker_path, 'w');
    fprintf(fid, 'verified_at=%s\n', datestr(now, 'yyyy-mm-ddTHH:MM:SS')); %#ok<TNOW1,DATST>
    fprintf(fid, 'issues=%d\n', length(issues));
    fprintf(fid, 'status=%s\n', conditional(isempty(issues), 'PASS', 'ISSUES'));
    fclose(fid);
end

function s = conditional(cond, if_true, if_false)
    if cond, s = if_true; else, s = if_false; end
end
