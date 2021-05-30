
# seer <img src="logo/seer.png" align="right" height="200"/>

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/seer)](https://CRAN.R-project.org/package=seer)
[![Project Status: Active ? The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/)
[![Build
Status](https://travis-ci.org/thiyangt/seer.svg?branch=master)](https://travis-ci.org/thiyangt/seer)
[![Codecov test
coverage](https://codecov.io/gh/thiyangt/seer/branch/master/graph/badge.svg)](https://codecov.io/gh/thiyangt/seer?branch=master)
[![](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://lifecycle.r-lib.org/articles/stages.html)

[![Downloads](http://cranlogs.r-pkg.org/badges/seer)](https://cran.r-project.org/package=seer)

-----

The `seer` package provides implementations of a novel framework for
forecast model selection using time series features. We call this
framework **FFORMS** (**F**eature-based **FOR**ecast **M**odel
**S**election). For more details see our
[paper](https://www.monash.edu/business/econometrics-and-business-statistics/research/publications/ebs/wp06-2018.pdf).

## Installation

You could install the stable version on CRAN:

``` r
install.packages("seer")
```

You could install the development version from Github using

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
#>  [1] 5534.099 5995.760 6302.127 6536.581 6776.046 6918.663 7080.150 7169.312
#>  [9] 7340.848 7534.329 7663.929 7764.886 7849.713 7804.574 7615.224 7505.023
#> [17] 7344.680 7281.240 7116.566 6906.528
#> 
#> $N0001[[2]]
#> Time Series:
#> Start = 1989 
#> End = 2008 
#> Frequency = 1 
#>  [1]  5508.345  6158.141  6946.140  7794.654  8515.908  9282.426  9955.063
#>  [8] 10593.672 11405.297 12095.897 12678.783 13214.190 13665.467 13901.732
#> [15] 14115.241 14359.307 14611.216 14887.513 15265.617 15609.553
#> 
#> 
#> $N0002
#> $N0002[[1]]
#> Time Series:
#> Start = 1989 
#> End = 2008 
#> Frequency = 1 
#>  [1] 5088.146 5885.185 6845.827 6322.167 7306.801 8461.032 8863.206 8657.404
#>  [9] 9196.772 9631.682 9830.043 9064.453 8912.493 8957.574 8857.515 7650.728
#> [17] 7434.835 8542.394 8442.969 7380.074
#> 
#> $N0002[[2]]
#> Time Series:
#> Start = 1989 
#> End = 2008 
#> Frequency = 1 
#>  [1] 4460.817 3875.687 4421.132 4160.590 4533.950 4246.915 4234.774 4285.818
#>  [9] 4193.622 5746.810 5825.214 4901.483 4370.983 5563.797 4338.189 3745.741
#> [17] 4776.466 5415.168 6318.543 5896.778
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
#>   entropy lumpiness stability hurst trend   spikiness linearity curvature e_acf1
#>     <dbl>     <dbl>     <dbl> <dbl> <dbl>       <dbl>     <dbl>     <dbl>  <dbl>
#> 1   0.568         0         0 0.971 0.995 0.000000237     3.58      0.424  0.412
#> 2   0.745         0         0 0.947 0.869 0.000179        2.05     -2.08   0.324
#> 3   0.423         0         0 0.949 0.865 0.000193        1.75     -2.26   0.457
#> 4   0.513         0         0 0.949 0.853 0.000368        2.87     -1.25   0.281
#> 5   0.553         0         0 0.855 0.586 0.00127        -0.765    -1.77   0.192
#> 6   0.709         0         0 0.964 0.964 0.0000217       3.56     -0.574  0.181
#> # … with 16 more variables: y_acf1 <dbl>, diff1y_acf1 <dbl>, diff2y_acf1 <dbl>,
#> #   y_pacf5 <dbl>, diff1y_pacf5 <dbl>, diff2y_pacf5 <dbl>, nonlinearity <dbl>,
#> #   lmres_acf1 <dbl>, ur_pp <dbl>, ur_kpss <dbl>, N <int>, y_acf5 <dbl>,
#> #   diff1y_acf5 <dbl>, diff2y_acf5 <dbl>, alpha <dbl>, beta <dbl>
```

**Calculate features from the simulated time series in the step 1**

``` r
features_simulated_arima <- lapply(simulated_arima, function(temp){
    lapply(temp, cal_features, h=6, database="other", highfreq=FALSE)})
fea_sim <- lapply(features_simulated_arima, function(temp){do.call(rbind, temp)})
do.call(rbind, fea_sim)
#> # A tibble: 4 x 25
#>   entropy lumpiness stability hurst trend  spikiness linearity curvature  e_acf1
#> *   <dbl>     <dbl>     <dbl> <dbl> <dbl>      <dbl>     <dbl>     <dbl>   <dbl>
#> 1   0.468         0         0 0.970 0.992    8.21e-7      3.53    -0.659 0.107  
#> 2   0.426         0         0 0.973 0.999    1.28e-8      3.56    -0.234 0.292  
#> 3   0.144         0         0 0.961 0.946    2.04e-5      3.00    -1.25  0.00722
#> 4   0.967         0         0 0.733 0.426    3.75e-3      2.21     0.621 0.0380 
#> # … with 16 more variables: y_acf1 <dbl>, diff1y_acf1 <dbl>, diff2y_acf1 <dbl>,
#> #   y_pacf5 <dbl>, diff1y_pacf5 <dbl>, diff2y_pacf5 <dbl>, nonlinearity <dbl>,
#> #   lmres_acf1 <dbl>, ur_pp <dbl>, ur_kpss <dbl>, N <int>, y_acf5 <dbl>,
#> #   diff1y_acf5 <dbl>, diff2y_acf5 <dbl>, alpha <dbl>, beta <dbl>
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
#> [1,] 1.566974 1.5636089 7.703518 4.2035176 6.017236 2.3901616
#> [2,] 1.698388 0.9229687 1.698388 0.6123443 1.096000 0.2800797
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
#> [1,] 5517.188 4789.839
#> [2,] 6080.367 5059.654
#> [3,] 6570.262 5150.664
#> [4,] 6948.022 5176.791
#> [5,] 7208.472 5183.907
#> [6,] 7372.778 5185.816
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
#>   entropy lumpiness stability hurst trend  spikiness linearity curvature  e_acf1
#>     <dbl>     <dbl>     <dbl> <dbl> <dbl>      <dbl>     <dbl>     <dbl>   <dbl>
#> 1   0.442   0.0400      0.977 0.985 0.985 0.00000132      4.46    0.705  -0.0603
#> 2   0.363   0.0790      0.894 0.988 0.989 0.00000154      4.47    0.613   0.272 
#> 3   0.379   0.0160      0.858 0.987 0.989 0.00000113      4.60    0.695   0.172 
#> 4   0.363   0.00201     1.32  0.982 0.957 0.00000896      4.48    0.0735 -0.396 
#> 5   0.156   0.00112     0.446 0.993 0.973 0.00000180      5.77    1.21    0.0113
#> 6   0.441   0.00774     0.578 0.986 0.975 0.00000331      4.75    0.748  -0.385 
#> # … with 17 more variables: y_acf1 <dbl>, diff1y_acf1 <dbl>, diff2y_acf1 <dbl>,
#> #   y_pacf5 <dbl>, diff1y_pacf5 <dbl>, diff2y_pacf5 <dbl>, nonlinearity <dbl>,
#> #   lmres_acf1 <dbl>, ur_pp <dbl>, ur_kpss <dbl>, N <int>, y_acf5 <dbl>,
#> #   diff1y_acf5 <dbl>, diff2y_acf5 <dbl>, alpha <dbl>, beta <dbl>,
#> #   classlabels <chr>

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
#> Warning in if (testset == FALSE) {: the condition has length > 1 and only the
#> first element will be used

# to get the predicted class labels
predictedlabels_m3 <- rf$predictions
table(predictedlabels_m3)
#> predictedlabels_m3
#>                 ARIMA            ARMA/AR/MA       ETS-dampedtrend 
#>                    64                     0                     0 
#> ETS-notrendnoseasonal             ETS-trend                    nn 
#>                     3                    23                    11 
#>                    rw                   rwd                 theta 
#>                     4                   528                     7 
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
#>          [,1]     [,2]     [,3]     [,4]     [,5]     [,6]
#> [1,] 4984.162 4893.098 4629.135 4199.745 3606.858 2848.873
#> [2,] 2941.377 2430.512 2028.738 1677.572 1355.680 1052.743

# to obtain upper boundary of 95% prediction intervals
forecasts$upper
#>          [,1]     [,2]     [,3]      [,4]      [,5]     [,6]
#> [1,] 5988.696 7178.632 8541.467 10069.729 11761.488 13618.34
#> [2,] 5863.077 6718.396 7464.623  8160.243  8826.589  9473.98

# to obtain MASE
forecasts$accuracy
#> [1] 1.5636089 0.6123443
```

#### Notes

**Calculation of features for daily
series**

``` r
# install.packages("https://github.com/carlanetto/M4comp2018/releases/download/0.2.0/M4comp2018_0.2.0.tar.gz",
#                 repos=NULL)
library(M4comp2018)
data(M4)
# extract first two daily time series
M4_daily <- Filter(function(l) l$period == "Daily", M4)
# convert daily series into msts objects
M4_daily_msts <- lapply(M4_daily, function(temp){
  temp$x <- convert_msts(temp$x, "daily")
  return(temp)
})
# calculate features
seer::cal_features(M4_daily_msts, seasonal=TRUE, h=14, m=7, lagmax=8L, database="M4", highfreq=TRUE)
#> # A tibble: 4,227 x 26
#>    entropy lumpiness stability hurst trend spikiness linearity curvature e_acf1
#>      <dbl>     <dbl>     <dbl> <dbl> <dbl>     <dbl>     <dbl>     <dbl>  <dbl>
#>  1 0.00950   0.00214     0.621 1.00  0.993  1.09e-10     31.1      3.09   0.976
#>  2 0.211     0.331       0.446 1.00  0.865  2.53e- 8     24.7      1.35   0.986
#>  3 0.610     0.755       0.761 0.999 0.917  4.49e- 6      3.82     4.89   0.318
#>  4 0.741     0.168       0.821 0.996 0.841  3.86e- 6      1.87     6.38   0.290
#>  5 0.281     0.0140      0.991 1.00  0.988  4.64e- 8     11.3      0.878  0.376
#>  6 0.0430    0.00136     0.242 1.00  0.989  1.90e-10     29.8      8.27   0.973
#>  7 0.412     0.247       0.697 0.999 0.845  2.38e- 8     24.1      1.96   0.809
#>  8 0.141     0.0189      1.01  1.00  0.968  2.31e- 9     30.1     -4.98   0.963
#>  9 0.213     0.0275      1.07  1.00  0.954  4.69e- 9     29.3     -6.67   0.963
#> 10 0.438     0.00110     0.974 1.00  0.989  8.77e-10     18.3     -3.60   0.346
#> # … with 4,217 more rows, and 17 more variables: y_acf1 <dbl>,
#> #   diff1y_acf1 <dbl>, diff2y_acf1 <dbl>, y_pacf5 <dbl>, diff1y_pacf5 <dbl>,
#> #   diff2y_pacf5 <dbl>, nonlinearity <dbl>, seas_pacf <dbl>,
#> #   seasonal_strength1 <dbl>, seasonal_strength2 <dbl>, sediff_acf1 <dbl>,
#> #   sediff_seacf1 <dbl>, sediff_acf5 <dbl>, N <int>, y_acf5 <dbl>,
#> #   diff1y_acf5 <dbl>, diff2y_acf5 <dbl>
```

**Calculation of features for hourly series**

``` r
data(M4)
# extract first two daily time series
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
#>   entropy lumpiness stability hurst trend   spikiness linearity curvature e_acf1
#>     <dbl>     <dbl>     <dbl> <dbl> <dbl>       <dbl>     <dbl>     <dbl>  <dbl>
#> 1   0.282    0.0110    0.0899 0.999 0.626     1.92e-8      5.33    -3.51   0.958
#> 2   0.284    0.0505    0.109  0.999 0.790     6.39e-9      7.85    -0.152  0.974
#> # … with 17 more variables: y_acf1 <dbl>, diff1y_acf1 <dbl>, diff2y_acf1 <dbl>,
#> #   y_pacf5 <dbl>, diff1y_pacf5 <dbl>, diff2y_pacf5 <dbl>, nonlinearity <dbl>,
#> #   seas_pacf <dbl>, seasonal_strength1 <dbl>, seasonal_strength2 <dbl>,
#> #   sediff_acf1 <dbl>, sediff_seacf1 <dbl>, sediff_acf5 <dbl>, N <int>,
#> #   y_acf5 <dbl>, diff1y_acf5 <dbl>, diff2y_acf5 <dbl>
```

# Forecast combinations based on FFORMS algorithm

``` r
# extract only the values for two time series just for illustration
yearly_m1_features <- features_m1[1:2,]
votes.matrix <- predict(rf$randomforest, yearly_m1_features, type="vote")
tslist <- yearly_m1[1:2]
# To identify models and weights for forecast combination
models_and_weights_for_combinations <- fforms_ensemble(votes.matrix, threshold=0.6)
# Compute combination forecast
fforms_combinationforecast(models_and_weights_for_combinations, tslist, "M1", 6)
#> [[1]]
#> [[1]]$mean
#>          [,1]   [,2]     [,3]     [,4]     [,5]     [,6]
#> [1,] 556280.7 594333 632385.3 670437.6 708489.9 746542.3
#> 
#> [[1]]$lower
#>          [,1]     [,2]     [,3]     [,4]     [,5]     [,6]
#> [1,] 495633.6 530117.6 561088.8 588269.7 611931.4 632551.3
#> 
#> [[1]]$upper
#>          [,1]     [,2]     [,3]     [,4]     [,5]     [,6]
#> [1,] 616927.8 658548.4 703681.8 752605.5 805048.5 860533.2
#> 
#> 
#> [[2]]
#> [[2]]$mean
#>          [,1]     [,2]     [,3]     [,4]     [,5]     [,6]
#> [1,] 400921.2 417802.4 434683.5 451564.7 468445.9 485327.1
#> 
#> [[2]]$lower
#>          [,1]     [,2]     [,3]     [,4]     [,5]     [,6]
#> [1,] 357623.1 355193.4 356354.4 359252.9 363194.2 367833.3
#> 
#> [[2]]$upper
#>          [,1]     [,2]     [,3]     [,4]     [,5]     [,6]
#> [1,] 444219.3 480411.3 513012.7 543876.6 573697.6 602820.9
```
