% plot colors (from http://colorbrewer2.org/)
colors = [ 31, 120, 180; ...
           51, 160,  44; ...
           20,  20,  20] / 255;

% location of tikz output
figures_directory = 'figures';

x = linspace(-4, 4, 5e2);

clf;

hold('off');
h_01 = plot(x, normpdf(x, 0, 1), ...
            'color', colors(1, :));
hold('on');
h_105 = plot(x, normpdf(x, 1, 0.5), ...
             'color', colors(2, :));
h_02 = plot(x, normpdf(x, 0, 2), ...
            'color', colors(3, :));

legend([h_01, h_105, h_02], ...
       '$\mu = 0$, $\sigma = 1$', ...
       '$\mu = 1$, $\sigma = \nicefrac{1}{2}$', ...
       '$\mu = 0$, $\sigma = 2$', ...
       'location', 'northwest');
legend('boxoff');

xlabel('$x$');

set(gca, 'box', 'off');

% make tikz plot if possible
if (exist('matlab2tikz', 'file'))
  figure_name = '1d_gaussian_pdfs';
  matlab2tikz(sprintf('%s/%s.tex', figures_directory, figure_name), ...
              'height',       '\figureheight', ...
              'width',        '\figurewidth',  ...
              'parseStrings', false,           ...
              'showInfo',     false,           ...
              'extraCode',    sprintf('\\tikzsetnextfilename{%s}', figure_name));
end

% mean of 2d Gaussians
mu = [0, 0];

% covariance of 2d Gaussians
Sigmas = zeros(2, 2, 3);
Sigmas(:, :, 1) = [1, 0; 0 1];
Sigmas(:, :, 2) = [1, 0.5; 0.5 1];
Sigmas(:, :, 3) = [1, -1; -1 3];

% grid of points for output
[xx, yy] = meshgrid(x, x);
zz = zeros(size(xx));

for i = 1:size(Sigmas, 3)

  % evaluate PDF
  zz(:) = mvnpdf([xx(:), yy(:)], mu, Sigmas(:, :, i));

  clf;

  hold('off');
  contourf(xx, yy, zz);

  colormap(pmkmp(256, 'linearl'));

  axis('square');
  set(gca, 'box', 'off');

  xlabel('$x_1$');
  ylabel('$x_2$');

  % make tikz plot if possible
  if (exist('matlab2tikz', 'file'))
    figure_name = sprintf('2d_gaussian_pdf_%i', i);
    matlab2tikz(sprintf('%s/%s.tex', figures_directory, figure_name), ...
                'height',       '\smallsquarefigureheight', ...
                'width',        '\smallsquarefigurewidth',  ...
                'parseStrings', false,                ...
                'showInfo',     false,                ...
                'extraCode',    sprintf('\\tikzsetnextfilename{%s}', figure_name));
  end
end

% replot last example larger
if (exist('matlab2tikz', 'file'))
  figure_name = sprintf('2d_gaussian_pdf_%i_large', i);
  matlab2tikz(sprintf('%s/%s.tex', figures_directory, figure_name), ...
              'height',       '\squarefigureheight', ...
              'width',        '\squarefigurewidth',  ...
              'parseStrings', false,                ...
              'showInfo',     false,                ...
              'extraCode',    sprintf('\\tikzsetnextfilename{%s}', figure_name));
end

% plot p(x_1 | x_2 = 2) marginal for last example
x2_observation = 2;

hold('on');
plot(x, x2_observation * ones(size(x)), 'w:');

if (exist('matlab2tikz', 'file'))
  figure_name = '2d_gaussian_pdf_conditional';
  matlab2tikz(sprintf('%s/%s.tex', figures_directory, figure_name), ...
              'height',       '\squarefigureheight', ...
              'width',        '\squarefigurewidth',  ...
              'parseStrings', false,                ...
              'showInfo',     false,                ...
              'extraCode',    sprintf('\\tikzsetnextfilename{%s}', figure_name));
end

% compute conditional mean and standard deviation
new_mu = mu(1) + ...
         Sigmas(1, 2, end) * (x2_observation - mu(2)) / Sigmas(2, 2, end);

new_sigma = sqrt(Sigmas(1, 1, end) - ...
                 Sigmas(1, 2, end)^2 / Sigmas(2, 2, end));

clf;

hold('off');
conditional_h = ...
    plot(x, normpdf(x, new_mu, new_sigma), ...
         'color', colors(2, :));

hold('on');
marginal_h = ...
    plot(x, normpdf(x, mu(1), sqrt(Sigmas(1, 1, end))), ...
         'color', colors(1, :));

xlabel('$x_1$');

legend([conditional_h, marginal_h], ...
       sprintf('$p(x_1 \\given x_2 = %g)$', x2_observation), ...
       '$p(x_1)$');
legend('boxoff');

set(gca, 'box', 'off');

ylim([0, 0.6]);

if (exist('matlab2tikz', 'file'))
  figure_name = '2d_conditional_pdf';
  matlab2tikz(sprintf('%s/%s.tex', figures_directory, figure_name), ...
              'height',       '\smallfigureheight', ...
              'width',        '\smallfigurewidth',  ...
              'parseStrings', false,                ...
              'showInfo',     false,                ...
              'extraCode',    sprintf('\\tikzsetnextfilename{%s}', figure_name));
end

% plot p(x_1) marginal for last example
clf;

marginal_h = ...
    plot(x, normpdf(x, mu(1), sqrt(Sigmas(1, 1, end))), ...
         'color', colors(1, :));

legend(marginal_h, '$p(x_1)$');
legend('boxoff');

xlabel('$x_1$');

set(gca, 'box', 'off');

% make tikz plot if possible
if (exist('matlab2tikz', 'file'))
  figure_name = '2d_marginal_pdf';
  matlab2tikz(sprintf('%s/%s.tex', figures_directory, figure_name), ...
              'height',       '\smallfigureheight', ...
              'width',        '\smallfigurewidth',  ...
              'parseStrings', false,                ...
              'showInfo',     false,                ...
              'extraCode',    sprintf('\\tikzsetnextfilename{%s}', figure_name));
end

% plot affine transformation for last example

A = [0.2, -0.6; 0.5, 0.3];
b = [1, -1];

new_mu = mu * A + b;
new_Sigma = A * Sigmas(:, :, end) * A';

% evaluate PDF
zz(:) = mvnpdf([xx(:), yy(:)], new_mu, new_Sigma);

clf;

hold('off');
contourf(xx, yy, zz);

colormap(pmkmp(256, 'linearl'));

axis('square');
set(gca, 'box', 'off');

xlabel('$x_1$');
ylabel('$x_2$');

% make tikz plot if possible
if (exist('matlab2tikz', 'file'))
  figure_name = '2d_transformed_pdf';
  matlab2tikz(sprintf('%s/%s.tex', figures_directory, figure_name), ...
              'height',       '\squarefigureheight', ...
              'width',        '\squarefigurewidth',  ...
              'parseStrings', false,                ...
              'showInfo',     false,                ...
              'extraCode',    sprintf('\\tikzsetnextfilename{%s}', figure_name));
end
