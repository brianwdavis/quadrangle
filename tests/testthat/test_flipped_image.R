context("Flipped images can be read by JS but not C++")

test_that(
  "Flipped image is detected but not read with C++",
  {
    x <- system.file("test_original.jpg", package = "quadrangle") %>% 
      qr_scan(flop = FALSE, no_js = TRUE)
    expect_equal(length(x), 2)
    expect_equal(
      unlist(lapply(x, class), use.names = FALSE), 
      c("data.frame", "data.frame")
    )
    expect_equal(names(x), c("values", "points"))
    expect_equal(names(x$values), c("id", "value"))
    expect_equal(names(x$points), c("id", "x", "y"))
    expect_equal(nrow(x$values), 1)
    expect_equal(nrow(x$points), 4)
    expect_equal(x$values$value, "")
  }
)

test_that(
  "Flipped image is detected and read with JS",
  {
    skip_if_not(qr_v8_checker_())
    x <- system.file("test_original.jpg", package = "quadrangle") %>% 
      qr_scan(flop = FALSE, force_js = TRUE)
    expect_equal(length(x), 2)
    expect_equal(
      unlist(lapply(x, class), use.names = FALSE), 
      c("data.frame", "data.frame")
    )
    expect_equal(names(x), c("values", "points"))
    expect_equal(names(x$values), c("id", "type", "value"))
    expect_equal(names(x$points), c("id", "corner", "x", "y"))
    expect_equal(nrow(x$values), 1)
    expect_equal(nrow(x$points), 8)
    expect_equal(x$values$value, "W XYZ B0 T1")
  }
)
