% problem 4

% parameters of prior distribution
alpha = (1 / 5); % pseudocount of positive observations
beta  = (1 / 5); % pseudocount of negative observations

% observed data
x = 3; % number of positive observations
n = 3; % total number of observations

% plot colors (from http://colorbrewer2.org/)
colors = [ 31, 120, 180; ...
           51, 160,  44; ...
          227,  26,  28] / 255;

% location of tikz output
figures_directory = 'figures';

% function handles for prior, likelihood, and posterior; see notes
prior      = @(theta) betapdf(theta, alpha, beta);
likelihood = @(theta) binopdf(x, n, theta);
posterior  = @(theta) betapdf(theta, alpha + x, beta + n - x);

% range of theta values to plot
theta = linspace(0, 1, 1000);

clf;
hold('off');
prior_h = ...
    plot(theta, prior(theta), ...
         'color', colors(1, :));
hold('on');
posterior_h = ...
    plot(theta, posterior(theta), ...
         'color', colors(3, :));

legend([prior_h, posterior_h], ...
       '$p(\theta)$', ...
       '$p(\theta \given \text{HHH})$', ...
       'location', 'northwest');
legend('boxoff');

xlabel('$\theta$');

set(gca, 'box', 'off');

% make tikz plot if possible
if (exist('matlab2tikz', 'file'))
  figure_name = 'problem_4';
  matlab2tikz(sprintf('%s/%s.tex', figures_directory, figure_name), ...
              'height',       '\figureheight', ...
              'width',        '\figurewidth',  ...
              'parseStrings', false,           ...
              'showInfo',     false,           ...
              'extraCode',    sprintf('\\tikzsetnextfilename{%s}', figure_name));
end

% problem 6 prior
sigma_spike = 1;
sigma_slab  = 10;
prior_f     = (1 / 2);

spike_prior = @(theta) (normpdf(theta, 0, sigma_spike));
slab_prior  = @(theta) (normpdf(theta, 0, sigma_slab));

prior = @(theta) (     prior_f  * slab_prior(theta) + ...
                  (1 - prior_f) * spike_prior(theta));

% range of theta values to plot
theta = linspace(-30, 30, 1000);

clf;
hold('off');
prior_h = ...
    plot(theta, prior(theta), ...
     'color', colors(1, :));

legend(prior_h, ...
       '$p(\theta \given \sigma_{\text{spike}}^2, \sigma_{\text{slab}}^2)$', ...
       'location', 'northwest');
legend('boxoff');

xlabel('$\theta$');

set(gca, 'box', 'off');

% make tikz plot if possible
if (exist('matlab2tikz', 'file'))
  figure_name = 'problem_6_prior';
  matlab2tikz(sprintf('%s/%s.tex', figures_directory, figure_name), ...
              'height',       '\figureheight', ...
              'width',        '\figurewidth',  ...
              'parseStrings', false,           ...
              'showInfo',     false,           ...
              'extraCode',    sprintf('\\tikzsetnextfilename{%s}', figure_name));
end

% problem 6 f posterior
omega = 0.1;

f_posterior = @(x) ...
    (prior_f * normpdf(x, 0, sqrt(sigma_slab^2 + omega^2)) ./ ...
     (     prior_f  * normpdf(x, 0, sqrt(sigma_slab^2 + omega^2)) + ...
      (1 - prior_f) * normpdf(x, 0, sqrt(sigma_spike^2 + omega^2))));

% range of x values to consider
x = linspace(-10, 10, 1000);

clf;
hold('off');
f_posterior_h = ...
    plot(x, f_posterior(x), ...
     'color', colors(1, :));

legend(f_posterior_h, ...
       '$\Pr(f = 1 \given x, \sigma_{\text{spike}}^2, \sigma_{\text{slab}}^2, \omega^2)$', ...
       'location', 'northwest');
legend('boxoff');

xlabel('$x$');

ylim([0, 1.2]);

set(gca, 'box', 'off');

% make tikz plot if possible
if (exist('matlab2tikz', 'file'))
  figure_name = 'problem_6_f_posterior';
  matlab2tikz(sprintf('%s/%s.tex', figures_directory, figure_name), ...
              'height',       '\figureheight', ...
              'width',        '\figurewidth',  ...
              'parseStrings', false,           ...
              'showInfo',     false,           ...
              'extraCode',    sprintf('\\tikzsetnextfilename{%s}', figure_name));
end

% problem 6 theta posterior

% observation
x = 3;

% posterior precisions
tau_spike = (omega^(-2) + sigma_spike^(-2));
tau_slab  = (omega^(-2) + sigma_slab^(-2));

theta_posterior = @(theta) ...
    (     f_posterior(x)  * ...
     normpdf(theta, omega^(-2) / tau_slab * x, sqrt(1 / tau_slab)) + ...
     (1 - f_posterior(x)) * ...
     normpdf(theta, omega^(-2) / tau_spike * x, sqrt(1 / tau_spike)));

theta = linspace(1, 5, 1000);

clf;
theta_posterior_h = ...
    plot(theta, theta_posterior(theta), ...
         'color', colors(1, :));

legend(theta_posterior_h, ...
       '$\Pr(\theta \given x, \sigma_{\text{spike}}^2, \sigma_{\text{slab}}^2, \omega^2)$', ...
       'location', 'northwest');
legend('boxoff');

xlabel('$\theta$');

ylim([0, 4.9]);

set(gca, 'box', 'off');

% make tikz plot if possible
if (exist('matlab2tikz', 'file'))
  figure_name = 'problem_6_theta_posterior';
  matlab2tikz(sprintf('%s/%s.tex', figures_directory, figure_name), ...
              'height',       '\figureheight', ...
              'width',        '\figurewidth',  ...
              'parseStrings', false,           ...
              'showInfo',     false,           ...
              'extraCode',    sprintf('\\tikzsetnextfilename{%s}', figure_name));
end
