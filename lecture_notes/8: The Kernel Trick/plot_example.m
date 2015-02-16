% uses GPML toolkit (http://www.gaussianprocess.org/gpml/code/)

% predictable results
rng('default');

% plot colors (from http://colorbrewer2.org/)
colors = [ 31, 120, 180; ...
           51, 160,  44; ...
          227,  26,  28; ...
          166, 206, 227] / 255;

% where figure output should go
figures_directory = 'figures/';

n       = 10;  % number of points
sigma_n = 0.1; % noise scale
lambda  = 1;   % output scale
ell     = 1;   % length scale

% true function
f = @(x) sin(x);

% training points
x = randn(n, 1);
y = f(x) + sigma_n * randn(size(x));

% test points
x_star = linspace(-4, 4, 1000)';
f_star = f(x_star);

% parameters of K
theta = [log(ell); log(lambda)];

% K(X, X)
Kxx = covSEiso(theta, x);
% K(X, X_*)
Kxs = covSEiso(theta, x, x_star);
% K(X_*, K_*)
Kss = covSEiso(theta, x_star);

% posterior distribution for y*
posterior_mu = Kxs' / (Kxx + sigma_n^2 * eye(n)) * y;
posterior_K  = Kss - Kxs' / (Kxx + sigma_n^2 * eye(n)) * Kxs;

clf;
hold('off');
sigma_h = ...
    fill([x_star; flipud(x_star)], ...
         [posterior_mu - 2 * sqrt(diag(posterior_K));
          flipud(posterior_mu + 2 * sqrt(diag(posterior_K)))], ...
         colors(4, :), ...
         'edgecolor', 'none', ...
         'facealpha', 1);
hold('on');
mean_h = ...
    plot(x_star, posterior_mu, ...
         'color', colors(1, :));
true_h = ...
    plot(x_star, f_star, ...
         'color', colors(3, :));
observation_h = ...
    plot(x, y, 'k.');

set(gca, 'box', 'off');

xlabel('$x$');
ylabel('$y$');

legend([observation_h, true_h, mean_h, sigma_h], ...
       'observations $\data$', ...
       'true function $f(x)$', ...
       '$\mu_{\vec{y}_\ast\given\data}$', ...
       '$\pm 2\sqrt{\diag K_{\vec{y}_\ast\given\data}}$', ...
       'location', 'southeast');
legend('boxoff');

% make tikz plot if possible
if (exist('matlab2tikz', 'file'))
  figure_name = 'kernel_example';
  matlab2tikz(sprintf('%s/%s.tex', figures_directory, figure_name), ...
              'height',       '\figureheight', ...
              'width',        '\figurewidth',  ...
              'parseStrings', false,           ...
              'showInfo',     false,           ...
              'extraAxisOptions', 'reverse legend', ...
              'extraCode',    sprintf('\\tikzsetnextfilename{%s}', figure_name));
end