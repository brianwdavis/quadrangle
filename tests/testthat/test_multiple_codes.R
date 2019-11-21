context("Multiple codes can be read")

test_that(
  "An image with 3 QR codes detects it with C++",
  {
    x <- system.file("multiple_original.png", package = "quadrangle") %>% 
      qr_scan()
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
    expect_equal(
      sort(x$values$value),
      c("in a single image", "This is a test", "to detect multiple QR codes")
    )
  }
)

test_that(
  "An image with 3 QR codes detects it with JS",
  {
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
    expect_equal(
      sort(x$values$value),
      c("in a single image", "This is a test", "to detect multiple QR codes")
    )
  }
)
