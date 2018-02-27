#' M-denni prutoky
#'
#' @param res Vystup modelu Bilan
#' @param m pocet dni
#'
#' @return
#' @export mdr
#'
#' @examples
mdr = function(res, m = c(30, 60, 90, 180, 270, 300, 330, 360, 365)){
  pcp = m/365.25
  p = 1-pcp
  res[, .(m, mR = quantile(R, p), mRM = quantile(RM, p))]
}


#' Porovnej pozorovany a modelovany odtok
#'
#' @param res vystup modelu Bilan
#' @param crits kriteria z funkce `hydroGOF::gof` zahrnuta v grafu
#'
#' @return
#' @export porovnej
#'
#' @examples
porovnej = function(res, crits = c('ME', 'RMSE', 'PBIAS %', 'NSE', 'KGE'), plot = TRUE){

 if (plot) {
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
 res[, gof(R, RM)[crits, ]]
}

err_mdr = function(x){
  m = c(30, 60, 90, 180, 270, 300, 330, 360, 365)
  pcp = m/365.25
  p = 1-pcp
  qx = quantile(x, p)  
  return(mean(abs(obs_mdr - qx)))
}
