% uses GPML toolkit (http://www.gaussianprocess.org/gpml/code/)

% predictable results
rng(31415);

% plot colors (from http://colorbrewer2.org/)
colors = [ 31, 120, 180; ...
           51, 160,  44; ...
          227,  26,  28; ...
          166, 206, 227] / 255;

sample_colors = ...
    [252, 146, 114; ...
     251, 106,  74; ...
     239,  59,  44; ...
     203,  24,  29; ...
     165,  15,  21] / 255;

% where figure output should go
figures_directory = 'figures/';

n_star      = 1000; % number of test points
sigma_n     = 0.1; % noise scale
num_samples = 3; % number of GP samples to take

% parameters of K
lambda      = 1;   % output scale
ell         = 1;   % length scale

theta.cov = [log(ell); log(lambda)];

x_star = linspace(0, 10, n_star)';

prior_mu = zeros(n_star, 1);
prior_K  = covSEiso(theta.cov, x_star);

% condition example from lecture 9 on \int f(x) = 5.
ell = 5;

% covariance function for integrating
f = @(x, y) exp(-(x - y).^2 / 2);

% prior mean of integral
L_mu = 0;

% prior variance of integral
L2_K = integral2(f, min(x_star), max(x_star), min(x_star), max(x_star));

% evaluate L[K(x, .)] = \int_{min(x_star)}^{max(x_star)} K(x, y) dy.
L_K = @(x) (sqrt(2 * pi) * ...
            (normcdf(max(x_star), x) - normcdf(min(x_star), x)));

L_K_x = zeros(n_star, 1);
for i = 1:n_star
  L_K_x(i) = L_K(x_star(i));
end

% posterior distribution
posterior_mu = ...
    prior_mu + L_K_x / L2_K * (ell - L_mu);

posterior_K = ...
    prior_K - L_K_x * L_K_x' / L2_K;

% fix conditioning problems
posterior_K = (posterior_K + posterior_K)' / 2 + 1e-6 * eye(n_star);

samples = mvnrnd(posterior_mu, posterior_K, num_samples)';

clf;
hold('off');
for i = 1:num_samples
  samples_h = ...
      plot(x_star, samples(:, i), ...
           'color', sample_colors(i, :));
  hold('on');
end
sigma_h = ...
    fill([x_star; flipud(x_star)], ...
         [posterior_mu - 2 * sqrt(diag(posterior_K));
          flipud(posterior_mu + 2 * sqrt(diag(posterior_K)))], ...
         colors(4, :), ...
         'edgecolor', 'none', ...
         'facealpha', 0.3);
mean_h = ...
    plot(x_star, posterior_mu, ...
         'color', colors(1, :));

ylim([-3, 3]);

set(gca, 'box', 'off');

xlabel('$x$');

legend([mean_h, sigma_h, samples_h], ...
       '$\mu(x)$',              ...
       '$\pm 2\sigma$', ...
       'samples',               ...
       'location', 'southeast');
legend('boxoff');

% make tikz plot if possible
if (exist('matlab2tikz', 'file'))
  figure_name = 'integral_posterior';
  matlab2tikz(sprintf('%s/%s.tex', figures_directory, figure_name), ...
              'height',       '\figureheight', ...
              'width',        '\figurewidth',  ...
              'parseStrings', false,           ...
              'showInfo',     false,           ...
              'extraAxisOptions', 'legend style={legend columns=-1, draw=none}, reverse legend', ...
              'extraCode',    sprintf('\\tikzsetnextfilename{%s}', figure_name));
end
