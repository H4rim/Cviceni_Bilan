require(devtools)
devtools::install_github("hanel/KZ2018")

require(KZ2018)
data(vstup)

vstup[UPOV_ID==1 & Q>1]

vstup[, DEF:= (P-ETr)]

vstup[, sum(DEF), by = .(year(DTM), UPOV_ID)][, mean(V1), by = UPOV_ID]

require(bilan)
vstup[, R:=1000*(Q*60*60*24)/(A*1000000)]

b = bil.new(type = 'd')
bil.set.values(b, vstup[UPOV_ID == 1])
bil.pet(b)
res = bil.optimize(b)


res[, plot(DTM, R, type = 'l')]
res[, lines(DTM, RM, col = "red")]

res[, plot(R, RM)]
abline(0,1)

res[, plot(sort(R), sort(RM))]
abline(0,1)

res[year(DTM)<1995, plot(R, RM, pch = 3)]
res[year(DTM)>=1995, points(R, RM, col = 'red', pch=4)]
abline(0,1)

res[year(DTM)<1995, plot(sort(R), sort(RM), pch = 3)]
res[year(DTM)>=1995, points(sort(R), sort(RM), col = 'red', pch=4)]
abline(0,1)


res[, plot(sort(R), ((1: .N) - 0.3)/(.N + .4), type = 'l')]
res[, lines(sort(RM), ((1: .N) - 0.3)/(.N + .4), col = 'red')]


mdr = function(res, m = c(30, 60, 90, 180, 270, 300, 330, 360, 365)){
  pcp = m/365.25
  p = 1-pcp
  res[, .(m, mR = quantile(R, p), mRM = quantile(RM, p))]
}


mdr(res, m = c(20,50))

### hydroGOF
require(hydroGOF)
res[, gof(R, RM)]



require(plotrix)


porovnej = function(res, crits = c('ME', 'MAE', 'RMSE', 'NRMSE %', 'PBIAS %')){

  layout(matrix(c(1,1,1,2,3,4), ncol = 3, byrow = TRUE))
  par(mar = c(2,2,0,0), mgp = c(1.5,.3,0), tcl = -.15)

  # R - RM
  res[, plot(DTM, R, type = "l")]
  res[, lines(DTM, RM, col = "red")]
  addtable2plot(x = res[, min(DTM)], y=res[, max(R, RM)], table = t(res[, gof(R, RM)[crits, ]]), yjust = 0)
  legend("topright", legend = c('R', 'RM'), col = c(1,2), lty = 1, bty= 'n')

  # KORELACNI GRAF
  res[, plot(R, RM)]
  title(main = 'Korelacni graf', line = -1)
  abline(0,1)

  # QQ GRAF
  res[, plot(sort(R), sort(RM))]
  title(main = 'QQ graf', line = -1)
  abline(0,1)

  # m-den graf
  md = mdr(res)
  md[, plot(m, mR, type = 'l', ylim = c(range(mR, mRM)))]
  title(main = 'm-denni vody', line = -1)
  md[, lines(m, mRM, col = 'red')]
}

porovnej(res[year(DTM)<1995])
porovnej(res[year(DTM)>=1995])
