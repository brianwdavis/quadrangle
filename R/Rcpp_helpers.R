#' Scan an image file or \code{magick} image object for QR codes with the C++ engine.
#' 
#' This is a wrapper function to call the QR code scanner in the \code{quirc}
#' C++ library. You can call this function on file paths, or preprocess files
#' and call this function on the resulting \code{magick} objects.
#' 
#' This uses a double-\code{while} loop that progressively pushes mid-brightness
#' pixels to pure black, and if that fails, progressively pushes mid-brightness
#' pixels to pure white. This algorithm was developed for identifying QR codes
#' on white printed sheets in outdoor images, in bright sun with or without
#' shadows. To speed up scanning, you can use arguments \code{lighten = F,
#' darken = F} which will skip any thresholding. If you use both \code{lighten = T, darken = T},
#' scanning may be quite slow until a decodable QR code is found. In those cases,
#' a progress bar will attempt to be shown, if you have the \pkg{progress}
#' package (\url{https://github.com/r-lib/progress}) available on your machine.
#'
#' To BYO algorithm, you can use this function as a template. For example,
#' \code{\link{image_morphology}} with \code{(..., morphology = "Open", kernel =
#' "Square:n")} (varying \code{n} from 2 to 10) may repair corrupted QR blocks.
#' 
#' @param image A path to a \code{magick}-readable file, e.g. jpg or png, or a \code{magick} object.
#' @param flop Logical. Should image be mirrored L-R? Some generators produce QR codes like this.
#' @param lighten Logical. Should under-exposed areas of the image be lightened to increase contrast? Useful for images in shadow. Default \code{FALSE}.
#' @param darken Logical. Should over-exposed areas of the image be darkened to increase contrast? Useful for images in bright light. Default \code{TRUE}.
#' @param debug Logical. Should additional metadata about decoded QR patterns be included? e.g. ECC level, version number, etc.
#' @param verbose Logical. Should warnings print for potentially slow operations?
#' @return A list of two dataframes, "values" and "points" describing any found QR codes.
qr_scan_cpp <- function(image, flop = T, lighten = F, darken = T, debug = F, verbose = interactive()) {
  if (is.character(image)) {
    mgk <- image_read(image)
  } else if ("magick-image" %in% class(image)) {
    mgk <- image
  } else {
    stop("Supply either an image file path or a magick image object.")
  }
  
  codes <- list(values = data.frame(), points = data.frame())
  thr_w <- paste0(c(100,50,45,40,35,30,25), "%")
  thr_b <- paste0(c(  0,50,60,70,80,90,95), "%")
  
  j <- 0
  candidate_values <- data.frame()
  candidate_points <- data.frame()
  
  if (flop) {
    mgk <- image_flop(mgk)
  }
  
  if (!lighten) thr_w <- thr_w[1]
  if (!darken) thr_b <- thr_b[1]
  if (lighten && darken && verbose) {
    warning(
      "Cleaning up both over-exposed and under-exposed areas may be slow.",
      immediate. = T, call. = F
    )
  }
  
  pb <- qr_pb_("C++", length(thr_w)*length(thr_b))
  
  while (
    (all(codes$values$value == "") || nrow(codes$values) == 0) && j < length(thr_w)
  ) {
    
    j <- j + 1
    mgk <- qr_threshold_shortcut_(mgk, "white", thr_w[j])
    i <- 0
    
    while (
      (all(codes$values$value == "") || nrow(codes$values) == 0) && i < length(thr_b)
    ) {
      i <- i + 1
      pb$tick(tokens = list(l = thr_w[j], d = thr_b[i]))
      
      
      arr <- qr_threshold_shortcut_(mgk, "black", thr_b[i]) %>%
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
  }
  
  
  
  if (nrow(codes$points) == 0 && nrow(candidate_points) != 0) {
    codes$values <- candidate_values
    codes$points <- candidate_points
  }
  
  codes
}

