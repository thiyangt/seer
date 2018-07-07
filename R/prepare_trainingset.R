#' preparation of training set
#'
#' Preparation of a training set for random forest training
#' @param accuracy_set output from the fcast_accuracy
#' @param feature_set output from the cal_features
#' @return dataframe consisting features and classlabels
#' @importFrom magrittr %>%
#' @export
prepare_trainingset <- function(accuracy_set, feature_set){

  accuracy_measures <- as.data.frame(accuracy_set$accuracy)
  minimum_accuracy <- apply(accuracy_measures,1,min, na.rm=TRUE)
  inf_indices <- which(minimum_accuracy==Inf)
  na_indices <- which(is.na(minimum_accuracy)==TRUE)
  rmv_indices <- c(inf_indices, na_indices)
  accuracy_measures$ARIMA_name <- as.character(accuracy_set$ARIMA)
  accuracy_measures$ETS_name <- as.character(accuracy_set$ETS)
  training_set <- dplyr::bind_cols(feature_set, accuracy_measures)
  if(length(rmv_indices)!=0) {training_set <- training_set[-rmv_indices, ]}

  # find the classlabel corresponds to minimum
  colnames_accuracyMatrix <- colnames(accuracy_set$accuracy)
  df_accuracy <- dplyr::select(training_set, colnames_accuracyMatrix)
  training_set$min_label <- as.character(seer::classlabel(df_accuracy))
  training_set$model_names <- ifelse(training_set$min_label == "arima", training_set$ARIMA_name, training_set$min_label)
  training_set$model_names <- ifelse(training_set$min_label == "ets", training_set$ETS_name, training_set$model_names)
  training_set$model_names <- as.character(training_set$model_names)

  # classify labe names
  df_modnames <- split_names(training_set$model_names)
  classlabel <- classify_labels(df_modnames)
  training_set$classlabels <- classlabel
  # extract complete cases only
  drop.cols <- colnames(accuracy_set$accuracy)
  training_set <- training_set %>% dplyr::select(-dplyr::one_of(drop.cols))
  training_set <- training_set[complete.cases(training_set),]
  models <- tibble::tibble(ARIMA_name=training_set$ARIMA_name, ETS_name=training_set$ETS_name,
                       min_label=training_set$min_label, model_names=training_set$model_names)
  training_set <- dplyr::select(training_set, c(colnames(feature_set), "classlabels"))
  training_set <- tibble::as_tibble(training_set)
  train <- list(modelinfo=models, trainingset=training_set)

  return(train)
}
#'@example
#'library(Mcomp)
#'tslist <- list(M3[[1]], M3[[2]], M3[[3]], M3[[4]], M3[[5]])
#'acc_set <- fcast_accuracy(tslist=tslist,
#'models= c("arima","ets","rw","rwd", "theta", "nn", "snaive"),
#'database ="M3", cal_MASE, h=6)
#'fea_set <- cal_features(tslist, database="M3", h=6, highfreq=FALSE)
#'outcome <- prepare_trainingset(acc_set, fea_set)
#'outcome$trainingset
#'outcome$modelinfo

