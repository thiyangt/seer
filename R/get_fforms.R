#' Function to download pre-trained FFORMS random forests
#'
#' Load pretrained random forests trained based on FFORMS algorithm using the M1, M3 and M4 competition data
#' @param frequency frequency of the data you will be forecasting, for example yearly, quarterly, monthly, weekly, daily and hourly
#' @return an object class of randomForest
#' @importFrom utils data install.packages
#' @export
get_fforms <- function(frequency){

  ## load datasets from fformsRF
  install.packages("https://github.com/thiyangt/fformsRF/releases/download/v0.1.0/fformsRF_0.1.0.tar.gz",
                 repos=NULL)

  if(frequency=="hourly"){
    x <- readline("FFORMS for hourly series!\n(press enter to continue)")
    fforms <- data("hourly_fforms", envir = environment())
  } else if (frequency=="daily") {
    x <- readline("FFORMS for daily series!\n(press enter to continue)")
    fforms <- data("rfu_m4daily", envir = environment())
  } else if (frequency=="weekly") {
    x <- readline("FFORMS for weekly series!\n(press enter to continue)")
    fforms <- data("rfu_m4weekly", envir = environment())
  }
return(fforms)
}
#'@example
#' #Do not run
#' #get_fforms("hourly")
