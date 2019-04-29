#' pre-trained random forest classifier for hourly data
#'
#' @description hourly random forest trained to forecast hourly M4-competition data
#' @format list of 19 entries
#' \describe{
#' \item{call}{the original call to randomForest}
#' \item{type}{classification}
#' \item{predicted}{the predicted values of the input data based on out-of-bag sample}
#' \item{err.rate}{vector error rates of the prediction on the input data, the i-th element being the OOB error rate for all trees up to the i-th}
#' \item{confusion}{the confusion matrix of the prediction based on OOB data}
#' \item{votes}{vote matrix or a matrix with one row for each input data point and one column for each class, giving the fraction or number of (OOB) votes from the random forest}
#' \item{oob.times}{number of times cases are ‘out-of-bag’ (and thus used in computing OOB error estimate)}
#' \item{classes}{names of all forecast-models we considered as classlabels}
#' \item{importance}{feature importance measure}
#' \item{importanceSD}{The “standard errors” of the permutation-based importance measure}
#' \item{localImportance}{we didn't calculate this: hence NULL}
#' \item{proximity}{We didn't calculate this: hence NULL}
#' \item{ntree}{Number of trees in the forest}
#' \item{mtry}{number of predictors sampled for spliting at each node}
#' \item{forest}{a list that contains the entire forest}
#' \item{y}{Responce variable}
#' \item{test}{NULL}
#' \item{inbag}{NULL}
#' \item{terms}{variable attributes}
#' }
#' @examples
#' data(hourly_fforms)
#' data(features_M4H)
#' predicted_fcast_models <- predict(hourly_fforms, features_M4H)
"hourly_fforms"
