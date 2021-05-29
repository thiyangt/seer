if (require(testthat)) {
  context("Tests on output")
  test_that("test for fcast_accuracy yearly series", {
    example_series <- as.ts(c(940.66, 1084.86, 1244.98, 1445.02, 1683.17,
                              2038.15, 2342.52, 2602.45, 2927.87, 3103.96, 3360.27, 3807.63, 4387.88,
                              4936.99))
    z <- fcast_accuracy(example_series, models= c("arima","ets","rw","rwd", "theta", "stlar", "nn", "wn"), database="other", h=6,
                        length_out = 1, accuracyFun=cal_MASE, fcast_save = FALSE)
    expect_equal(length(z), 3L)
    expect_equal(z$accuracy[["arima"]], 1.075554, tolerance=1e-4)
    expect_equal(z$accuracy[["ets"]], 4.851234, tolerance=1e-4)
    expect_equal(z$accuracy[["rw"]], 4.851124, tolerance=1e-4)
    expect_equal(z$accuracy[["rwd"]], 1.351124, tolerance=1e-4)
    expect_equal(z$accuracy[["theta"]], 3.048791, tolerance=1e-4)
    #expect_equal(z$accuracy[["stlar"]], 1.075554, tolerance=1e-4)
    #expect_equal(z$accuracy[["nn"]], 4.184322, tolerance=1e-2)
    expect_equal(z$accuracy[["wn"]], 8.767423 , tolerance=1e-4)
    expect_equal(z$ARIMA, "ARIMA(0,2,0)")
    expect_equal(z$ETS, "ETS(M,N,N)")
  })
}

if (require(testthat)) {
  context("Tests on output")
  test_that("test for fcast_accuracy for monthly series", {
    library(Mcomp)
    monthly_subset <- subset(M3, "monthly")
    example_series <- monthly_subset[[600]]$x
    z2 <- fcast_accuracy(example_series, models= c("arima","ets","rw","rwd", "theta", "stlar", "nn", "wn", "snaive", "mstlets",
                                                  "mstlarima", "tbats"), database="other", h=8,
                        length_out = 1, accuracyFun=cal_MASE, fcast_save = FALSE)
    expect_equal(length(z2), 3L)
    expect_equal(z2$accuracy[["arima"]], 1.087726, tolerance=1e-4)
    expect_equal(z2$accuracy[["ets"]], 1.149386, tolerance=1e-4)
    expect_equal(z2$accuracy[["rw"]], 2.221425, tolerance=1e-4)
    expect_equal(z2$accuracy[["rwd"]], 2.227361, tolerance=1e-4)
    expect_equal(z2$accuracy[["theta"]], 1.169801, tolerance=1e-4)
    #expect_equal(z2$accuracy[["stlar"]], 1.078007, tolerance=1e-4)
    #expect_equal(z2$accuracy[["nn"]], 1.435993, tolerance=1e-1)
    expect_equal(z2$accuracy[["wn"]], 1.989912 , tolerance=1e-4)
    expect_equal(z2$accuracy[["snaive"]], 1.025273 , tolerance=1e-4)
   # expect_equal(z2$accuracy[["mstlets"]], 1.063771 , tolerance=1e-4)
   # expect_equal(z2$accuracy[["mstlarima"]],1.034984 , tolerance=1e-4)
    expect_equal(z2$accuracy[["tbats"]], 1.106218, tolerance=1e-4)
    expect_equal(z2$ARIMA, "ARIMA(1,0,1)(0,1,1)[12]")
    expect_equal(z2$ETS, "ETS(M,N,M)")
  })
}
