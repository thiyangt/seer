#' Calculate features for new time series instances
#'
#' Computes relevant time series features before applying them to the model
#' @param tslist a list of univariate time series
#' @param seasonal if FALSE, restricts to features suitable for non-seasonal data
#' @param m frequency of the time series or minimum frequency in the case of msts objects
#' @param lagmax maximum lag at which to calculate the acf (quarterly series-5L, monthly-13L, weekly-53L, daily-8L, hourly-25L)
#' @param database whether the time series is from mcomp or other
#' @param h forecast horizon
#' @param highfreq whether the time series is weekly, daily or hourly
#' @return dataframe: each column represent a feature and each row represent a time series
#' @importFrom magrittr %>%
#' @importFrom utils head tail
#' @author Thiyanga Talagala
#' @export
cal_features <- function(tslist, seasonal=FALSE, m=1, lagmax=2L, database, h, highfreq){ # tslist = yearly_m1,

  if (database == "other") {
    train_test <- lapply(tslist, function(temp){list(training=head(temp,(length(temp)-h)), test=tail(temp, h))})
  } else {
    train_test <- lapply(tslist, function(temp){list(training=temp$x, test=temp$xx)})
  }

  train <- lapply(train_test, function(temp){temp$training})




  ts_features_pkg <- tsfeatures::tsfeatures(train, c("entropy",
                                      "lumpiness",
                                      "stability",
                                      "hurst",
                                     # "stl_features",
                                     "acf_features",
                                      "pacf_features",
                                      "nonlinearity"))


  # calculation of stl features: handling short and long time series
  stl_ftrs <- lapply(train, function(temp){
    length_temp <- length(temp)
   # tryCatch({
      #freq_temp <- frequency(temp)
      freq_temp <- m
   # }, error=function(e){freq_temp <- m})
    required_length <- 2*freq_temp+1
    if (length_temp >= required_length) {tsfeatures::tsfeatures(temp, features = c("stl_features"))
    } else {
    fcast_h <- required_length-length_temp
    fcast <- forecast::forecast(temp, fcast_h)$mean
    com <- ts(c(temp,fcast), start=start(temp), frequency=frequency(temp))
    tsfeatures::tsfeatures(com, features=c("stl_features"))
    }

  })

  if (highfreq==FALSE){
  stl_df <- as.data.frame(do.call("rbind", stl_ftrs))
  } else {
  stl_df <- dplyr::bind_rows(lapply(stl_ftrs, as.data.frame.list))
  namestldf <- names(stl_df)
  if ("seasonal_strength1" %in% namestldf==T & "seasonal_strength2" %in% namestldf ==T){
  stl_df$seasonal_strength1[is.na(stl_df$seasonal_strength1)==TRUE] =
    stl_df$seasonal_strength[is.na(stl_df$"seasonal_strength")==FALSE]
  stl_df$seasonal_strength2[is.na(stl_df$seasonal_strength2)==TRUE]=0
  stl_df <- stl_df %>% dplyr::select(-dplyr::one_of("seasonal_strength"))
  }
  }

  ts_features_pkg <- dplyr::bind_cols(ts_features_pkg,stl_df)

  if (seasonal==FALSE){
  ts_features1 <- ts_features_pkg %>% dplyr::select ("entropy", "lumpiness", "stability", "hurst",
            "trend", "spike", "linearity", "curvature",
            "e_acf1", "x_acf1", "diff1_acf1", "diff2_acf1",
            "x_pacf5","diff1x_pacf5", "diff2x_pacf5", "nonlinearity")

  seer_features_nonseasonal <- lapply(train, function(temp1){c(
                                                         seer::e_acf1(temp1),
                                                         seer::unitroot(temp1))})
  seer_features_nonseasonal_DF <- as.data.frame(do.call("rbind", seer_features_nonseasonal))
  ts_features <- dplyr::bind_cols(ts_features1, seer_features_nonseasonal_DF)

    } else {
  ts_features_pkg_name <- names(ts_features_pkg)
  seasonalFeatures <- grep("seasonal_strength",ts_features_pkg_name, value = TRUE)
  select_features <- c("entropy", "lumpiness", "stability", "hurst",
                      "trend", "spike", "linearity", "curvature",
                      "e_acf1", "x_acf1", "diff1_acf1", "diff2_acf1",
                      "x_pacf5","diff1x_pacf5", "diff2x_pacf5","nonlinearity",
                      "seas_pacf", seasonalFeatures)

  ts_features1 <- ts_features_pkg %>% dplyr::select(select_features)
  if(highfreq==TRUE){
  seer_features_seasonal <- lapply(train, function(temp1){
    acf_seasonalDiff(temp1, m, lagmax)})
  } else {
    seer_features_seasonal <- lapply(train, function(temp1){
      hwf <- tsfeatures::hw_parameters(temp1)
      names(hwf) <- c("hwalpha", "hwbeta", "hwgamma")
      c(hwf, acf_seasonalDiff(temp1, m, lagmax))})
  }

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

  names_slt_df <- names(stl_df)
  if("seasonal_strength" %in% names_slt_df ==TRUE){
  ts_featuresDF <- dplyr::rename(ts_featuresDF, "seasonality" = "seasonal_strength")
  }

  length <- lapply(train, function(temp){length(temp)})
  length <- unlist(length)
  ts_featuresDF$N <- length

  if (highfreq==FALSE){
  seer_features <- lapply(train, function(temp1){c(seer::acf5(temp1), tsfeatures::holt_parameters(temp1))})
  } else {
    seer_features <- lapply(train, function(temp1){seer::acf5(temp1)})
  }

  seer_feature_DF <- as.data.frame(do.call("rbind", seer_features))

  featureDF <- dplyr::bind_cols(ts_featuresDF,seer_feature_DF)
  featureDF <- tibble::as_tibble(featureDF)
  return(featureDF)

}
#'@examples
#'require(Mcomp)
#'data(M3)
#'yearly_m3 <- subset(M3, "yearly")
#'cal_features(yearly_m3[1:3], database="M3", h=6, highfreq=FALSE)
#'@examples
#'require(Mcomp)
#'data(M3)
#'quarterly_m3 <- subset(M3, "quarterly")
#'cal_features(quarterly_m3[1:3], seasonal=TRUE, m=4, lagmax=5L, database="M3", h=8, highfreq=FALSE)
#'@example
#'myts <- list(ts(rnorm(20)), ts(rnorm(25)))
#'cal_features(myts, database="other", h=6, highfreq=FALSE)


