.onLoad <- function(libname, pkgname) {
  if (is.null(getOption("quadrangle.js_src"))) {
    path <- list("quadrangle.js_src" = qr_js_src_path_())
    options(path)
  }
  
  invisible()
}

#' Get the included JS source for \code{jsQR}.
#' 
#' @keywords internal
#' 
#' @return The path to the included version of the \code{jsQR} library.
qr_js_src_path_ <- function() {system.file("js/jsQR.js", package = "quadrangle")}


#' Update the JS source for \code{jsQR} from the upstream repo.
#' 
#' Changes the \code{\link{options}} setting to a new version of the JS source code,
#' as determined from the canonical repository on GitHub. If you wish to modify
#' the JS source yourself or download from another URL, you can instead call
#' \code{options(list("quadrangle.js_src" = your_local_file_path))}
#' 
#' @param local_path The working folder to save the new version of the \code{jsQR} library.
#' @param reset Reverts to the included version if problems arise.
#' @return The path to a new version of the jsQR library.
qr_js_src_update <- function(local_path = getwd(), reset = FALSE) {
  if (reset) {
    options(list("quadrangle.js_src" = qr_js_src_path_()))
  } else {
    pkg <- jsonlite::read_json(
      "https://github.com/cozmo/jsQR/raw/master/package.json"
      )
    
    dest <- normalizePath(
      glue::glue("{local_path}/jsQR_{pkg$version}.js"),
      mustWork = FALSE
      )
    
    st <- utils::download.file(
      url = "https://github.com/cozmo/jsQR/raw/master/dist/jsQR.js",
      destfile = dest,
      quiet = !interactive()
      )
    
    if (file.exists(dest) && st == 0) {
      options(list("quadrangle.js_src" = dest))
    } else {
      stop("jsQR.js was not successfully downloaded. Check your connection and try again.")
    }
    
  }

  return(getOption("quadrangle.js_src"))
}

#' Initialize a JS engine for QR scanning.
#' 
#' @return A V8 context that can be used inside a function, or assigned to the global environment.
qr_v8_init <- function() {
  eng <- V8::v8()
  
  op_path <- getOption("quadrangle.js_src")
  
  if (file.exists(op_path)) {
    path <- op_path
  } else {
    path <- qr_js_src_path_()
  }
  
  eng$source(path)
  return(eng)
}

#' Check if the system V8 library is up to date.
#' 
#' Older versions of V8 included with Ubuntu/Debian do not support 
#' \code{Uint8ClampedArray} typed arrays, so JS decoding will be skipped. These
#' can be updated manually.
#' 
#' @keywords internal
#' 
#' @return Logical. Compatibility.
qr_v8_checker_ <- function() {
  v <- V8::engine_info()$version
  v1 <- strsplit(v, "\\.")[[1]][1]
  flag <- as.numeric(v1) >= 6
  
  if (!flag) {
    warning(
      "You must upgrade your system V8 library to use the JS engine.\n", 
      glue::glue("Currently using {v}, needs >= 6."),
      immediate. = TRUE
      )
  }
  
  return(flag)
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
  if (!qr_v8_checker_()) {
    stop("Please see https://github.com/jeroen/V8#debian--ubuntu")
  }
  
  if (is.null(engine)) {
    engine <- qr_v8_init()
    on.exit(engine$reset())
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
  
  img_d <- V8::JS(glue::glue("new Uint8ClampedArray({jsonlite::toJSON(vec)})"))
  img_w <- V8::JS(jsonlite::toJSON(dim(arr)[2], auto_unbox = TRUE))
  img_h <- V8::JS(jsonlite::toJSON(dim(arr)[3], auto_unbox = TRUE))
  
  y <- engine$call("jsQR", img_d, img_w, img_h, list(inversionAttempts = "dontInvert"))
  if (!is.null(y)) {
    y$location <- y$location %>% 
      purrr::map(~as.data.frame(.x, stringsAsFactors = F)) %>% 
      qr_rbind_(.id = "corner")
  }
  return(y)
}  
