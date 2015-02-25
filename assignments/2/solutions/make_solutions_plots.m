% problem 1

% make results repeatable
rng('default');

% from colorbrewer2.org
plot_colors = ...
    [166, 206, 227; ...
      51, 160,  44;...
      20,  20,  20; ...
      31, 120, 180; ...
     178, 223, 138] / 255;

% where to save tikz figures
figures_directory = 'figures/';

n      = 10000;               % number of samples
ds     = [1, 5, 10, 50, 100]; % dimensions
num_xs = 1000;                % size of grid to estimate density

num_ds = numel(ds);

xs = linspace(0, 15, num_xs); % inputs for density estimation
fs = zeros(num_xs, num_ds);

for i = 1:num_ds
  % draw samples
  x = randn(n, ds(i));
  y = sqrt(sum(x.^2, 2));

  fs(:, i) = ksdensity(y, xs)';
end

clf;

plot_hs = zeros(num_ds, 1);
legend_strings = cell(num_ds, 1);

hold('off');
for i = 1:num_ds
  plot_hs(i) = ...
      plot(xs, fs(:, i), ...
           'color', plot_colors(i, :));

  hold('on');

  legend_strings{i} = sprintf('$d = %i$', ds(i));
end

legend(plot_hs, ...
       legend_strings{:}, ...
       'location', 'northeast');
legend('boxoff');

xlabel('$y$');
ylabel('$p(y \given d)$');

set(gca, 'box', 'off');

% make tikz plot if possible
if (exist('matlab2tikz', 'file'))
  figure_name = 'problem_1';
  matlab2tikz(sprintf('%s/%s.tex', figures_directory, figure_name), ...
              'height',       '\figureheight', ...
              'width',        '\figurewidth',  ...
              'parseStrings', false,           ...
              'showInfo',     false,           ...
              'extraAxisOptions', 'legend style={draw=none}', ...
              'extraCode',    sprintf('\\tikzsetnextfilename{%s}', figure_name));
end

% problem 2

% data
x = [-2.26, -1.31, -0.43, 0.32, 0.34, 0.54, 0.86, 1.83, 2.77, 3.58]';
y = [1.03, 0.70, -0.68, -1.36, -1.74, -1.01, 0.24, 1.55, 1.68, 1.53]';

n = numel(x);

% test_points
n_star = 1000;
x_star = linspace(-4, 4, n_star)';

% noise variance
sigma2_n = 0.5^2;

% feature expansions
Phi      = ones(n, 1);
Phi_star = ones(n_star, 1);

for k = 1:3
  % expand feature expansions
  Phi      = [Phi,           x.^k];
  Phi_star = [Phi_star, x_star.^k];

  % dimension of expansion
  d = size(Phi, 2);

  % prior for w
  mu    = zeros(d, 1);
  Sigma = eye(d);

  % posterior for w given data
  w_posterior_mu = ...
      mu + ...
      Sigma * Phi' / ...
      (Phi * Sigma * Phi' + sigma2_n * eye(n)) * ...
      (y - Phi * mu);

  w_posterior_Sigma = ...
      Sigma + ...
      Sigma * Phi' / ...
      (Phi * Sigma * Phi' + sigma2_n * eye(n)) * ...
      Phi * Sigma;

  % predictions for y*
  y_star_posterior_mu = ...
      Phi_star * w_posterior_mu;
  y_star_posterior_Sigma = ...
      Phi_star * w_posterior_Sigma * Phi_star' + sigma2_n * eye(n_star);

  % marginal likelihood
  fprintf('log p(y | X, D, k = %i) = %0.4f\n', ...
          k, ...
          log_mvnpdf(y, ...
                     Phi * mu, ...
                     Phi * Sigma * Phi' + sigma2_n * eye(n)));

  % plot

  clf;
  hold('off');
  sigma_h = ...
    fill([x_star; flipud(x_star)], ...
         [y_star_posterior_mu - ...
          2 * sqrt(diag(y_star_posterior_Sigma));
          flipud(y_star_posterior_mu + ...
                 2 * sqrt(diag(y_star_posterior_Sigma)))], ...
         plot_colors(1, :), ...
         'edgecolor', 'none', ...
         'facealpha', 0.3);
  hold('on');
  mean_h = ...
      plot(x_star, y_star_posterior_mu, ...
       'color', plot_colors(4, :));
  observations_h = ...
      plot(x, y, 'k.');

  xlabel('$x$');

  set(gca, 'box', 'off');

  legend([mean_h, sigma_h, observations_h], ...
         '$\mu(x)$',              ...
         '$\pm 2\sigma$', ...
         'observations',               ...
         'location', 'northeast');
  legend('boxoff');

  % make tikz plot if possible
  if (exist('matlab2tikz', 'file'))
    figure_name = sprintf('order_%i_expansion', k);
    matlab2tikz(sprintf('%s/%s.tex', figures_directory, figure_name), ...
                'height',       '\figureheight', ...
                'width',        '\figurewidth',  ...
                'parseStrings', false,           ...
                'showInfo',     false,           ...
                'extraAxisOptions', 'legend style={legend columns=-1, draw=none}, reverse legend', ...
                'extraCode',    sprintf('\\tikzsetnextfilename{%s}', figure_name));
  end
end

% problem 3

% data
x = [-2.26, -1.31, -0.43, 0.32, 0.34, 0.54, 0.86, 1.83, 2.77, 3.58]';
y = [1.03, 0.70, -0.68, -1.36, -1.74, -1.01, 0.24, 1.55, 1.68, 1.53]';

n = numel(x);

% test_points
x_star = (-4:0.5:4)';
n_star = numel(x_star);

% noise variance
sigma2_n = 0.5^2;

% feature expansions
Phi      = [ones(n, 1),      x,      x.^2];
Phi_star = [ones(n_star, 1), x_star, x_star.^2];

% dimension of expansion
d = size(Phi, 2);

% prior for w
mu    = zeros(d, 1);
Sigma = eye(d);

% updated Phi matrix after adding a observation at x'
Phi_prime = ...
    @(x_prime) ([Phi; [1, x_prime, x_prime.^2]]);

% posterior covariance of w after adding a observation at x'
w_posterior_Sigma = ...
    @(x_prime) ...
    (Sigma + ...
     Sigma * Phi_prime(x_prime)' / ...
     (Phi_prime(x_prime) * Sigma * Phi_prime(x_prime)' + ...
      sigma2_n * eye(n + 1)) * ...
     Phi_prime(x_prime) * Sigma);

% posterior covariance of y_* after adding an observation at x'
y_star_posterior_Sigma = ...
    @(x_prime) ...
    Phi_star * w_posterior_Sigma(x_prime) * Phi_star' + ...
    sigma2_n * eye(n_star);

% x' to consider for plotting
n_primes = 1000;
x_primes = linspace(-4, 4, n_primes);

% compute expected losses for each x'
expected_losses = zeros(n_primes, 1);
for i = 1:n_primes
  expected_losses(i) = trace(y_star_posterior_Sigma(x_primes(i)));
end

[minimum_loss, best_ind] = min(expected_losses);

fprintf('Bayes action: x''= %0.4f\n', x_primes(best_ind));

% plot

clf;
hold('off');
loss_h = ...
    plot(x_primes, expected_losses, ...
         'color', plot_colors(4, :));
hold('on');
bayes_h = ...
    plot(x_primes(best_ind), minimum_loss, 'k.');

xlabel('$x''$');
ylabel('$\mathbb{E}\bigl[\ell(\vec{y}_\ast, \hat{\vec{y}}_\ast) \given x'', \data\bigr]$');

set(gca, 'box', 'off');

legend([loss_h, bayes_h], ...
       'expected loss',   ...
       'Bayes action');
legend('boxoff');

% make tikz plot if possible
if (exist('matlab2tikz', 'file'))
  figure_name = 'problem_3';
  matlab2tikz(sprintf('%s/%s.tex', figures_directory, figure_name), ...
              'height',       '\figureheight', ...
              'width',        '\figurewidth',  ...
              'parseStrings', false,           ...
              'showInfo',     false,           ...
              'extraAxisOptions', 'legend style={draw=none}', ...
              'extraCode',    sprintf('\\tikzsetnextfilename{%s}', figure_name));
end

% problem 5

% range of alpha to plot
alpha = linspace(0.1, 5, 1000);

% Laplace approximation to Z
approximate_Z = ...
    @(alpha) ...
    (sqrt(2 * pi) * (alpha - 1).^(alpha - 1/2) .* exp(-(alpha - 1)));

clf;
% true Z is gamma(alpha)
true_Z_h = ...
    plot(alpha, gamma(alpha), ...
         'color', plot_colors(4, :));
hold('on');
approximate_Z_h = ...
    plot(alpha, approximate_Z(alpha), ...
         'color', plot_colors(2, :));

xlabel('$\alpha$');

legend([true_Z_h, approximate_Z_h], ...
       'true $Z$', ...
       'approximate $Z$', ...
       'location', 'northwest');

set(gca, 'box', 'off');

% make tikz plot if possible
if (exist('matlab2tikz', 'file'))
  figure_name = 'problem_5';
  matlab2tikz(sprintf('%s/%s.tex', figures_directory, figure_name), ...
              'height',       '\figureheight', ...
              'width',        '\figurewidth',  ...
              'parseStrings', false,           ...
              'showInfo',     false,           ...
              'extraAxisOptions', 'legend style={draw=none}', ...
              'extraCode',    sprintf('\\tikzsetnextfilename{%s}', figure_name));
end
