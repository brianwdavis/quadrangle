context("Multiple codes can be read")

test_that(
  "An image with 3 QR codes detects it with C++",
  {
    x <- system.file("multiple_original.png", package = "quadrangle") %>% 
      qr_scan(no_js = TRUE)
    expect_equal(length(x), 2)
    expect_equal(
      unlist(lapply(x, class), use.names = FALSE), 
      c("data.frame", "data.frame")
    )
    expect_equal(names(x), c("values", "points"))
    expect_equal(names(x$values), c("id", "value"))
    expect_equal(names(x$points), c("id", "x", "y"))
    expect_equal(nrow(x$values), 3)
    expect_equal(nrow(x$points), 12)
    expect_setequal(
      x$values$value,
      c("This is a test", "to detect multiple QR codes", "in a single image")
    )
  }
)

test_that(
  "An image with 3 QR codes detects it with JS",
  {
    skip_if_not(qr_v8_checker_())
    x <- system.file("multiple_original.png", package = "quadrangle") %>% 
      qr_scan(force_js = TRUE)
    expect_equal(length(x), 2)
    expect_equal(
      unlist(lapply(x, class), use.names = FALSE), 
      c("data.frame", "data.frame")
    )
    expect_equal(names(x), c("values", "points"))
    expect_equal(names(x$values), c("id", "type", "value"))
    expect_equal(names(x$points), c("id", "corner", "x", "y"))
    expect_equal(nrow(x$values), 3)
    expect_equal(nrow(x$points), 24)
    expect_setequal(
      x$values$value,
      c("This is a test", "to detect multiple QR codes", "in a single image")
    )
  }
)
