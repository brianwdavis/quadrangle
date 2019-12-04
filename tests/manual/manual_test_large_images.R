library(testthat)
library(quadrangle)

context("Slow/network tests to be run manually")


test_that(
  "Large images (~8MB, 20Mpx) don't crash JS engine",
  {
    skip_if_offline()
    skip_on_cran()

    large_path <- "https://github.com/brianwdavis/QRdemo/raw/master/inst/extdata/DSC_0003.jpg"
    large_image <- magick::image_read(large_path)

    x <- large_image %>% 
      magick::image_flop() %>% 
      qr_scan_js_from_corners(code_pts = data.frame())
    expect_equal(nrow(x$location), 8)
    expect_equal(x$data, "W ETO C1 T1")
  }
)

# testthat::test_file("./tests/manual/manual_test_large_images.R")
