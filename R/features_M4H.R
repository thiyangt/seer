#' features of hourly series of the M4-competition data
#'
#' @description 26 features calculated on hourly series of the M4-competition data
#' @format dataframe of 26 columns and 414 rows
#' \describe{
#' \item{entropy}{entropy}
#' \item{lumpiness}{lumpiness}
#' \item{stability}{stability}
#' \item{hurst}{Hurst exponent}
#' \item{trend}{strength of trend}
#' \item{spikiness}{spikiness}
#' \item{linearity}{linearity}
#' \item{curvature}{curvature}
#' \item{e_acf1}{first autocorrelation coefficient of the remainder series}
#' \item{y_acf1}{first autocorrelation coefficient of the original series}
#' \item{diff1y_acf1}{first autocorrelation coefficient of the differenced series}
#' \item{diff2y_acf1}{first autocorrelation coefficient of the twiced diffeenced series}
#' \item{y_pacf5}{}
#' \item{diff1y_pacf5}{}
#' \item{diff2y_pacf5}{}
#' \item{nonlinearity}{nonlinearity}
#' \item{seas_pacf}{}
#' \item{seasonal_strength1}{strength of seasonality of the first freq}
#' \item{seasonal_strength2}{strength of seasonality of the second freq}
#' \item{sediff_acf1}{sediff_acf1}
#' \item{sediff_seacf1}{sediff_seacf1}
#' \item{sediff_acf5}{sediff_acf5}
#' \item{N}{length}
#' \item{y_acf5}{y_acf5}
#' \item{diff1y_acf5}{diff1y_acf5}
#' \item{diff2y_acf5}{diff2y_acf5}
#' }
"features_M4H"
