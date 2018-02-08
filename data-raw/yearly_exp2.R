library(readr)
yearly_exp2 <- readr::read_rds("data-raw/yearly_exp2.rds")
save(yearly_exp2, file='data/yearly_exp2.rdata', compress='xz')

yearly_exp2_sub <- readr::read_rds("data-raw/yearly_exp2_sub.rds")
save(yearly_exp2_sub, file='data/yearly_exp2_sub.rdata', compress='xz')
