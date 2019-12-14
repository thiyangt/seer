if (require(testthat)) {
  context("Tests on output")
  test_that("test for rf_forecast for a yearly series", {
    library(Mcomp)
    data(M1)
    y1 <- subset(M1, "yearly")
    z <- rf_forecast(predictions="rw", tslist=y1[[1]]$x, database="other", function_name=cal_MASE, h=6, accuracy=TRUE)
    expect_equal(length(z), 4L)
    expect_equal(as.vector(z$mean), c(322681, 322681, 322681, 322681, 322681, 322681), tolerance=1e-4)
    expect_equal(as.vector(z$lower), c(269057.7, 246846.2, 229802.7, 215434.4, 202775.6, 191331.2), tolerance=1e-4)
    expect_equal(as.vector(z$upper), c(376304.3, 398515.8, 415559.3, 429927.6, 442586.4, 454030.8), tolerance=1e-4)
    expect_equal(z$accuracy,  5.093695, tolerance=1e-4)
  })
}

if (require(testthat)) {
  context("Tests on output")
  test_that("test for rf_forecast for a monthly series", {
    library(Mcomp)
    data(M1)
    m1 <- subset(M1, "monthly")
    z2 <- rf_forecast(predictions="rw", tslist=m1[[1]]$x, database="other", function_name=cal_MASE, h=8, accuracy=TRUE)
    expect_equal(length(z2), 4L)
    expect_equal(as.vector(z2$mean), c(1330520, 1330520, 1330520, 1330520, 1330520, 1330520, 1330520, 1330520), tolerance=1e-4)
    expect_equal(as.vector(z2$lower), c(442499.4, 74669.21, -207576.8, -445521.2, -655154.4, -844677.4, -1018962, -1181182), tolerance=1e-4)
    expect_equal(as.vector(z2$upper), c(2218541, 2586371, 2868617, 3106561, 3316194, 3505717, 3680002, 3842222), tolerance=1e-4)
    expect_equal(z2$accuracy,   1.212279, tolerance=1e-4)
  })
}
