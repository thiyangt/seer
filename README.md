
seer <img src="logo/seer.png" align="right" height="200"/>
==========================================================

[![Project Status: Active ? The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active) [![Build Status](https://travis-ci.org/thiyangt/seer.svg?branch=master)](https://travis-ci.org/thiyangt/seer)

------------------------------------------------------------------------

The `seer` package provides implementations of a novel framework for forecast model selection using time series features. We call this framework **FFORMS** (**F**eature-based **FOR**ecast **M**odel **S**election). For more details see our [paper](https://www.monash.edu/business/econometrics-and-business-statistics/research/publications/ebs/wp06-2018.pdf).

Installation
------------

You can install seer from github with:

``` r
# install.packages("devtools")
devtools::install_github("thiyangt/seer")
library(seer)
```

Usage
-----

The FFORMS framework consists of two main phases: i) offline phase, which includes the development of a classification model and ii) online phase, use the classification model developed in the offline phase to identify "best" forecast-model. This document explains the main functions using a simple dataset based on M3-competition data. To load data

``` r
library(Mcomp)
data(M3)
yearly_m3 <- subset(M3, "yearly")
m3y <- M3[1:2]
```

**FFORMS: offline phase **

Augmenting the observed sample with simulated time series.

`sim_arimabased` can be used to simulate time series based on (S)ARIMA models.

``` r
library(seer)
simulated_arima <- lapply(m3y, sim_arimabased, Future=TRUE, Nsim=2, extralength=6, Combine=FALSE)
simulated_arima
#> $N0001
#> $N0001[[1]]
#> Time Series:
#> Start = 1989 
#> End = 2008 
#> Frequency = 1 
#>  [1]  5519.299  6226.387  7025.630  7839.298  8669.836  9614.123 10548.357
#>  [8] 11379.795 12329.346 13239.124 14014.073 14890.971 15866.408 16878.932
#> [15] 17853.579 18829.107 19656.232 20460.987 21219.581 21907.067
#> 
#> $N0001[[2]]
#> Time Series:
#> Start = 1989 
#> End = 2008 
#> Frequency = 1 
#>  [1]  5505.019  6088.506  6576.212  7017.670  7554.010  8068.398  8701.627
#>  [8]  9392.835 10108.130 10862.810 11747.781 12660.091 13649.940 14823.974
#> [15] 15887.510 16790.826 17836.767 18749.503 19636.700 20509.879
#> 
#> 
#> $N0002
#> $N0002[[1]]
#> Time Series:
#> Start = 1989 
#> End = 2008 
#> Frequency = 1 
#>  [1] 3112.6960 4722.2523 5295.1574 5570.2010 4834.9705 4355.2355 4763.6273
#>  [8] 4573.4270 4582.8747 3675.1281 2912.3663 1571.1368 1315.4058 2093.3903
#> [15] 1298.8673 1218.3408  684.0334 1931.7761 2215.2703 2279.5410
#> 
#> $N0002[[2]]
#> Time Series:
#> Start = 1989 
#> End = 2008 
#> Frequency = 1 
#>  [1]  4642.7554  4075.1313  2743.2531  4804.9946  3298.4484  3230.8649
#>  [7]  3134.4922  2466.5466  2351.3711  1709.5303  1428.4462  2072.9468
#> [13]  2202.3710  1297.5353   847.5323   477.0597   190.6337 -1458.4751
#> [19]  -801.8079 -1570.1235
```

Similarly, `sim_etsbased` can be used to simulate time series based on ETS models.

``` r
simulated_ets <- lapply(m3y, sim_etsbased, Future=TRUE, Nsim=2, extralength=6, Combine=FALSE)
simulated_ets
```

Calculate features based on the training period of time series.

`cal_features` function can be used to calculate relevant features.

``` r
library(tsfeatures)
M3yearly_features <- cal_features(yearly_m3,database="M3", h=6, highfreq = FALSE)
head(M3yearly_features)
#>     entropy lumpiness stability     hurst     trend    spikiness linearity
#> 1 0.7729350         0         0 0.9710509 0.9950394     589054.2 4497.2290
#> 2 0.8374974         0         0 0.9473065 0.8687934  602056839.8 2781.4010
#> 3 0.8250352         0         0 0.9486339 0.8648297  668930862.1 2389.2156
#> 4 0.8544250         0         0 0.9486690 0.8534447 1236312953.9 3891.0477
#> 5 0.8988307         0         0 0.8545574 0.5858339  895710089.7 -700.9957
#> 6 0.7977529         0         0 0.9642617 0.9637770    8155267.6 2785.1353
#>    curvature    e_acf1    y_acf1 diff1y_acf1  diff2y_acf1   y_pacf5
#> 1   531.9694 0.4124236 0.7623182  0.59742360 -0.004813322 0.6152347
#> 2 -2823.8839 0.3240316 0.7507872  0.23996912 -0.398246929 0.8093241
#> 3 -3078.0284 0.4571183 0.7687310  0.44612514 -0.211798893 0.9173062
#> 4 -1696.7665 0.2807471 0.6921482  0.11112733 -0.329776367 0.5799828
#> 5 -1620.3855 0.1921663 0.6085203 -0.01600688 -0.445592095 0.5019175
#> 6  -449.4356 0.1810244 0.7011528  0.09666365 -0.296063241 0.5100057
#>   diff1y_pacf5 diff2y_pacf5 nonlinearity lmres_acf1     ur_pp   ur_kpss  N
#> 1   0.54834260    0.2301945   2.12440536  0.4819001  1.329299 0.1495925 14
#> 2   0.15658053    0.3074159   1.99871020  0.7227836 -3.735398 0.1461405 14
#> 3   0.37083053    0.1717048   1.44966392  0.7645834 -3.978590 0.1449998 14
#> 4   0.31074774    0.3872147   5.93940010  0.6322638 -2.516911 0.1253592 14
#> 5   0.03533964    0.3259537   8.10433256  0.5030697 -5.721996 0.1149469 14
#> 6   0.09475982    0.3984187   0.08557127  0.3791048 -1.928506 0.1315947 14
#>      y_acf5 diff1y_acf5 diff2y_acf5     alpha         beta
#> 1 1.0230152  0.42137737   0.3614128 0.9998869 0.9998868741
#> 2 0.9855601  0.13385167   0.5582498 0.9998999 0.2171013415
#> 3 1.0798980  0.36099883   0.7632291 0.9998999 0.5054122271
#> 4 0.7259137  0.27099528   0.4791517 0.9838320 0.0001000009
#> 5 0.6476230  0.03192893   0.2940731 0.9373860 0.0001000081
#> 6 0.8320440  0.11524106   0.3031490 0.6714580 0.0001000046
```

Calculate forecast accuracy measures

``` r
tslist <- list(M3[[1]], M3[[2]])
fcast_accuracy(tslist=tslist,models= c("arima","ets","rw","rwd", "theta", "nn"),database ="M3", cal_MASE, h=6, length_out = 1)
#> $accuracy
#>         arima       ets       rw       rwd    theta        nn
#> [1,] 1.566974 1.5636089 7.703518 4.2035176 6.017236 2.3483442
#> [2,] 1.698388 0.9229687 1.698388 0.6123443 1.096000 0.2798433
#> 
#> $ARIMA
#> [1] "ARIMA(0,2,0)" "ARIMA(0,1,0)"
#> 
#> $ETS
#> [1] "ETS(M,A,N)" "ETS(M,A,N)"
```
