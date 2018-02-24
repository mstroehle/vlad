#' @references Steiner SH, Cook RJ, Farewell VT and Treasure T (2000).
#' “Monitoring surgical performance using risk-adjusted cumulative sum charts.”
#' \emph{Biostatistics}, \strong{1}(4), pp. 441-452.
#' doi: \href{https://doi.org/10.1093/biostatistics/1.4.441}{10.1093/biostatistics/1.4.441}.
#'
#' Taylor HM (1968). “The Economic Design of Cumulative Sum Control Charts.”
#' \emph{Technometrics}, \strong{10}(3), pp. 479-488.
#' doi: \href{https://doi.org/10.1080/00401706.1968.10490595}{10.1080/00401706.1968.10490595}.
#'
#' Crosier R (1986). “A new two-sided cumulative quality control scheme.”
#' \emph{Technometrics}, \strong{28}(3), pp. 187-194.
#' doi: \href{https://doi.org/10.2307/1269074}{10.2307/1269074}.
#'
#' @examples
#' \dontrun{
#' library("vlad")
#' library("spcadjust")
#' data("cardiacsurgery")
#' # build data set
#' df1 <- subset(cardiacsurgery, select=c(Parsonnet, status))
#'
#' # estimate coefficients from logit model
#' coeff1 <- round(coef(glm(status ~ Parsonnet, data=df1, family="binomial")), 3)
#'
#' # simulation of conditional steady state
#' m <- 10^4
#' tau <- 10
#' res <- sapply(0:(tau-1), function(i){
#'  RLS <- do.call(c, parallel::mclapply( 1:m, racusum_adoc_sim, RQ=2, h=2.0353, df=df1, m=i,
#'                                        coeff=coeff1, coeff2=coeff1,
#'                                        mc.cores=parallel::detectCores()) )
#'  list(data.frame(cbind("ARL"=mean(RLS), "ARLSE"=sd(RLS)/sqrt(m))))
#' } )
#'
#' # plot
#' df3 <- data.frame(cbind("m"=1:tau, "Sim"=do.call(rbind, res)[,"ARL"]))
#' df4 <- tidyr::gather(df3, "Method", CED, c(-m))
#' ggplot2::qplot(data=df4, m, CED, colour=Method, geom=c("line", "point"),
#'                ylab=c(expression(CED[m]))) + ggplot2::theme_classic()
#' }