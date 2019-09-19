#' Scan an image file or \code{magick} image object for QR codes with the C++ engine.
#' 
#' This is a wrapper function to call the QR code scanner in the \code{quirc}
#' C++ library. You can call this function on file paths, or preprocess files
#' and call this function on the resulting \code{magick} objects.
#' 
# The algorithm used here was originally developed to identify QR codes on
# white printed sheets in outdoor images, so images are progressively darkened
# to recover data in overexposed regions. You may need to view the source of
# this function to get a template for developing your own algorithm in other
# lighting conditions. For example, \code{\link{image_threshold}} with
# \code{(..., type = "white")} to lighten dark images, or
# \code{\link{image_morphology}} with \code{(..., morphology = "Open", kernel =
# "Square:7")}. A more thoughtful API for developing these algorithms is a work
# in progress.
#' 
#' @param image A path to a \code{magick}-readable file, e.g. jpg or png, or a \code{magick} object.
#' @param flop Logical. Should image be mirrored L-R? Some generators produce QR codes like this.
#' @param debug Logical. Should additional metadata about decoded QR patterns be included? e.g. ECC level, version number, etc.
#' @return A list of two dataframes, "values" and "points" describing any found QR codes.
qr_scan_cpp <- function(image, flop = T, debug = F) {
  if (is.character(image)) {
    mgk <- image_read(image)
  } else if ("magick-image" %in% class(image)) {
    mgk <- image
  } else {
    stop("Supply either an image file path or a magick image object.")
  }
  
  codes <- list(values = data.frame(), points = data.frame())
  thr <- paste0(c(0,50,60,70,80,90,95), "%")
  i <- 0
  candidate_values <- data.frame()
  candidate_points <- data.frame()
  
  if (flop) {
    mgk <- image_flop(mgk)
  }
  
  while (
    (all(codes$values$value == "") || nrow(codes$values) == 0) & i < length(thr)
  ) {
    i <- i + 1
    
    arr <- mgk %>% 
      image_threshold("black", thr[i]) %>%
      image_data(channels = "gray")
    
    codes <- rcpp_qr_scan_array(
      as.vector(arr, mode = "raw"),
      dim(arr)[2],
      dim(arr)[3],
      debug
    )
    
    if (nrow(codes$points) > 0) {
      candidate_values <- codes$values
      candidate_points <- codes$points
    }
  }
  
  if (nrow(codes$points) == 0 && nrow(candidate_points) != 0) {
    codes$values <- candidate_values
    codes$points <- candidate_points
  }
  
  codes
}


