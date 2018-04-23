#' build random forest classifier
#'
#' train a random forest model and predict forecast-models for new series
#' @param training_set data frame of features and class labels
#' @param testset features of new time series
#' @param ntree number of trees in the forest
#' @param rf_type whether ru(random forest based on unbiased sample) or rcp(random
#' forest based on class priors)
#' @param seed a vlue for seed
#' @param import Should importance of predictors be assessed?, TRUE of FALSE
#' @return a list containing the random forest and forecast-models for new series
#' @export
build_rf <- function(training_set, testset, rf_type=c("ru", "rcp"), ntree, seed, import=FALSE){

  training_set$classlabels <- as.factor(training_set$classlabels)
  # extract training columns
  # random forest based on unbiased sample
  if (rf_type=="ru"){
    set.seed(seed)
    rf <- randomForest::randomForest(classlabels~ .,
          data = training_set,importance = import, ntree=ntree, mtry=8)
  }
  # random forest based on class priors
  if (rf_type=="rcp"){
    classWT <- 1/as.vector(table(training_set$classlabels))
    set.seed(seed)
    rf <- randomForest::randomForest(classlabels~ .,
          data = training_set,importance = import, ntree=ntree, mtry=8,
          classwt=classWT)
  }

  predictions <- predict(rf, testset)
  out <- list(randomforest=rf, predictions=predictions)
  return(out)
}
