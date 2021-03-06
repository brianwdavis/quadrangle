#' quadrangle: Wrangle QR codes out of images.
#'
#' The quadrangle package provides wrappers for two external libraries that read QR codes:
#' \code{quirc} (C++ via Rcpp) and \code{jsQR} (JavaScript via V8).
#' 
#' @section Primary scanning functions:
#' \code{\link{qr_scan}} reads files or \code{magick} objects and scans using both approaches.
#' 
#' \enumerate{
#'   \item \code{\link{qr_scan_cpp}} wraps only the C++ library and tries some image manipulation algorithms if detection is initially unsuccessful.
#'   \item \code{\link{qr_scan_js_from_corners}} wraps only the JS library and tries some image manipulation algorithms (especially cropping) if detection is initially unsuccessful.
#' }
#' 
#' @section Lower-level APIs:
#' \itemize{
#'   \item \code{rcpp_qr_scan_array} takes a pixel brightness vector of \code{raw} or \code{integer} and passes it to the C++ library.
#'   \item \code{\link{qr_scan_js_array}} takes a 3D pixel array (RGBA, w, h) and passes it to the JS library.
#' }
#' 
#'
#' @docType package
#' @name quadrangle
NULL

# Per Jenny Bryan's suggestions where the . pronoun is used (but I used vars in qr_plot)
# "Undefined global functions or variables" in R CMD check
if (getRversion() >= "2.15.1")  utils::globalVariables(c("id", "value", "x", "y"))
