#' @name racusum_arl_mc
#' @title Compute ARLs of RA-CUSUM control charts using Markov chain approximation
#' @description Computes the Average Run Length of a risk-adjusted cumulative sum control chart
#' using Markov chain approximation.
#'
#' @param pmix Numeric Matrix. A three column matrix. First column is the risk
#' score distribution. Second column are the predicted probabilities from the ris kmodel. Third
#'  column can be either the predicted probabilities from the risk model or average outcome per
#'  risk score, see examples.
#' @param RA Double. Odds ratio of death under the alternative hypotheses. Detecting deterioration
#' in performance with increased mortality risk by doubling the odds Ratio \code{RA = 2}. Detecting
#'  improvement in performance with decreased mortality risk by halving the odds ratio of death
#'  \code{RA = 1/2}. Odds ratio of death under the null hypotheses is \code{1}.
#' @param RQ Double. Defines the true performance of a surgeon with the odds ratio ratio of death
#' \code{RQ}. Use \code{RQ = 1} to compute the in-control ARL and other values to compute the
#' out-of-control ARL.
#' @param h Double. \code{h} is the control limit (>\code{0}).
#' @param scaling Double. The \code{scaling} parameter controls the quality of the approximation,
#' larger values achieve higher accuracy but increase the computation burden (larger transition
#' probability matrix).
#' @param rounding Character. If \code{rounding = "p"} a paired rounding implementation similar to
#' \emph{Webster and Pettitt (2007)} is used, if \code{rounding = "s"} a simple rounding method of
#' \emph{Steiner et al. (2000)} is used.
#' @param method Character. If \code{method = "Toep"} a combination of Sequential Probability Ratio
#'  Test and Toeplitz matrix structure is used to calculate the ARL. \code{"ToepInv"} computes the
#'  inverted matrix using Toeplitz matrix structure. \code{"BE"} solves a linear equation system
#'  using the classical approach of \emph{Brook and Evans (1972)} to calculate the ARL.
#'
#' @return Returns a single value which is the Run Length.
#'
#' @template racusum_arl_mc
#'
#' @author Philipp Wittenberg
#' @export
racusum_arl_mc <- function(pmix, RA, RQ, h, scaling = 600, rounding = "p", method = "Toep") {
  pmix <- as.matrix(pmix)
  RA <- as.numeric(RA)
  if (is.na(RA) || RA <= 0) {stop("Odds ratio of death under the alternative hypotheses 'RA' must a positive numeric value")}
  RQ <- as.numeric(RQ)
  if (is.na(RQ) || RQ <= 0) {stop("True performance of a surgeon 'RQ' must a positive numeric value")}
  UCL <- as.numeric(h)
  if (is.na(h) || h <= 0) {stop("Control limit 'h' must be a positive numeric value")}
  irounding <- switch(rounding, p = 1, s = 2)
  as.integer(irounding)
  as.numeric(scaling)
  imethod <- switch(method, Toep = 1, ToepInv = 2, BE = 3)
  as.integer(imethod)
  if (is.null(imethod)) {
    warning("no valid input, using method=toeplitz as default")
    imethod <- 1
  }
  .racusum_arl_mc(pmix, RA, RQ, h, scaling, irounding, imethod)
}

#' @name racusum_crit_mc
#' @title Compute alarm threshold of RA-CUSUM control chart using Markov chain approximation
#' @description Computes alarm threshold of a risk-adjusted cumulative sum control chart using
#' Markov chain approximation.
#'
#' @param L0 Double. Prespecified Average Run Length.
#' @inheritParams racusum_arl_mc
#' @param verbose Logical. If \code{FALSE} a quiet calculation of \code{h} is done. If \code{TRUE}
#'  verbose output of the search procedure is included.
#'
#' @return Returns a single value which is the control limit \code{h} for a given In-control ARL.
#'
#' @template racusum_crit_mc
#'
#' @details
#' Determines the control limit for given in-control ARL (\code{"L0"}) using
#' \code{\link{racusum_arl_mc}} by applying a grid search and secant method.
#'
#' @author Philipp Wittenberg
#' @export
racusum_crit_mc <- function(pmix, L0, RA, RQ, scaling = 600, rounding = "p", method = "Toep", verbose = FALSE) {
  irounding <- switch(rounding, p = 1, s = 2)
  as.integer(irounding)
  imethod <- switch(method, Toep = 1, ToepInv = 2, BE = 3)
  if (is.null(imethod)) {
    warning("no valid input, using method=toeplitz as default")
    imethod <- 1
  }
  .racusum_crit_mc(
    as.matrix(pmix),
    as.numeric(L0),
    as.numeric(RA),
    as.numeric(RQ),
    as.numeric(scaling),
    irounding, imethod,
    as.logical(verbose)
  )
}