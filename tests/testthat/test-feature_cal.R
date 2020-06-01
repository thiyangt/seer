if (require(testthat)) {
  context("Tests on output")
  test_that("test for feature_cal", {
    example_series <- as.ts(c(940.66, 1084.86, 1244.98, 1445.02, 1683.17,
                              2038.15, 2342.52, 2602.45, 2927.87, 3103.96, 3360.27, 3807.63, 4387.88,
                              4936.99))
    z <- cal_features(example_series, database="other", h=6, highfreq=FALSE)
    expect_equal(length(z), 25L)
   # expect_equal(z$entropy,0.8089799, tolerance=1e-3)
    expect_equal(z$lumpiness,0, tolerance=1e-3)
    expect_equal(z$stability,0, tolerance=1e-3)
    expect_equal(z$hurst, 0.9205396, tolerance=1e-3)
    expect_equal(z$trend,0.9929078, tolerance=1e-3)
    expect_equal(z$spikiness,8.789084e-07, tolerance=1e-3)
    expect_equal(z$linearity,2.620677, tolerance=1e-3)
    expect_equal(z$curvature,0.166591, tolerance=1e-3)
    expect_equal(z$e_acf1,0.4067337, tolerance=1e-3)
    expect_equal(z$y_acf1,0.6430547, tolerance=1e-3)
    expect_equal(z$diff1y_acf1,0.5601308, tolerance=1e-3)
    expect_equal(z$diff2y_acf1,-0.01084371, tolerance=1e-3)
    expect_equal(z$y_pacf5,0.5713965, tolerance=1e-3)
    expect_equal(z$diff1y_pacf5,0.620029, tolerance=1e-3)
    expect_equal(z$nonlinearity,16.25889, tolerance=1e-3)
    expect_equal(z$lmres_acf1, 0.4624682, tolerance=1e-3)
    expect_equal(z$ur_pp, 0.7591639, tolerance=1e-3)
    expect_equal(z$ur_kpss, 0.1365905, tolerance=1e-3)
    expect_equal(z$N, 8, tolerance=1e-3)
    expect_equal(z$y_acf5, 0.7421095, tolerance=1e-3)
    expect_equal(z$diff1y_acf5, 0.7170233, tolerance=1e-3)
    expect_equal(z$diff2y_acf5, 0.1112676, tolerance=1e-3)
    expect_equal(z$alpha, 0.9780962, tolerance=1e-3)
    expect_equal(z$beta, 0.7691654, tolerance=1e-3)
    expect_equal(z$diff2y_pacf5,0.159, tolerance=1e-3)
  })
}

if (require(testthat)) {
  context("Tests on output")
  test_that("test for feature_calfor a monthly series", {
    #library(Mcomp)
   # monthly_subset <- subset(M3, "monthly")
    example_series <- ts(c(4160, 3960, 4170, 6180, 5520, 3750, 3400, 5170, 3890, 3580, 3130, 4950,
                        4310, 3830, 5430, 4580, 6270, 4740, 3260, 5970, 6910, 6380, 6460, 4570,
                        5660, 5100, 4140, 5380, 6560, 3650, 2970, 8360, 6240, 4260, 3740, 5980,
                        6300, 4370, 4490, 7600, 6920, 3200, 2280, 5440, 5450, 4340, 2690, 6550,
                        7650, 3870, 4290, 8530, 6200, 2260, 1600, 3580, 5480, 2990, 3260, 5490,
                        7520, 4730, 5710, 7680, 4860, 5920, 2260, 4400, 5520, 4000, 3660, 5770,
                        6990, 4220, 4360, 6880, 5360, 3920, 2800, 4670, 3470, 4400, 4470, 5480,
                        5790, 3440, 4010, 7310, 6370, 2380, 2560, 5290, 4090, 4890, 4140, 7620,
                        5600, 3650, 4540, 7090, 6320, 3270, 2750, 6630, 3080, 4180, 4410, 5490,
                        6020, 3270, 3930, 7400, 7350, 2270, 2360, 6870, 3460, 3880, 3040, 4540,
                        6800, 4060, 5620, 7790, 8480, 2610), frequency = 12)
    z <- cal_features(example_series, database="other", h=8, highfreq = FALSE, seasonal = TRUE, lagmax = 13L)
    expect_equal(length(z), 30L)
   # expect_equal(z$entropy, 0.824, tolerance=1e-3)
    expect_equal(z$lumpiness, 0.2029498, tolerance=1e-3)
    expect_equal(z$stability, 0.03809177, tolerance=1e-3)
    expect_equal(z$hurst, 0.5000458, tolerance=1e-3)
    expect_equal(z$trend, 0.1481309, tolerance=1e-3)
    expect_equal(z$spikiness, 1.580675e-05, tolerance=1e-3)
    expect_equal(z$linearity, -0.1522078, tolerance=1e-3)
    expect_equal(z$curvature, -0.8602018, tolerance=1e-3)
    expect_equal(z$e_acf1, -0.02213496, tolerance=1e-3)
    expect_equal(z$y_acf1, 0.09713354, tolerance=1e-3)
    expect_equal(z$diff1y_acf1, -0.1986929, tolerance=1e-3)
    expect_equal(z$diff2y_acf1, -0.3442473, tolerance=1e-3)
    expect_equal(z$y_pacf5, 0.3171549, tolerance=1e-3)
    expect_equal(z$diff1y_pacf5, 0.6318072, tolerance=1e-3)
    expect_equal(z$nonlinearity, 0.2937262, tolerance=1e-3)
    expect_equal(z$seas_pacf, 0.4174251, tolerance=1e-3)
    expect_equal(z$seasonality, 0.693799, tolerance=1e-3)
    expect_equal(z$hwalpha, 0.0001001451, tolerance=1e-3)
    expect_equal(z$hwbeta, 0.0001000158, tolerance=1e-3)
    expect_equal(z$hwgamma, 0.000100174, tolerance=1e-3)
    expect_equal(z$sediff_acf1, -0.1986929, tolerance=1e-3)
    expect_equal(z$sediff_seacf1, -0.1986929, tolerance=1e-3)
    expect_equal(z$sediff_acf5, 0.580957, tolerance=1e-3)
    expect_equal(z$N, 118, tolerance=1e-3)
    expect_equal(z$y_acf5, 0.3758739, tolerance=1e-3)
    expect_equal(z$diff1y_acf5, 0.580957, tolerance=1e-3)
    expect_equal(z$diff2y_acf5, 0.4422682, tolerance=1e-3)
  #  expect_equal(z$alpha, 0.0001001281, tolerance=1e-3)
  #  expect_equal(z$beta, 0.0001000012, tolerance=1e-3)
  })
}

