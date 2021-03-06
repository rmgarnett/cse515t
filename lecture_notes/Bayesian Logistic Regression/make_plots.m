% plot colors (from http://colorbrewer2.org/)
colors = [ 31, 120, 180; ...
           51, 160,  44; ...
          227,  26,  28] / 255;

% location of tikz output
figures_directory = 'figures';

% range of t to plot
t = linspace(-5, 5, 1000);

% logistic function
sigma_l = @(t) (exp(t) ./ (1 + exp(t)));

% normal CDF, transform to match slope
sigma_n = @(t) (normcdf(sqrt(pi / 8) * t));

clf;
hold('off');
logistic_h = ...
    plot(t, sigma_l(t), ...
         'color', colors(1, :));

hold('on');
normcdf_h = ...
    plot(t, sigma_n(t), ...
         'color', colors(3, :));

legend([logistic_h, normcdf_h], ...
       'logistic', ...
       'normal \acro{CDF}', ...
       'location', 'northwest');
legend('boxoff');

xlabel('t');

set(gca, 'box', 'off');

% make tikz plot if possible
if (exist('matlab2tikz', 'file'))
  figure_name = 'sigmoids';
  matlab2tikz(sprintf('%s/%s.tex', figures_directory, figure_name), ...
              'height',       '\figureheight', ...
              'width',        '\figurewidth',  ...
              'parseStrings', false,           ...
              'showInfo',     false,           ...
              'extraCode',    sprintf('\\tikzsetnextfilename{%s}', figure_name));
end