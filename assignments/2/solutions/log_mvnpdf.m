% computes log N(y; mu, K)

function log_p = log_mvnpdf(y, mu, K)

  log_2pi = 1.837877066409345;

  d = numel(y);

  y = y - mu;
  L = chol(K);

  log_p = -0.5 * (y' * (L \ (L' \ y)) + d * log_2pi) - ...
          sum(log(diag(L)));

end