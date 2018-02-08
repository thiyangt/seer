#' Data related to experiment 1 - yearly series
#' @description Data set related to Experiment 1 in yearly data
#' @format A data frame with 362181 rows and 38 variables
#' \describe{
#' \item{entropy}{spectral entropy}
#' \item{stability}{stability}
#' \item{hurst}{Hurst exponent}
#' \item{trend}{strength of trend}
#' \item{linearity}{linearity}
#' \item{y_acf1}{first autocorrelation coefficient of the original series}
#' \item{diff1y_acf1}{first autocorrelation coefficient of the differenced series}
#' \item{diff2y_acf1}{first autocorrelation coefficient of the twiced-differenced series}
#' \item{y_pacf5}{sum of squared of first 5 partial autoorrelation coefficient of the original series}
#' \item{diff1y_pacf5}{sum of squared of first 5 partial autocorrelation coefficients of the differenced series}
#' \item{diff2y_pacf5}{sum of squared of first 5 partial autocorrelation coefficients of the twiced-differenced series}
#' \item{beta}{Holt's linear trend model-beta hat}
#' \item{nonlinearity}{nonlinearity}
#' \item{N}{length of the time series}
#' \item{y_acf5}{sum of squared of first 5 autocorrelation coefficients of the original series}
#' \item{diff1y_acf5}{sum of squared of first 5 autocorrelation coefficients of the differenced series}
#' \item{diff2y_acf5}{sum of squared of first 5 autocorrelation coefficients of the twiced-differenced series}
#' \item{lmres_acf1}{first autocorelation coefficient of the residual series of linear trend model}
#' \item{ur_pp}{test statistics based on Phillips-Perron test}
#' \item{ur_kpss}{test statistics based on KPSS test}
#' \item{curvature}{curvature}
#' \item{spikiness}{spikiness}
#' \item{e_acf1}{first autocorrelation coefficient of the remainder series}
#' \item{lumpiness}{lumpiness}
#' \item{alpha}{Holt's linear trend model-alpha_hat}
#' \item{classlabel}{"best" forecasting method according to MASE}
#' \item{datasource}{M1 or simulated series based on M1}
#' \item{ETS}{MASE for the ETS model}
#' \item{ARIMA}{MASE for the ARIMA model}
#' \item{RW}{MASE for the RW model}
#' \item{RWD}{MASE for the RWD model}
#' \item{WN}{MASE for the WN model}
#' \item{Theta}{MASE for the Theta model}
#' \item{STL-AR}{MASE for the STL-AR model}
#' \item{SNAIVE}{MASE for the SNAIVE model}
#' \item{ETS_model}{model corresponds to the ETS model}
#' \item{ARIMA_model}{model corresponds to the ARIMA model}
#' \item{WN_model}{mean zero or not}}
#' @examples
#' data(yearly_exp1)
#' head(yearly_exp1)
#' summary(yearly_exp1)
"yearly_exp1"