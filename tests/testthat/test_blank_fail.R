context("Graceful failure")

test_that(
  "A blank image produces a named list with two dfs of zero rows with named cols without JS",
  {
    x <- qr_scan(magick::image_blank(5,5, "green"), no_js = TRUE)
    expect_equal(length(x), 2)
    expect_equal(
      unlist(lapply(x, class), use.names = FALSE), 
      c("data.frame", "data.frame")
      )
    expect_equal(names(x), c("values", "points"))
    expect_equal(names(x$values), c("id", "value"))
    expect_equal(names(x$points), c("id", "x", "y"))
    expect_equal(nrow(x$values), 0)
    expect_equal(nrow(x$points), 0)
  }
)

test_that(
  "A blank image produces a named list with two dfs of zero rows and zero cols with JS",
  {
    skip_if_not(qr_v8_checker_())
    x <- qr_scan(magick::image_blank(5,5, "green"), force_js = TRUE)
    expect_equal(length(x), 2)
    expect_equal(
      unlist(lapply(x, class), use.names = FALSE), 
      c("data.frame", "data.frame")
      )
    expect_equal(names(x), c("values", "points"))
    expect_equal(unlist(lapply(x, ncol), use.names = FALSE), c(0, 0))
    expect_equal(nrow(x$values), 0)
    expect_equal(nrow(x$points), 0)
  }
)
