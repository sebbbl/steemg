options(shiny.usecairo = FALSE)

plotdate <- function(x, y, myylab = '', mylegend = '', mycol = 'darkgreen', myxlim){
  xrange <- as.numeric(diff.Date(myxlim))
  xatf <- function(x) {
    if (x > 365 * 4) return(c('year', '%Y'))
    if (x > 365) return(c('quarter', '%Y-%m'))
    if (x > 100) return(c('month', '%Y-%m'))
    if (x > 30) return(c('week','%m-%d'))
    c('day','%m-%d')
  }
  
  xat <- xatf(xrange)
  par(mar = c(3, 4, 0.5, 1), las = 1)
  plot(x, y, xlab = '', ylab = myylab, axes = FALSE, type = 'l', col = mycol)
  box()
  axis.Date(side = 1,
            at = seq.Date(myxlim[1], myxlim[2], by = xat[1]),
            x = seq.Date(myxlim[1], myxlim[2], by = xat[1]),
            format = xat[2])
  axis(2)
  rug(x, col = "darkgrey")
  
  legend('topleft', legend = mylegend, bty = 'n')
}

contest_stat <- function(contest_id){
  # contest_id <- 'mr'
  url <- paste0('https://raw.githubusercontent.com/pzhaonet/keller/master/mr/', contest_id, '.txt')
  info_all <- read.csv(url, stringsAsFactors = FALSE, encoding = 'UTF-8', quote = '')
  info <- info_all[, 1]
  info <- gsub('"', '', info)
  info <- as.Date(info)
  info_t <- info > (Sys.Date() - 7)
  n7 <- sum(info_t, na.rm = T)
  n <- length(info)
  return(c(n, n7))
}
