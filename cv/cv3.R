library(KZ2018)
library(bilan)

data("vstup")

b = bil.new(type = 'd')
bil.set.values(b, input_vars = vstup[UPOV_ID == 1 & year(DTM) %in% c(2005:2006)])
bil.pet(b)

bil.set.optim(b, method = 'DE', init_GS = 1)
res = bil.optimize(b)

porovnej(res, plot = TRUE)


b1 = bil.new(type = 'd', modif = 'critvars')
bil.set.values(b1, input_vars = vstup[UPOV_ID == 1 & year(DTM) %in% c(2001:2002)])
bil.pet(b1)
bil.set.optim(b1, method = 'DE')

bil.set.critvars(b1, obs_vars = c('R', 'R'), mod_vars = c('RM', 'RM'), crit = c("mean", 'sd'), weights = c(1, 1) )

res1 = bil.optimize(b1)
porovnej(res1)


res[, .(sd(R)/sd(RM))]

porovnej(res)

mdr(res)
mdr(res1)[, mean(abs(mR - mRM))]
mdr(res)[, mean(abs(mR - mRM))]
mdr(res1)[, mean(abs(mRM/mR-1))]

obs_mdr = mdr(res)$mR

err_mdr = function(x){
  m = c(30, 60, 90, 180, 270, 300, 330, 360, 365)
  pcp = m/365.25
  p = 1-pcp
  qx = quantile(x, p)
  return(mean(abs(obs_mdr - qx)))
}

bil.set.critvars(b1, obs_vars = c('R'), mod_vars = c('RM'), crit = c('custom'), weights = c(1), funs = c(err_mdr), obs_values = 0)

res1 = bil.optimize(b1)
porovnej(res1)


bil.set.critvars(b1, obs_vars = c('R', 'R'), mod_vars = c('RM', 'RM'), crit = c('custom', 'sd'), weights = c(5,1), funs = c(err_mdr, NA), obs_values = c(0, NA) )

bil.set.optim(b1, method = 'DE', init_GS = 5)
res2 = bil.optimize(b1)
porovnej(res2)

err_mdr(res2$RM)
res2[, .(sd(R), sd(RM))]


.i = 10

##### Pro standardni kalibraci
b = bil.new(type = 'd')
bil.set.values(b, input_vars = vstup[UPOV_ID == 1 & year(DTM) %in% c(2001:2002)])
bil.pet(b)

bil.set.optim(b, method = 'DE', init_GS = 1)

C1 = list()
for (i in 1:.i){
  res = bil.optimize(b)
  C1[[length(C1) + 1]] = data.table(t(porovnej(res, plot = FALSE)  ))
}

C1 = rbindlist(C1)

### C2 ... Pro kalibraci na prumer



### C3 ... Pro kalibraci na sd

### C4 ... Pro kalibraci na prumer + sd

b1 = bil.new(type = 'd', modif = 'critvars')
bil.set.values(b1, input_vars = vstup[UPOV_ID == 1 & year(DTM) %in% c(2001:2002)])
bil.pet(b1)
bil.set.optim(b1, method = 'DE')

bil.set.critvars(b1, obs_vars = c('R', 'R'), mod_vars = c('RM', 'RM'), crit = c("mean", 'sd'), weights = c(1, 1) )

C4 = list()
for (i in 1:.i){
  res1 = bil.optimize(b1)
  C4[[length(C4) + 1]] = data.table(t(porovnej(res1, plot = FALSE)  ))
}

C4 = rbindlist(C4)

### C5 ... Kalibraci na m-denni vody

### C6 ... Nejlepsi kalibrace

### Vyhodnocení

C = rbind(
  data.table(ID = 'C1', C1),
  data.table(ID = 'C4', C4)
)

boxplot(ME ~ ID, data = C)
boxplot(RMSE ~ ID, data = C)
