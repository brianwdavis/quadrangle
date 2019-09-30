#' (Internal) Image thresholding, with some shortcuts
#' 
#' This is an internal function used by \code{\link{qr_scan_js_from_corners}}
#' and \code{\link{qr_scan_cpp}}. It's a wrapper around \code{\link{image_threshold}}
#' which skips running the function call if the arguments indicate essentially
#' unchanged images, such as pushing the blackest 0\% of pixels to black, or the
#' whitest 100\% of pixels to white.
#' 
#' @keywords internal
#' 
#' @param mgk       A \pkg{magick} image object.
#' @param type      Type of thresholding, either black or white.
#' @param threshold Pixel intensity threshold.
#' @param ...       Additional arguments passed through (\code{channels}).
qr_threshold_shortcut_ <- function(mgk, type, threshold, ...) {
  if ((type == "black" && threshold == "0%") || (type == "white" && threshold == "100%")) {
    mgk
  } else {
    image_threshold(mgk, type, threshold, ...)
  }
}

#' (Internal) Progress bar wrapper
#' 
#' This is an internal function used by \code{\link{qr_scan_js_from_corners}}
#' and \code{\link{qr_scan_cpp}}. It's a wrapper around \code{\link[progress]{progress_bar}}.
#' It checks for \code{options("dplyr.show_progress")} since that's a handy flag
#' used by an existing dependency of this package. If I was smarter, I'd probably
#' put something into \code{\link{options}} on loading \code{quadrangle}.
#' 
#' @keywords internal
#' 
#' @param prefix  Which scanning engine is running?
#' @param n       How many combinations of arguments will be tried before failure?
qr_pb_ <- function(prefix, n) {
  flag <- c(
    options("dplyr.show_progress")[[1]],
    requireNamespace("progress", quietly = T),
    interactive()
  )
  
  if (all(flag, na.rm = T)) { 
    pb <- progress::progress_bar$new(
      total = n + 1,
      format = glue::glue("[{prefix}] Lighten :l Darken :d [:bar] :percent :eta")
    )
    pb$tick(tokens = list(l = "    ", d = "  "))
  } else {
    pb <- list(tick = function(...) {invisible(NULL)})
  }
  return(pb)
}
