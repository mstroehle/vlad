#' @references Knoth S, Wittenberg P and Gan FF (2019).
#' Risk-adjusted CUSUM charts under model error.
#' \emph{Statistics in Medicine}, \strong{38}(12), pp. 2206--2218.
#' \doi{10.1002/sim.8104}
#'
#' Steiner SH, Cook RJ, Farewell VT and Treasure T (2000).
#'  Monitoring surgical performance using risk-adjusted cumulative sum charts.
#'  \emph{Biostatistics}, \strong{1}(4), pp. 441--452.
#'  \doi{10.1093/biostatistics/1.4.441}
#'
#' Brook D and Evans DA (1972)
#'  An approach to the probability distribution of CUSUM run length.
#'  \emph{Biometrika}, \strong{59}(3), pp. 539--549
#'
#' Webster RA and Pettitt AN (2007)
#' Stability of approximations of average run length of risk-adjusted CUSUM schemes using
#' the Markov approach: comparing two methods of calculating transition probabilities.
#'  \emph{Communications in Statistics - Simulation and Computation} \strong{36}(3), pp. 471--482
#'
#' @examples
#' \dontrun{
#' library(vlad)
#' library(dplyr)
#' data("cardiacsurgery", package = "spcadjust")
#'
#' ## preprocess data to 30 day mortality and subset phase I (In-control) of surgeons 2
#' SALLI <- cardiacsurgery %>% rename(s = Parsonnet) %>%
#'   mutate(y = ifelse(status == 1 & time <= 30, 1, 0),
#'         phase = factor(ifelse(date < 2*365, "I", "II"))) %>%
#'   filter(phase == "I") %>% select(s, y)
#'
#' ## estimate risk model, get relative frequences and probabilities
#' mod1 <- glm(y ~ s, data = SALLI, family = "binomial")
#' fi  <- as.numeric(table(SALLI$s) / length(SALLI$s))
#' usi <- sort(unique(SALLI$s))
#' pi1 <- predict(mod1, newdata = data.frame(s = usi), type = "response")
#' pi2 <- tapply(SALLI$y, SALLI$s, mean)
#'
#' ## set up patient mix (risk model)
#' pmix1  <- data.frame(fi, pi1, pi1)
#'
#' ## Average Run Length for detecting deterioration RA = 2:
#' racusum_arl_mc(pmix = pmix1, RA = 2, RQ = 1, h = 4.5)
#'
#' ## Average Run Length for detecting improvement RA = 1/2:
#' racusum_arl_mc(pmix = pmix1, RA = 1/2, RQ = 1, h = 4)
#'
#' ## set up patient mix (model free)
#' pmix2  <- data.frame(fi, pi1, pi2)
#'
#' ## Average Run Length for detecting deterioration RA = 2:
#' racusum_arl_mc(pmix = pmix2, RA = 2, RQ = 1, h = 4.5)
#'
#' ## Average Run Length for detecting improvement RA = 1/2:
#' racusum_arl_mc(pmix = pmix2, RA = 1/2, RQ = 1, h = 4)
#'
#' ## compare results with R-code function 'findarl()' from Steiner et al. (2000)
#' source("https://bit.ly/2KC0SYD")
#' all.equal(findarl(pmix = pmix1, R1 = 2, R = 1, CL = 4.5, scaling = 600),
#'          racusum_arl_mc(pmix = pmix1, RA = 2, RQ = 1, h = 4.5, scaling = 600, rounding = "s"))
#' }
