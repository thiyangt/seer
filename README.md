
[![Build Status](https://travis-ci.org/thiyangt/seer.svg?branch=master)](https://travis-ci.org/thiyangt/seer)

seer
====

Meta-learning how to forecast time series

Installation
------------

You can install seer from github with:

``` r
# install.packages("devtools")
devtools::install_github("thiyangt/seer")
```

Usage
-----

``` r
library(Mcomp)
#> Loading required package: forecast
library(seer)
#> 
#> Attaching package: 'seer'
#> The following object is masked from 'package:Mcomp':
#> 
#>     subset.Mcomp
library(tsfeatures)
#> 
#> Attaching package: 'tsfeatures'
#> The following object is masked from 'package:seer':
#> 
#>     holt_parameters
data(M3)
yearly_m3 <- subset(M3, "yearly")
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

``` r
library(Mcomp)
tslist <- list(M3[[1]], M3[[2]])
fcast_accuracy(tslist=tslist,models= c("arima","ets","rw","rwd", "theta", "nn"),database ="M3", cal_MASE, h=6, length_out = 1)
#> $accuracy
#>         arima       ets       rw       rwd    theta        nn
#> [1,] 1.566974 1.5636089 7.703518 4.2035176 6.017236 2.4353317
#> [2,] 1.698388 0.9229687 1.698388 0.6123443 1.096000 0.2798837
#> 
#> $ARIMA
#> [1] "ARIMA(0,2,0)" "ARIMA(0,1,0)"
#> 
#> $ETS
#> [1] "ETS(M,A,N)" "ETS(M,A,N)"
```
