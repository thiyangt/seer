#if (require(testthat)) {
#  context("Tests on output")
#  test_that("test for fforms_combination", {
#    fforms_votematrix <- matrix(c(0.1, 0.2, 0.7), byrow=TRUE, ncol=3)
#    colnames(fforms_votematrix) <- c("wn", "rw", "rwd")
#    wmat <- fforms_ensemble(fforms_votematrix)
#    library(Mcomp)
#    data(M1)
#    m1y <- subset(M1, "yearly")
#    tslist <- m1y[1]
#    z <- fforms_combinationforecast(wmat, tslist, database="M1", h=6)
#    expect_equal(length(z), 1L)
#    expect_equal(as.vector(z[[1]]$mean), c(579581, 605761.9, 631942.9, 658123.8, 684304.8, 710485.7), tolerance=1e-4)
#    expect_equal(as.vector(z[[1]]$lower), c(518551.8, 517422.6, 521318.2, 527638.1, 535408.9, 544148.4), tolerance=1e-4)
#    expect_equal(as.vector(z[[1]]$upper), c(640610.1, 694101.2, 742567.5, 788609.6, 833200.6, 876823.1), tolerance=1e-4)
#  })
#}


