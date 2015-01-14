% This file will plot the prior, likelihood, and posterior
% distribution for a beta-binomial model.
%
% The output will be a .tex file that you can \input{} into a LaTeX
% document and produce a plot.  This will require matlab2tikz
% (https://github.com/matlab2tikz/matlab2tikz) and pgfplots.
%
% Roman Garnett (garnett@wustl.edu)

% parameters of prior distribution
alpha = 3; % pseudocount of positive observations
beta  = 5; % pseudocount of negative observations

% observed data
x = 7; % number of positive observations
n = 8; % total number of observations

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
likelihood_h = ...
    plot(theta, likelihood(theta), ...
         'color', colors(2, :));
posterior_h = ...
    plot(theta, posterior(theta), ...
         'color', colors(3, :));

legend([prior_h, likelihood_h, posterior_h], ...
       'prior', ...
       'likelihood', ...
       'posterior', ...
       'location', 'northwest');
legend('boxoff');

xlabel('$\theta$');

set(gca, 'box', 'off');

% make tikz plot if possible
if (exist('matlab2tikz', 2))
  figure_name = 'beta_example';
  matlab2tikz(sprintf('%s/%s.tex', figures_directory, figure_name), ...
              'height',       '\figureheight', ...
              'width',        '\figurewidth',  ...
              'parseStrings', false,           ...
              'showInfo',     false,           ...
              'extraCode',    sprintf('\\tikzsetnextfilename{%s}', figure_name));
end