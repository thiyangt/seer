#' Function to identify models to compute combination forecast using FFORMS algorithm
#'
#' This function identify models to be use in producing combination forecast
#' @param votematrix a matrix of votes of probabilities based of fforms random forest classifier
#' @param threshold threshold value for sum of probabilities of votes, default is 0.5
#' @return a list containing the names of the forecast models
#' @importFrom purrr map
#' @author Thiyanga Talagala
#' @export
fforms_ensemble <- function(votematrix, threshold=0.5){

  # begore applying purrr function convert all rows in the matrix into a lost
  colnames.votematrix <- colnames(votematrix)
  ncol.votematrix <- ncol(votematrix)
  mat.list <- lapply(seq_len(nrow(votematrix)), function(i) votematrix[i,])

  # select the names of the models in which the sum is greater than the threshold
  select.models <- function(x){
    x.length <- length(x)
    x.sort <- sort(x, decreasing = TRUE)
    x.sort.sum <- numeric(x.length)
    model.names <- c()
    for (i in 1:x.length)
    {
      x.sort.sum[i] <- sum(x.sort[seq_len(i)])
      if (x.sort.sum[i] >=threshold){
        model.names <- names(x.sort[1:i])
        return(model.names)
      }
    }
  }

 purrr::map(mat.list, select.models)



}
#'@example
#'fforms_votematrix <- matrix(c(0.1, 0.2, 0.7, 0.3, 0.3, 0.4), byrow=TRUE, ncol=3)
#'colnames(fforms_votematrix) <- c("WN", "RW", "RWD")
#'fforms_ensemble(fforms_votematrix)


