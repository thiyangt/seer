#' Calculate features for new time series instances
#'
#' Computes relevant time series features before applying them to the model
#' @param tslist a list of univariate time series
#' @param seasonal if FALSE, restricts to features suitable for non-seasonal data
#' @param m frequency of the time series
#' @param lagmax maximum lag at which to calculate the acf (quarterly series-5L and monthly-13L)
#' @param database whether the time series is from mcomp or other
#' @param h forecast horizon
#' @return dataframe: each column represent a feature and each row represent a time series
#' @importFrom magrittr %>%
#' @author Thiyanga Talagala
#' @export
cal_features <- function(tslist, seasonal=FALSE, m=1, lagmax=2L, database, h){ # tslist = yearly_m1,

  if (database == "other") {
    train_test <- lapply(tslist, function(temp){list(training=head_ts(temp,h), test=tail_ts(temp, h))})
  } else {
    train_test <- lapply(tslist, function(temp){list(training=temp$x, test=temp$xx)})
  }

  train <- lapply(train_test, function(temp){temp$training})
  ts_features_pkg <- tsfeatures::tsfeatures(train, c("entropy",
                                      "lumpiness",
                                      "stability",
                                      "hurst",
                                      "stl_features",
                                     "acf_features",
                                      "pacf_features",
                                      "holt_parameters",
                                      "nonlinearity"))
  if (seasonal==FALSE){
  ts_features1 <- ts_features_pkg %>% dplyr::select ("entropy", "lumpiness", "stability", "hurst",
            "trend", "spike", "linearity", "curvature",
            "e_acf1", "x_acf1", "diff1_acf1", "diff2_acf1",
            "x_pacf5","diff1x_pacf5", "diff2x_pacf5", "alpha",
            "beta","nonlinearity")

  seer_features_nonseasonal <- lapply(train, function(temp1){c(
                                                         e_acf1(temp1),
                                                         unitroot(temp1))})
  seer_features_nonseasonal_DF <- as.data.frame(do.call("rbind", seer_features_nonseasonal))
  ts_features <- dplyr::bind_cols(ts_features1, seer_features_nonseasonal_DF)

    } else {
  ts_features1 <- ts_features_pkg %>% dplyr::select ("entropy", "lumpiness", "stability", "hurst",
                                                      "trend", "spike", "linearity", "curvature",
                                                      "e_acf1", "x_acf1", "diff1_acf1", "diff2_acf1",
                                                      "x_pacf5","diff1x_pacf5", "diff2x_pacf5", "alpha",
                                                      "beta","nonlinearity", "seasonal_strength",
                                                    "seas_pacf")

  seer_features_seasonal <- lapply(train, function(temp1){c(holtWinter_parameters(temp1),
    acf_seasonalDiff(temp1, m, lagmax))})

  seer_features_seasonal_DF <- as.data.frame(do.call("rbind", seer_features_seasonal))

  ts_features <- dplyr::bind_cols(ts_features1, seer_features_seasonal_DF)

  }

  ts_featuresDF <- as.data.frame(ts_features)

  ts_featuresDF <- dplyr::rename(ts_featuresDF, "spikiness" = "spike")
  ts_featuresDF <- dplyr::rename(ts_featuresDF, "y_acf1" = "x_acf1")
  ts_featuresDF <- dplyr::rename(ts_featuresDF, "diff1y_acf1" = "diff1_acf1")
  ts_featuresDF <- dplyr::rename(ts_featuresDF, "diff2y_acf1" = "diff2_acf1")
  ts_featuresDF <- dplyr::rename(ts_featuresDF, "y_pacf5" = "x_pacf5")
  ts_featuresDF <- dplyr::rename(ts_featuresDF, "diff1y_pacf5" = "diff1x_pacf5")
  ts_featuresDF <- dplyr::rename(ts_featuresDF, "diff2y_pacf5" = "diff2x_pacf5")

  if(seasonal==TRUE){
  ts_featuresDF <- dplyr::rename(ts_featuresDF, "seasonality" = "seasonal_strength")
  }

  length <- lapply(train, function(temp){length(temp)})
  length <- unlist(length)
  ts_featuresDF$N <- length

  seer_features <- lapply(train, function(temp1){acf5(temp1)})
  seer_feature_DF <- as.data.frame(do.call("rbind", seer_features))

  featureDF <- dplyr::bind_cols(ts_featuresDF,seer_feature_DF)
  return(featureDF)

}
#'@examples
#'require(Mcomp)
#'data(M3)
#'yearly_m3 <- subset(M3, "yearly")
#'cal_features(yearly_m3, database="M3", h=6)
#'@examples
#'require(Mcomp)
#'data(M3)
#'quarterly_m3 <- subset(M3, "quarterly")
#'cal_features(quarterly_m3, seasonal=TRUE, m=4, lagmax=5L, database="M3", h=8)
#'@example
#'myts <- list(ts(rnorm(20)), ts(rnorm(25)))
#'cal_features(myts, database="other", h=6)


