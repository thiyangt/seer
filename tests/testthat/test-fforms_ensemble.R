if (require(testthat)) {
  context("Tests on output")
  test_that("test for fforms_ensemble", {
    fforms_votematrix <- matrix(c(0.1, 0.2, 0.7, 0.3, 0.3, 0.4), byrow=TRUE, ncol=3)
    colnames(fforms_votematrix) <- c("WN", "RW", "RWD")
    z <- fforms_ensemble(fforms_votematrix, threshold = 0.5)
    expect_equal(length(z), 2L)
    expect_equal(names(z[[1]]), "RWD")
    expect_equal(names(z[[2]]), c("RWD","WN"))
  })
}
