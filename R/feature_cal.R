#' Calculate features for new time series instances
#'
#' Computes relevant time series features before applying them to the model
#' @param ts_data_set a list of univariate time series
#' @param seasonal if FALSE, restricts to features suitable for non-seasonal data
#' @param m frequency of the time series
#' @param lagmax maximum lag at which to calculate the acf (quarterly series-5L and monthly-13L)
#' @return dataframe: each column represent a feature and each row represent a time series
#' @author Thiyanga Talagala
#' @export
cal_features <- function(ts_data_set, seasonal=FALSE, m=1, lagmax=2L){ # ts_data_set = yearly_m1,

  train <- lapply(ts_data_set, function(temp){temp$x})
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

  seer_features_nonseasonal <- lapply(ts_data_set, function(temp1){c(
                                                         e_acf1(temp1$x),
                                                         unitroot(temp1$x))})
  seer_features_nonseasonal_DF <- as.data.frame(do.call("rbind", seer_features_nonseasonal))
  ts_features <- dplyr::bind_cols(ts_features1, seer_features_nonseasonal_DF)

    } else {
  ts_features1 <- ts_features_pkg %>% dplyr::select ("entropy", "lumpiness", "stability", "hurst",
                                                      "trend", "spike", "linearity", "curvature",
                                                      "e_acf1", "x_acf1", "diff1_acf1", "diff2_acf1",
                                                      "x_pacf5","diff1x_pacf5", "diff2x_pacf5", "alpha",
                                                      "beta","nonlinearity", "seasonal_strength",
                                                    "seas_pacf")

  seer_features_seasonal <- lapply(ts_data_set, function(temp1){c(holtWinter_parameters(temp1$x),
    acf_seasonalDiff(temp1$x, m, lagmax))})

  seer_features_seasonal_DF <- as.data.frame(do.call("rbind", seer_features_seasonal))

  ts_features <- dplyr::bind_cols(ts_features1, seer_features_seasonal_DF)

  }

  ts_featuresDF <- as.data.frame(ts_features)

  ts_featuresDF <- dplyr::rename(ts_featuresDF, spikiness = spike)
  ts_featuresDF <- dplyr::rename(ts_featuresDF, y_acf1 = x_acf1)
  ts_featuresDF <- dplyr::rename(ts_featuresDF, diff1y_acf1 = diff1_acf1)
  ts_featuresDF <- dplyr::rename(ts_featuresDF, diff2y_acf1 = diff2_acf1)
  ts_featuresDF <- dplyr::rename(ts_featuresDF, y_pacf5 = x_pacf5)
  ts_featuresDF <- dplyr::rename(ts_featuresDF, diff1y_pacf5 = diff1x_pacf5)
  ts_featuresDF <- dplyr::rename(ts_featuresDF, diff2y_pacf5 = diff2x_pacf5)

  if(seasonal==TRUE){
  ts_featuresDF <- dplyr::rename(ts_featuresDF, seasonality = seasonal_strength)
  }

  length <- lapply(ts_data_set, function(temp){length(temp$x)})
  length <- unlist(length)
  ts_featuresDF$N <- length

  seer_features <- lapply(ts_data_set, function(temp1){acf5(temp1$x)})
  seer_feature_DF <- as.data.frame(do.call("rbind", seer_features))

  featureDF <- dplyr::bind_cols(ts_featuresDF,seer_feature_DF)
  return(featureDF)

}
#'@examples
#'require(Mcomp)
#'data(M3)
#'yearly_m3 <- subset(M3, "yearly")
#'cal_features(yearly_m3)
#'@examples
#'require(Mcomp)
#'data(M3)
#'quarterly_m3 <- subset(M3, "quarterly")
#'cal_features(quarterly_m3, seasonal=TRUE, m=4, lagmax=5L)


