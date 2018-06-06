
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

The FFORMS framework consists of two main phases: i) offline phase, which includes the development of a classification model and ii) online phase, use the classification model developed in the offline phase to identify "best" forecast-model. This document explains the main functions using a simple dataset based on M3-competition data. To load data,

``` r
library(Mcomp)
data(M3)
yearly_m3 <- subset(M3, "yearly")
m3y <- M3[1:2]
```

#### FFORMS: offline phase

**1. Augmenting the observed sample with simulated time series.**

We augment our reference set of time series by simulating new time series. In order to produce simulated series, we use several standard automatic forecasting algorithms such as ETS or automatic ARIMA models, and then simulate multiple time series from the selected model within each model class. `sim_arimabased` can be used to simulate time series based on (S)ARIMA models.

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
#>  [1]  5569.093  6180.512  6681.431  7286.892  7978.127  8563.688  9314.401
#>  [8] 10021.883 10639.279 11225.016 11687.079 12181.573 12830.373 13439.960
#> [15] 13940.877 14456.247 14966.625 15440.211 15886.663 16418.853
#> 
#> $N0001[[2]]
#> Time Series:
#> Start = 1989 
#> End = 2008 
#> Frequency = 1 
#>  [1]  5454.029  6071.421  6845.412  7727.272  8679.675  9578.075 10460.967
#>  [8] 11299.964 12007.949 12604.293 13043.921 13658.290 14385.046 15190.843
#> [15] 16012.031 16807.532 17737.011 18708.738 19713.843 20667.203
#> 
#> 
#> $N0002
#> $N0002[[1]]
#> Time Series:
#> Start = 1989 
#> End = 2008 
#> Frequency = 1 
#>  [1] 5797.149 6322.811 8319.110 8479.733 8308.127 8466.295 7724.679
#>  [8] 8055.208 8022.321 6757.096 7317.836 7959.673 8200.885 7535.840
#> [15] 8002.631 7611.447 7712.112 7509.604 7124.239 6815.125
#> 
#> $N0002[[2]]
#> Time Series:
#> Start = 1989 
#> End = 2008 
#> Frequency = 1 
#>  [1] 4115.684 4526.197 3730.000 3915.645 4129.895 4251.028 3568.205
#>  [8] 4851.440 4721.646 5153.161 5369.345 5935.973 6957.293 7203.131
#> [15] 8221.180 7609.585 7116.906 5866.564 6488.425 6748.056
```

Similarly, `sim_etsbased` can be used to simulate time series based on ETS models.

``` r
simulated_ets <- lapply(m3y, sim_etsbased, Future=TRUE, Nsim=2, extralength=6, Combine=FALSE)
simulated_ets
```

**2. Calculate features based on the training period of time series.**

Our proposed framework operates on the features of the time series. `cal_features` function can be used to calculate relevant features for a given list of time series.

``` r
library(tsfeatures)
M3yearly_features <- cal_features(yearly_m3, database="M3", h=6, highfreq = FALSE)
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

**3. Calculate forecast accuracy measure(s)**

`fcast_accuracy` function can be used to calculate forecast error measure (in the following example MASE) from each candidate model. This step is the most computationally intensive and time-consuming, as each candidate model has to be estimated on each series. In the following example ARIMA(arima), ETS(ets), random walk(rw), random walk with drift(rwd), standard theta method(theta) and neural network time series forecasts(nn) are used as possible models. In addition to these models following models can also be used in the case of handling seasonal time series,

-   snaive: seasonal naive method
-   stlar: STL decomposition is applied to the time series and then seasonal naive method is used to forecast seasonal component. AR model is used to forecast seasonally adjusted data.
-   mstlets: STL decomposition is applied to the time series and then seasonal naive method is used to forecast seasonal component. ETS model is used to forecast seasonally adjusted data.
-   mstlarima: STL decomposition is applied to the time series and then seasonal naive method is used to forecast seasonal component. ARIMA model is used to forecast seasonally adjusted data.
-   tbats: TBATS models

``` r
tslist <- list(M3[[1]], M3[[2]])
accuracy_info <- fcast_accuracy(tslist=tslist, models= c("arima","ets","rw","rwd", "theta", "nn"), database ="M3", cal_MASE, h=6, length_out = 1)
accuracy_info
#> $accuracy
#>         arima       ets       rw       rwd    theta        nn
#> [1,] 1.566974 1.5636089 7.703518 4.2035176 6.017236 2.3854881
#> [2,] 1.698388 0.9229687 1.698388 0.6123443 1.096000 0.2797537
#> 
#> $ARIMA
#> [1] "ARIMA(0,2,0)" "ARIMA(0,1,0)"
#> 
#> $ETS
#> [1] "ETS(M,A,N)" "ETS(M,A,N)"
```

**4. Construct a dataframe of input:features and output:lables to train a random forest**

`prepare_trainingset` can be used to create a data frame of input:features and output: labels.

``` r
# steps 3 and 4 applied to yearly series of M1 competition
data(M1)
yearly_m1 <- subset(M1, "yearly")
accuracy_m1 <- fcast_accuracy(tslist=yearly_m1, models= c("arima","ets","rw","rwd", "theta", "nn"), database ="M1", cal_MASE, h=6, length_out = 1)
features_m1 <- cal_features(yearly_m1, database="M1", h=6, highfreq = FALSE)

# prepare training set
prep_tset <- prepare_trainingset(accuracy_set = accuracy_m1, feature_set = features_m1)

# provides the training set to build a rf classifier
head(prep_tset$trainingset)
#>     entropy   lumpiness stability     hurst     trend    spikiness
#> 1 0.6834977 0.039954623 0.9769784 0.9849926 0.9850371 1.017214e+15
#> 2 0.7111939 0.079004273 0.8942551 0.9875651 0.9886314 6.578014e+14
#> 3 0.7159449 0.016023114 0.8575642 0.9869744 0.9889526 2.092182e+14
#> 4 0.7614693 0.002012414 1.3188444 0.9818805 0.9573949 1.536452e+15
#> 5 0.6282809 0.001119965 0.4455716 0.9926890 0.9731881 4.697275e+21
#> 6 0.7079567 0.007742860 0.5784716 0.9859727 0.9750517 1.112001e+09
#>     linearity   curvature      e_acf1    y_acf1 diff1y_acf1 diff2y_acf1
#> 1   743661.90  117634.759 -0.06034303 0.8332267 -0.01613382 -0.15858240
#> 2   643182.89   88179.645  0.27247240 0.9060644  0.28997787 -0.23409565
#> 3   536004.16   80971.484  0.17194227 0.8687823  0.08556123 -0.05780273
#> 4   512741.95    8408.668 -0.39597048 0.8242861 -0.60279324 -0.73661717
#> 5 41188862.04 8651866.687  0.01126973 0.9281709 -0.17972587 -0.40129440
#> 6    20322.33    3201.696 -0.38536114 0.8395461 -0.56036199 -0.72372407
#>     y_pacf5 diff1y_pacf5 diff2y_pacf5 nonlinearity lmres_acf1        ur_pp
#> 1 0.7317718    0.4678099    0.7872667   0.09788676 0.43737025  1.600224447
#> 2 0.9134830    0.3685785    0.3087412   8.03078490 0.72996605 -0.331484960
#> 3 0.8003519    0.3633001    0.4027709   1.87585478 0.67234619  0.761913821
#> 4 0.8029142    0.4082855    0.7547024   1.06354893 0.01395566  0.006654736
#> 5 0.9211049    0.0870958    0.2514310   2.42522204 0.66419101 -0.426695213
#> 6 0.7516687    0.3981432    1.0484015   0.29465502 0.34441088  0.664898414
#>      ur_kpss  N   y_acf5 diff1y_acf5 diff2y_acf5        alpha         beta
#> 1 0.21070271 22 1.836573  0.43635058  0.17487483 0.1350376735 0.1350376734
#> 2 0.16817558 23 2.192964  0.25237684  0.27786274 0.9998999584 0.5437148338
#> 3 0.20361099 23 1.959167  0.37443160  0.20979630 0.4413862921 0.1354501704
#> 4 0.08654678 23 2.049330  0.48071760  0.10950686 0.0001000893 0.0001000886
#> 5 0.20202815 39 2.872714  0.09763561  0.08923302 0.6774775679 0.0326474990
#> 6 0.20347758 25 1.934410  0.34526089  0.14236605 0.1413996697 0.1413403346
#>   classlabels
#> 1   ETS-trend
#> 2         rwd
#> 3   ETS-trend
#> 4         rwd
#> 5       ARIMA
#> 6   ETS-trend

# provides additional information about the fitted models
head(prep_tset$modelinfo)
#>                ARIMA_name   ETS_name min_label             model_names
#> 1 ARIMA(0,1,0) with drift ETS(A,A,N)       ets              ETS(A,A,N)
#> 2 ARIMA(0,1,1) with drift ETS(M,A,N)       rwd                     rwd
#> 3 ARIMA(0,1,2) with drift ETS(M,A,N)       ets              ETS(M,A,N)
#> 4 ARIMA(1,1,0) with drift ETS(M,A,N)       rwd                     rwd
#> 5 ARIMA(0,1,1) with drift ETS(M,A,N)     arima ARIMA(0,1,1) with drift
#> 6 ARIMA(1,1,0) with drift ETS(M,A,N)       ets              ETS(M,A,N)
```

#### FFORMS: online phase is activated.

**5. Train a random forest and predict class labels for new series (FFORMS: online phase)**

`build_rf` in the `seer` package enables the training of a random forest model and predict class labels ("best" forecast-model) for new time series. In the following example we use only yearly series of the M1 and M3 competitions to illustrate the code. A random forest classifier is build based on the yearly series on M1 data and predicted class labels for yearly series in the M3 competition.

``` r
rf <- build_rf(training_set = prep_tset$trainingset, testset=M3yearly_features,  rf_type="rcp", ntree=100, seed=1, import=FALSE)

# to get the predicted class labels
predictedlabels_m3 <- rf$predictions
table(predictedlabels_m3)
#> predictedlabels_m3
#>                 ARIMA            ARMA/AR/MA       ETS-dampedtrend 
#>                    49                     2                     0 
#> ETS-notrendnoseasonal             ETS-trend                    nn 
#>                     0                    58                     8 
#>                    rw                   rwd                 theta 
#>                     7                   516                     4 
#>                    wn 
#>                     1

# to obtain the random forest for future use
randomforest <- rf$randomforest
```

**6. Generate point foecasts and 95% prediction intervals**

`rf_forecast` function can be used to generate point forecasts and 95% prediction intervals based on the predicted class labels obtained in step 5.

``` r
forecasts <- rf_forecast(predictions=predictedlabels_m3[1:2], tslist=yearly_m3[1:2], database="M3", function_name="cal_MASE", h=6, accuracy=TRUE)

# to obtain point forecasts
forecasts$mean
#>          [,1]     [,2]     [,3]     [,4]     [,5]     [,6]
#> [1,] 5486.429 6035.865 6585.301 7134.737 7684.173 8233.609
#> [2,] 4402.227 4574.454 4746.681 4918.908 5091.135 5263.362

# to obtain lower boundary of 95% prediction intervals
forecasts$lower
#>          [,1]     [,2]     [,3]     [,4]     [,5]      [,6]
#> [1,] 4984.162 4893.098 4629.135 4199.745 3606.858 2848.8735
#> [2,] 2890.401 2366.671 1959.916 1608.186 1288.666  990.2221

# to obtain upper boundary of 95% prediction intervals
forecasts$upper
#>          [,1]     [,2]     [,3]      [,4]      [,5]      [,6]
#> [1,] 5988.696 7178.632 8541.467 10069.729 11761.488 13618.344
#> [2,] 5914.053 6782.236 7533.445  8229.629  8893.603  9536.501

# to obtain MASE
forecasts$accuracy
#> [1] 1.5636089 0.6123443
```
