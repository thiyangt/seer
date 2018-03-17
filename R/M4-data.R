#'M4-Competition data
#'
#'The time series from the M4 forecasting competition.
#'
#'@format M4 is a list of 100000 series of class \code{Mcomp}. Each series within \code{M4} is
#'of class \code{Mdata} with the following structure:
#'\describe{
#'   \item{sn}{Name of the series}
#'   \item{st}{Series number and period. For example "Y1" denotes first yearly series,
#'   "Q20" denotes 20th quarterly series and so on.}
#'   \item{n}{The number of observations in the time series}
#'   \item{h}{The number of required forecasts}
#'   \item{period}{Interval of the time series.
#'             Possible values are "Yearly", "Quarterly", "Monthly", "Weekly", "Daily" and "Hourly".}
#'   \item{type}{The type of series.
#'             Possible values for M4 are "Industry", "Macro", "Micro",
#'             "Demographic", "Finance", "Other".}
#'   \item{x}{A time series of length \code{n} (the historical data)}
#'   }
#'@author Thiyanga Talagala
#'@source
#'\url{https://www.m4.unic.ac.cy/}.
#'
#'@keywords datasets
#'@examples
#'library(Mcomp)
#'data(M4)
#'M4
#'plot(M4[[10000]]$x)
#'
"M4"
