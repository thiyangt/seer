#' The following code is taken from Mcomp package and done some
#' small tweaks to handle hourly, daily and weekly data in M4 competition.
#' @param x whether the data are from M1, M3 or M4
#' @param getdata condition: daily, monthly, demographic, etc.
#' @export
Mcomp.sub <- function(x,getdata)
{
  n <- length(x)
  Type <- Period <- character(n)
  for(i in 1:n)
  {
    Type[i] <- x[[i]]$type
    if(Type[i]=="INDUSTRIAL")
    Type[i] <- "INDUST"
    if(strsplit(Type[i],"-")=="DEMOGRAPHI")
    Type[i] <- "DEMOGRAPHIC"
    Period[i] <- x[[i]]$period
      }
    getdatatable <- c("yearly","quarterly","monthly","hourly","weekly","daily","other","macro","micro","industry",
                                  "finance","demographic","allother","macro1","macro2","micro1","micro2","micro3")
  if(is.character(getdata))
  {
    getdata <- getdatatable[charmatch(getdata,getdatatable)]
     if(length(getdata) != 1)
     stop("Ambiguous data type")
     else if(is.na(getdata))
     stop("Unknown data type")
      }

  if(getdata==1 | getdata=="yearly")
  choose <- (Period=="YEARLY")
  else if(getdata==4 | getdata=="quarterly")
  choose <- (Period=="QUARTERLY")
  else if(getdata==12 | getdata=="monthly")
  choose <- (Period=="MONTHLY")
  else if(getdata==52 | getdata=="weekly")
  choose <- (Period=="WEEKLY")
  else if(getdata==24 | getdata=="hourly")
  choose <- (Period=="HOURLY")
  else if(getdata==365 | getdata=="daily")
  choose <- (Period=="DAILY")
  #else if(getdata==111)
  #{
  #    j <- match(x111,names(x))
  #    choose <- rep(FALSE,length(x))
  #    choose[j] <- TRUE
  #   }
  else if(getdata=="other")
  choose <- (Period=="OTHER")
  else if(getdata=="macro")
  choose <- (Type=="MACRO")
  else if(getdata=="micro")
  choose <- (Type=="MICRO")
  else if(getdata=="industry")
  choose <- (Type=="INDUSTRY" | Type=="INDUST")
  else if(getdata=="finance")
  choose <- (Type=="FINANCE")
  else if(getdata=="demographic")
  choose <- (Type=="DEMOGRAPHIC" | Type=="DEMOGR")
  else if(getdata=="allother")
  choose <- (Type=="OTHER")
  else if(getdata=="macro1")
  choose <- (Type=="MACRO1")
  else if(getdata=="macro2")
  choose <- (Type=="MACRO2")
  else if(getdata=="micro1")
  choose <- (Type=="MICRO1")
  else if(getdata=="micro2")
  choose <- (Type=="MICRO2")
  else if(getdata=="micro3")
  choose <- (Type=="MICRO3")
  else
  stop("Unknown type or period")
  if(sum(choose) == 0)
  stop("No data")

  return(x[choose])

}
#' Subset of time series from the M Competitions
#' \code{subset.Mcomp} returns a subset of the time series data from the M
#' Competitions. Subsets can be for specific periods, or specific types of data
#' or both.
#'
#' Possible values for \code{cond1} and \code{cond2} denoting period are 1, 4,
#' 12, 24, 52, 365, "yearly", "quarterly", "monthly", "hourly", "weekly", "daily" and "other".
#'
#' If \code{cond1} or \code{cond2} equals 111, then the 111 series used in the
#' extended comparisons in the 1982 M-competition are selected.
#'
#' Possible values for \code{cond1} and \code{cond2} denoting type are "macro",
#' "micro", "industry", "finance", "demographic", "allother", "macro1",
#' "macro2", "micro1", "micro2", "micro3". These correspond to the descriptions
#' used in the competitions. See the references for details.
#'
#' Partial matching used for both conditions.
#'
#' @param x M-competition data or a subset of M-competition data
#' @param cond1 Type or period of the data. Type is a character variable and
#' period could be character or numeric.
#' @param cond2 Optional second condition specifying type or period of the
#' data, depending on \code{cond1}.  If \code{cond1} denotes type then
#' \code{cond2} would denote period, but if \code{cond1} denotes period then
#' \code{cond2} would denote type.
#' @param ... Other arguments.
#' @author Thiyanga Talagala (Thiyanga has done small tweaks to adopt the code to M4data, original authors
#' of the code are Muhammad Akram and Rob Hyndman)
#' @return An object of class \code{Mcomp} consisting of the selected series.
#' @references Rob Hyndman (2018). Mcomp: Data from the M-Competitions. R package version 2.7. https://CRAN.R-project.org/package=Mcomp
#' @keywords data
#' @examples
#' library(seer)
#' data(M4)
#' M4.quarterly <- subset(M4,4)
#' M4.yearly.industry <- subset(M4,1,"industry")
#' @export
#' @export subset.Mcomp
#'
subset.Mcomp <- function(x,cond1,cond2,...)
{
  if(is.character(cond1))
  cond1 <- tolower(cond1)
  M11=structure(Mcomp.sub(x,cond1),class="Mcomp")
  if(!missing(cond2))
  {
    if(is.character(cond2))
    cond2 <- tolower(cond2)
    M12=structure(Mcomp.sub(M11,cond2),class="Mcomp")
    return(M12)
     }
  else
  return(M11)
}
#' @export
`[.Mcomp` <- function(x, i)
{
  y <- NextMethod("[")
  class(y) <- c("Mcomp", class(y))
  y
}
