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
    magick::image_threshold(mgk, type, threshold, ...)
  }
}

#' (Internal) Progress bar wrapper
#' 
#' This is an internal function used by \code{\link{qr_scan_js_from_corners}}
#' and \code{\link{qr_scan_cpp}}. It's a wrapper around \code{\link[progress]{progress_bar}}.
#' Can be disabled with \code{options(list(progress_enabled = F))}.
#' 
#' @keywords internal
#' 
#' @param prefix  Which scanning engine is running?
#' @param n       How many combinations of arguments will be tried before failure?
qr_pb_ <- function(prefix, n) {
  flag <- c(
    requireNamespace("progress", quietly = TRUE),
    interactive()
  )
  
  if (all(flag, na.rm = TRUE)) { 
    pb <- progress::progress_bar$new(
      total = n + 1,
      format = glue::glue("[{prefix}] Lighten :l Darken :d [:bar] :percent :eta"),
      clear = FALSE,
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
#' handles the expected use cases in this package. It's inferior to \code{dplyr::bind_rows}
#' in every way, so it should only be used inside this package.
#' 
#' @keywords internal
#' 
#' @param df_list  A list of dataframes.
#' @param .id      The name of the prepended ID column.
qr_rbind_ <- function(df_list, .id = "id") {
  bound_list <- purrr::compact(df_list) %>% 
    purrr::keep(~nrow(.) > 0) %>% 
    purrr::imap(~cbind(.id = .y, .x))
  
  bound <- do.call("rbind", bound_list)
  
  if (is.null(bound)) {
    bound <- data.frame()
  } else {
    names(bound)[1] <- .id
    rownames(bound) <- NULL
  }
  
  bound
}

#' Pipe operator
#' 
#' @name %>% 
#' @rdname pipe
#' @keywords internal
magick::`%>%`
