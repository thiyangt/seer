
# seer <img src="logo/seer.png" align="right" height="200"/>

[![Project Status: Active ? The project has reached a stable, usable
state and is being actively
developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![Build
Status](https://travis-ci.org/thiyangt/seer.svg?branch=master)](https://travis-ci.org/thiyangt/seer)
[![Github All
Releases](https://img.shields.io/github/downloads/atom/atom/total.svg)]()

-----

The `seer` package provides implementations of a novel framework for
forecast model selection using time series features. We call this
framework **FFORMS** (**F**eature-based **FOR**ecast **M**odel
**S**election). For more details see our
[paper](https://www.monash.edu/business/econometrics-and-business-statistics/research/publications/ebs/wp06-2018.pdf).

## Installation

You can install seer from github with:

``` r
# install.packages("devtools")
devtools::install_github("thiyangt/seer")
library(seer)
```

## Usage

The FFORMS framework consists of two main phases: i) offline phase,
which includes the development of a classification model and ii) online
phase, use the classification model developed in the offline phase to
identify “best” forecast-model. This document explains the main
functions using a simple dataset based on M3-competition data. To load
data,

``` r
library(Mcomp)
data(M3)
yearly_m3 <- subset(M3, "yearly")
m3y <- M3[1:2]
```

#### FFORMS: offline phase

**1. Augmenting the observed sample with simulated time series.**

We augment our reference set of time series by simulating new time
series. In order to produce simulated series, we use several standard
automatic forecasting algorithms such as ETS or automatic ARIMA models,
and then simulate multiple time series from the selected model within
each model class. `sim_arimabased` can be used to simulate time series
based on (S)ARIMA models.

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
#>  [1]  5490.955  6119.117  6749.191  7436.306  7993.662  8609.019  9157.780
#>  [8]  9608.814 10130.749 10562.936 10950.964 11320.067 11525.691 11546.358
#> [15] 11487.008 11381.722 11436.578 11433.000 11276.212 11126.866
#> 
#> $N0001[[2]]
#> Time Series:
#> Start = 1989 
#> End = 2008 
#> Frequency = 1 
#>  [1]  5396.029  5806.479  6071.970  6313.744  6450.769  6712.097  7094.863
#>  [8]  7333.391  7688.369  8096.339  8552.904  9052.463  9806.651 10630.349
#> [15] 11352.306 12280.316 13153.266 14125.454 15098.500 15960.031
#> 
#> 
#> $N0002
#> $N0002[[1]]
#> Time Series:
#> Start = 1989 
#> End = 2008 
#> Frequency = 1 
#>  [1] 4132.367 5394.736 5878.636 7043.460 6323.953 6475.405 5874.627
#>  [8] 4922.770 5483.352 5824.077 7185.315 6738.272 7482.547 7787.055
#> [15] 6295.090 7749.083 6803.454 7423.936 8237.433 7583.395
#> 
#> $N0002[[2]]
#> Time Series:
#> Start = 1989 
#> End = 2008 
#> Frequency = 1 
#>  [1] 3215.185 3679.349 2212.228 2547.069 3295.008 4055.396 3433.749
#>  [8] 3734.993 3856.939 3678.168 4384.234 5470.493 7399.917 8538.066
#> [15] 7754.154 8330.420 8796.660 9118.638 8287.589 7253.959
```

Similarly, `sim_etsbased` can be used to simulate time series based on
ETS
models.

``` r
simulated_ets <- lapply(m3y, sim_etsbased, Future=TRUE, Nsim=2, extralength=6, Combine=FALSE)
simulated_ets
```

**2. Calculate features based on the training period of time series.**

Our proposed framework operates on the features of the time series.
`cal_features` function can be used to calculate relevant features for a
given list of time series.

``` r
library(tsfeatures)
M3yearly_features <- seer::cal_features(yearly_m3, database="M3", h=6, highfreq = FALSE)
head(M3yearly_features)
#> # A tibble: 6 x 25
#>   entropy lumpiness stability hurst trend spikiness linearity curvature
#>     <dbl>     <dbl>     <dbl> <dbl> <dbl>     <dbl>     <dbl>     <dbl>
#> 1   0.773         0         0 0.971 0.995   2.37e-7     3.58      0.424
#> 2   0.837         0         0 0.947 0.869   1.79e-4     2.05     -2.08 
#> 3   0.825         0         0 0.949 0.865   1.93e-4     1.75     -2.26 
#> 4   0.854         0         0 0.949 0.853   3.68e-4     2.87     -1.25 
#> 5   0.899         0         0 0.855 0.586   1.27e-3    -0.765    -1.77 
#> 6   0.798         0         0 0.964 0.964   2.17e-5     3.56     -0.574
#> # … with 17 more variables: e_acf1 <dbl>, y_acf1 <dbl>, diff1y_acf1 <dbl>,
#> #   diff2y_acf1 <dbl>, y_pacf5 <dbl>, diff1y_pacf5 <dbl>,
#> #   diff2y_pacf5 <dbl>, nonlinearity <dbl>, lmres_acf1 <dbl>, ur_pp <dbl>,
#> #   ur_kpss <dbl>, N <int>, y_acf5 <dbl>, diff1y_acf5 <dbl>,
#> #   diff2y_acf5 <dbl>, alpha <dbl>, beta <dbl>
```

**Calculate features from the simulated time series in the step 1**

``` r
features_simulated_arima <- lapply(simulated_arima, function(temp){
    lapply(temp, cal_features, h=6, database="other", highfreq=FALSE)})
fea_sim <- lapply(features_simulated_arima, function(temp){do.call(rbind, temp)})
do.call(rbind, fea_sim)
#> # A tibble: 4 x 25
#>   entropy lumpiness stability hurst trend spikiness linearity curvature
#> *   <dbl>     <dbl>     <dbl> <dbl> <dbl>     <dbl>     <dbl>     <dbl>
#> 1   0.771         0         0 0.973 0.998   6.87e-8      3.54    -0.450
#> 2   0.772         0         0 0.970 0.995   2.25e-7      3.58     0.582
#> 3   0.918         0         0 0.885 0.720   9.13e-4      2.73     0.383
#> 4   0.855         0         0 0.948 0.913   3.61e-5      3.03     1.50 
#> # … with 17 more variables: e_acf1 <dbl>, y_acf1 <dbl>, diff1y_acf1 <dbl>,
#> #   diff2y_acf1 <dbl>, y_pacf5 <dbl>, diff1y_pacf5 <dbl>,
#> #   diff2y_pacf5 <dbl>, nonlinearity <dbl>, lmres_acf1 <dbl>, ur_pp <dbl>,
#> #   ur_kpss <dbl>, N <int>, y_acf5 <dbl>, diff1y_acf5 <dbl>,
#> #   diff2y_acf5 <dbl>, alpha <dbl>, beta <dbl>
```

**3. Calculate forecast accuracy measure(s)**

`fcast_accuracy` function can be used to calculate forecast error
measure (in the following example MASE) from each candidate model. This
step is the most computationally intensive and time-consuming, as each
candidate model has to be estimated on each series. In the following
example ARIMA(arima), ETS(ets), random walk(rw), random walk with
drift(rwd), standard theta method(theta) and neural network time series
forecasts(nn) are used as possible models. In addition to these models
following models can also be used in the case of handling seasonal time
series,

  - snaive: seasonal naive method
  - stlar: STL decomposition is applied to the time series and then
    seasonal naive method is used to forecast seasonal component. AR
    model is used to forecast seasonally adjusted data.
  - mstlets: STL decomposition is applied to the time series and then
    seasonal naive method is used to forecast seasonal component. ETS
    model is used to forecast seasonally adjusted data.
  - mstlarima: STL decomposition is applied to the time series and then
    seasonal naive method is used to forecast seasonal component. ARIMA
    model is used to forecast seasonally adjusted data.
  - tbats: TBATS models

<!-- end list -->

``` r
tslist <- list(M3[[1]], M3[[2]])
accuracy_info <- fcast_accuracy(tslist=tslist, models= c("arima","ets","rw","rwd", "theta", "nn"), database ="M3", cal_MASE, h=6, length_out = 1, fcast_save = TRUE)
accuracy_info
#> $accuracy
#>         arima       ets       rw       rwd    theta        nn
#> [1,] 1.566974 1.5636089 7.703518 4.2035176 6.017236 2.3811074
#> [2,] 1.698388 0.9229687 1.698388 0.6123443 1.096000 0.2798625
#> 
#> $ARIMA
#> [1] "ARIMA(0,2,0)" "ARIMA(0,1,0)"
#> 
#> $ETS
#> [1] "ETS(M,A,N)" "ETS(M,A,N)"
#> 
#> $forecasts
#> $forecasts$arima
#>         [,1] [,2]
#> [1,] 5486.10 4230
#> [2,] 6035.21 4230
#> [3,] 6584.32 4230
#> [4,] 7133.43 4230
#> [5,] 7682.54 4230
#> [6,] 8231.65 4230
#> 
#> $forecasts$ets
#>          [,1]     [,2]
#> [1,] 5486.429 4347.678
#> [2,] 6035.865 4465.365
#> [3,] 6585.301 4583.052
#> [4,] 7134.737 4700.738
#> [5,] 7684.173 4818.425
#> [6,] 8233.609 4936.112
#> 
#> $forecasts$rw
#>         [,1] [,2]
#> [1,] 4936.99 4230
#> [2,] 4936.99 4230
#> [3,] 4936.99 4230
#> [4,] 4936.99 4230
#> [5,] 4936.99 4230
#> [6,] 4936.99 4230
#> 
#> $forecasts$rwd
#>         [,1]     [,2]
#> [1,] 5244.40 4402.227
#> [2,] 5551.81 4574.454
#> [3,] 5859.22 4746.681
#> [4,] 6166.63 4918.908
#> [5,] 6474.04 5091.135
#> [6,] 6781.45 5263.362
#> 
#> $forecasts$theta
#>         [,1]     [,2]
#> [1,] 5085.07 4321.416
#> [2,] 5233.19 4412.843
#> [3,] 5381.31 4504.269
#> [4,] 5529.43 4595.696
#> [5,] 5677.55 4687.122
#> [6,] 5825.67 4778.549
#> 
#> $forecasts$nn
#>          [,1]     [,2]
#> [1,] 5516.220 4791.116
#> [2,] 6078.902 5061.169
#> [3,] 6569.796 5151.823
#> [4,] 6950.277 5177.689
#> [5,] 7214.389 5184.688
#> [6,] 7382.268 5186.554
```

**4. Construct a dataframe of input:features and output:lables to train
a random forest**

`prepare_trainingset` can be used to create a data frame of
input:features and output: labels.

``` r
# steps 3 and 4 applied to yearly series of M1 competition
data(M1)
yearly_m1 <- subset(M1, "yearly")
accuracy_m1 <- fcast_accuracy(tslist=yearly_m1, models= c("arima","ets","rw","rwd", "theta", "nn"), database ="M1", cal_MASE, h=6, length_out = 1, fcast_save = TRUE)
features_m1 <- cal_features(yearly_m1, database="M1", h=6, highfreq = FALSE)

# prepare training set
prep_tset <- prepare_trainingset(accuracy_set = accuracy_m1, feature_set = features_m1)

# provides the training set to build a rf classifier
head(prep_tset$trainingset)
#> # A tibble: 6 x 26
#>   entropy lumpiness stability hurst trend spikiness linearity curvature
#>     <dbl>     <dbl>     <dbl> <dbl> <dbl>     <dbl>     <dbl>     <dbl>
#> 1   0.683   0.0400      0.977 0.985 0.985   1.32e-6      4.46    0.705 
#> 2   0.711   0.0790      0.894 0.988 0.989   1.54e-6      4.47    0.613 
#> 3   0.716   0.0160      0.858 0.987 0.989   1.13e-6      4.60    0.695 
#> 4   0.761   0.00201     1.32  0.982 0.957   8.96e-6      4.48    0.0735
#> 5   0.628   0.00112     0.446 0.993 0.973   1.80e-6      5.77    1.21  
#> 6   0.708   0.00774     0.578 0.986 0.975   3.31e-6      4.75    0.748 
#> # … with 18 more variables: e_acf1 <dbl>, y_acf1 <dbl>, diff1y_acf1 <dbl>,
#> #   diff2y_acf1 <dbl>, y_pacf5 <dbl>, diff1y_pacf5 <dbl>,
#> #   diff2y_pacf5 <dbl>, nonlinearity <dbl>, lmres_acf1 <dbl>, ur_pp <dbl>,
#> #   ur_kpss <dbl>, N <int>, y_acf5 <dbl>, diff1y_acf5 <dbl>,
#> #   diff2y_acf5 <dbl>, alpha <dbl>, beta <dbl>, classlabels <chr>

# provides additional information about the fitted models
head(prep_tset$modelinfo)
#> # A tibble: 6 x 4
#>   ARIMA_name              ETS_name   min_label model_names            
#>   <chr>                   <chr>      <chr>     <chr>                  
#> 1 ARIMA(0,1,0) with drift ETS(A,A,N) ets       ETS(A,A,N)             
#> 2 ARIMA(0,1,1) with drift ETS(M,A,N) rwd       rwd                    
#> 3 ARIMA(0,1,2) with drift ETS(M,A,N) ets       ETS(M,A,N)             
#> 4 ARIMA(1,1,0) with drift ETS(M,A,N) rwd       rwd                    
#> 5 ARIMA(0,1,1) with drift ETS(M,A,N) arima     ARIMA(0,1,1) with drift
#> 6 ARIMA(1,1,0) with drift ETS(M,A,N) ets       ETS(M,A,N)
```

#### FFORMS: online phase is activated.

**5. Train a random forest and predict class labels for new series
(FFORMS: online phase)**

`build_rf` in the `seer` package enables the training of a random forest
model and predict class labels (“best” forecast-model) for new time
series. In the following example we use only yearly series of the M1 and
M3 competitions to illustrate the code. A random forest classifier is
build based on the yearly series on M1 data and predicted class labels
for yearly series in the M3 competition. Users can further add the
features and classlabel information calculated based on the simulated
time
series.

``` r
rf <- build_rf(training_set = prep_tset$trainingset, testset=M3yearly_features,  rf_type="rcp", ntree=100, seed=1, import=FALSE, mtry = 8)
#> Warning in if (testset == "NA") {: the condition has length > 1 and only
#> the first element will be used

# to get the predicted class labels
predictedlabels_m3 <- rf$predictions
table(predictedlabels_m3)
#> predictedlabels_m3
#>                 ARIMA            ARMA/AR/MA       ETS-dampedtrend 
#>                    63                     2                     0 
#> ETS-notrendnoseasonal             ETS-trend                    nn 
#>                     3                    33                     8 
#>                    rw                   rwd                 theta 
#>                     3                   522                     6 
#>                    wn 
#>                     5

# to obtain the random forest for future use
randomforest <- rf$randomforest
```

**6. Generate point foecasts and 95% prediction intervals**

`rf_forecast` function can be used to generate point forecasts and 95%
prediction intervals based on the predicted class labels obtained in
step
5.

``` r
forecasts <- rf_forecast(predictions=predictedlabels_m3[1:2], tslist=yearly_m3[1:2], database="M3", function_name="cal_MASE", h=6, accuracy=TRUE)

# to obtain point forecasts
forecasts$mean
#>          [,1]     [,2]     [,3]     [,4]     [,5]     [,6]
#> [1,] 5486.429 6035.865 6585.301 7134.737 7684.173 8233.609
#> [2,] 4402.227 4574.454 4746.681 4918.908 5091.135 5263.362

# to obtain lower boundary of 95% prediction intervals
forecasts$lower
#>          [,1]     [,2]     [,3]     [,4]      [,5]      [,6]
#> [1,] 4984.162 4893.098 4629.135 4199.745 3606.8577 2848.8735
#> [2,] 2886.231 2282.484 1769.324 1294.985  841.7082  401.3586

# to obtain upper boundary of 95% prediction intervals
forecasts$upper
#>          [,1]     [,2]     [,3]      [,4]      [,5]     [,6]
#> [1,] 5988.696 7178.632 8541.467 10069.729 11761.488 13618.34
#> [2,] 5918.223 6866.424 7724.037  8542.831  9340.561 10125.36

# to obtain MASE
forecasts$accuracy
#> [1] 1.5636089 0.6123443
```

#### Notes

**Calculation of features for daily series**

``` r
library(M4comp2018)
# extract first two daily time series
M4_daily <- Filter(function(l) l$period == "Daily", M4)[1:2]
# convert daily series into msts objects
M4_daily_msts <- lapply(M4_daily, function(temp){
  temp$x <- convert_msts(temp$x, "daily")
  return(temp)
})
# calculate features
seer::cal_features(M4_daily_msts, seasonal=TRUE, h=14, m=7, lagmax=8L, database="M4", highfreq=TRUE)
#> Warning: Unknown columns: `seasonal_strength`
#> # A tibble: 2 x 26
#>   entropy lumpiness stability hurst trend spikiness linearity curvature
#>     <dbl>     <dbl>     <dbl> <dbl> <dbl>     <dbl>     <dbl>     <dbl>
#> 1   0.327   0.00214     0.621 1.000 0.993  1.09e-10      31.1      3.09
#> 2   0.369   0.331       0.446 1.000 0.865  2.53e- 8      24.7      1.35
#> # … with 18 more variables: e_acf1 <dbl>, y_acf1 <dbl>, diff1y_acf1 <dbl>,
#> #   diff2y_acf1 <dbl>, y_pacf5 <dbl>, diff1y_pacf5 <dbl>,
#> #   diff2y_pacf5 <dbl>, nonlinearity <dbl>, seas_pacf <dbl>,
#> #   seasonal_strength1 <dbl>, seasonal_strength2 <dbl>, sediff_acf1 <dbl>,
#> #   sediff_seacf1 <dbl>, sediff_acf5 <dbl>, N <int>, y_acf5 <dbl>,
#> #   diff1y_acf5 <dbl>, diff2y_acf5 <dbl>
```

**Calculation of features for hourly series**

``` r
M4_hourly <- Filter(function(l) l$period == "Hourly", M4)[1:2]
## convert data into msts object
hourlym4_msts <- lapply(M4_hourly, function(temp){
    temp$x <- convert_msts(temp$x, "hourly")
    return(temp)
})
cal_features(hourlym4_msts, seasonal=TRUE, m=24, lagmax=25L, 
                                                         database="M4", highfreq = TRUE)
#> Warning: Unknown columns: `seasonal_strength`
#> # A tibble: 2 x 26
#>   entropy lumpiness stability hurst trend spikiness linearity curvature
#>     <dbl>     <dbl>     <dbl> <dbl> <dbl>     <dbl>     <dbl>     <dbl>
#> 1   0.524    0.0110    0.0899 0.999 0.626   1.92e-8      5.33    -3.51 
#> 2   0.540    0.0505    0.109  0.999 0.790   6.39e-9      7.85    -0.152
#> # … with 18 more variables: e_acf1 <dbl>, y_acf1 <dbl>, diff1y_acf1 <dbl>,
#> #   diff2y_acf1 <dbl>, y_pacf5 <dbl>, diff1y_pacf5 <dbl>,
#> #   diff2y_pacf5 <dbl>, nonlinearity <dbl>, seas_pacf <dbl>,
#> #   seasonal_strength1 <dbl>, seasonal_strength2 <dbl>, sediff_acf1 <dbl>,
#> #   sediff_seacf1 <dbl>, sediff_acf5 <dbl>, N <int>, y_acf5 <dbl>,
#> #   diff1y_acf5 <dbl>, diff2y_acf5 <dbl>
```

# Pre-trained classifiers (WIP)

## Forecast hourly time series in the M4-competition data

``` r
data("hourly_fforms")
data("features_M4H")
fcast.models <- predict(hourly_fforms, features_M4H)
head(fcast.models)
#>     1     2     3     4     5     6 
#> tbats    nn stlar stlar    nn    nn 
#> Levels: mstlarima mstlets nn rw rwd snaive stlar tbats theta wn
table(fcast.models)
#> fcast.models
#> mstlarima   mstlets        nn        rw       rwd    snaive     stlar 
#>        93        54       119         0         0        50        39 
#>     tbats     theta        wn 
#>        58         0         1
```
