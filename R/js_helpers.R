# TODO add to options()
# TODO add updating mechanism
# https://github.com/cozmo/jsQR/raw/master/dist/jsQR.js
qr_js_src_path <- system.file("js/jsQR.js", package = "quadrangle")

#' Initialize a JS engine for QR scanning.
#' 
#' @param  qr_js_src The path to the JS file that contains the \code{jsQR} library.
#' @return A V8 context that can be used inside a function, or assigned to the global environment.
qr_v8_init <- function(qr_js_src = qr_js_src_path) {
  eng <- v8()
  eng$source(qr_js_src)
  return(eng)
}

#' Identify a JS engine and test it.
#' 
#' If a \pkg{V8} engine isn't specified when running \code{\link{qr_scan_js_array}}, this
#' function will be called to search the global environment. If it finds a V8 
#' context, it will then test if it contains the \code{jsQR} library and return
#' it. If not, it will initialize a new one with \code{\link{qr_v8_init}} and return it.
#' 
#' @param env Which environment to search for engines? (Usually global.)
#' @param qr_js_src Path to the \code{jsQR} library source.
#' @return A prepared \code{\link{v8}} context.
qr_v8_ls <- function(env = .GlobalEnv, qr_js_src = qr_js_src_path) {
  envs <- ls.str(mode = "environment", envir = env)
  
  is_V8 <- function(nm) {
    if ("V8" %in% class(get(nm))) {
      return(nm)
    } else return(NULL)
  }
  
  is_jsQR <- function(nm) {
    eng <- get(nm)
    if ("jsQR" %in% eng$get("Object.keys(this)")) {
      nm
    } else return(NULL)
  }
  
  eng_list <- envs %>% map(is_V8) %>% compact() %>% map(is_jsQR) %>% compact()
  
  if (length(eng_list) == 0) {
    eng <- qr_v8_init(qr_js_src)
  } else {
    eng <- get(sample(unlist(eng_list), 1))
  }
  
  return(eng)
}

#' Scan a pixel array for QR codes with the JS engine.
#' 
#' This is the wrapper for the QR code scanner in the \code{jsQR} library. It
#' converts an array of pixels (usually from \code{\link{image_data}}) into the
#' appropriate JS object and calls \code{jsQR} to scan it. The first dimension
#' should length-4 for RGBA values (can be \code{double} 0-1, \code{integer} 0-255, or \code{raw}
#' \code{0x00-0xff}), and the other dimensions should be width and height.
#' 
#' @param arr A 3D array of types raw, double, or integer. 
#' @param engine An initialized V8 context, see \code{\link{qr_v8_init}}.
#' @return A list with metadata about any identified QR code.
qr_scan_js_array <- function(arr, engine = NULL) {
  if (is.null(engine)) {
    engine <- qr_v8_ls()
  }
  
  if (!identical(dim(arr)[1], 4L)) {
    stop("Pixel array must have 4 channels, RGBA")
  }
  
  # TODO check this logic again
  vec <- as.vector(arr, mode = "numeric")

  if (max(vec) <= 1) {
    vec = vec*255
  }
  
  vec = as.integer(vec)
  
  img_d <- JS(glue::glue("Uint8ClampedArray.from({jsonlite::toJSON(vec)})"))
  img_w <- JS(jsonlite::toJSON(dim(arr)[2], auto_unbox = T))
  img_h <- JS(jsonlite::toJSON(dim(arr)[3], auto_unbox = T))
  
  y <- engine$call("jsQR", img_d, img_w, img_h, list(inversionAttempts = "dontInvert"))
  if (!is.null(y)) {
    y$location <- y$location %>% 
      map(~as.data.frame(.x, stringsAsFactors = F)) %>% 
      qr_rbind_(.id = "corner")
  }
  return(y)
}  
