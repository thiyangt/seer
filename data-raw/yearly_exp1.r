library(readr)
yearly_exp1 <- readr::read_rds("data-raw/yearly_exp1.rds")
use_data(yearly_exp1, overwrite=TRUE)
