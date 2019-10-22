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
#' If I was smarter, I'd probably put something into \code{\link{options}} on 
#' loading \code{quadrangle}, so the user could disable this if they wanted to.
#' 
#' @keywords internal
#' 
#' @param prefix  Which scanning engine is running?
#' @param n       How many combinations of arguments will be tried before failure?
qr_pb_ <- function(prefix, n) {
  flag <- c(
    requireNamespace("progress", quietly = T),
    interactive()
  )
  
  if (all(flag, na.rm = T)) { 
    pb <- progress::progress_bar$new(
      total = n + 1,
      format = glue::glue("[{prefix}] Lighten :l Darken :d [:bar] :percent :eta"),
      clear = F,
      show_after = 0
    )
    pb$tick(tokens = list(l = "    ", d = "  "))
  } else {
    pb <- list(tick = function(...) {invisible(NULL)})
  }
  return(pb)
}

#' (Internal) \code{dplyr::bind_rows} replacement
#' 
#' This is an internal function. Since \pkg{dplyr} is a heavy dependency, this
#' handles the expected use cases in this package. It's inferior to \code{\link[dplyr]{bind_rows}}
#' in every way, so it should only be used inside this package.
#' 
#' @keywords internal
#' 
#' @param df_list  A list of dataframes.
#' @param .id      The name of the prepended ID column.
qr_rbind_ <- function(df_list, .id = "id") {
  bound <- compact(df_list) %>% 
    keep(~nrow(.) > 0) %>% 
    imap(~cbind(.id = .y, .x)) %>% 
    {do.call("rbind", .)}
  
  if (is.null(bound)) {
    bound <- data.frame()
  } else {
    names(bound)[1] <- .id
    rownames(bound) <- NULL
  }
  
  bound
}
