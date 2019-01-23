% This file will plot the posterior probability that a coin is
% "near fair."
%
% The output will be a .tex file that you can \input{} into a LaTeX
% document and produce a plot.  This will require matlab2tikz
% (https://github.com/matlab2tikz/matlab2tikz) and pgfplots.
%
% Roman Garnett (garnett@wustl.edu)

% parameters of prior distribution
alpha = 1; % pseudocount of positive observations
beta  = 1; % pseudocount of negative observations

% observed data
x = 30; % number of positive observations
n = 50; % total number of observations

% location of tikz output
figures_directory = 'figures';

% posterior probability θ ∈ [½ - ε, ½ + ε]
near_fair_probability = @(epsilon) ...
    betacdf(0.5 + epsilon, alpha + x, beta + n - x) - ...
    betacdf(0.5 - epsilon, alpha + x, beta + n - x);

% range of epsilon values to plot
epsilon = linspace(0, 0.5, 1000);

clf;
near_fair_probabilities_h = ...
    plot(epsilon, near_fair_probability(epsilon), ...
         'color', [31, 120, 180] / 255);

ylim([0, 1.01]);

legend(near_fair_probabilities_h, ...
       '$\Pr\bigl(\theta \in \mc{H}(\varepsilon) \given \data\bigr)$', ...
       'location', 'southeast');
legend('boxoff');

xlabel('$\varepsilon$');

set(gca, 'box',      'off', ...
         'tickdir', 'out');

% make tikz plot if possible
if (exist('matlab2tikz', 'file'))
  figure_name = 'near_fair_probabilities';
  matlab2tikz(sprintf('%s/%s.tex', figures_directory, figure_name), ...
              'height',       '\figureheight', ...
              'width',        '\figurewidth',  ...
              'parseStrings', false,           ...
              'showInfo',     false,           ...
              'extraCode',    sprintf('\\tikzsetnextfilename{%s}', figure_name));
end