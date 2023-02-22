context("Encoding latin1 can be read with JS")

test_that(
  "An image with latin1 encoded text read with JS",
  {
    skip_if_not(qr_v8_checker_())
    x <- system.file("latin1_small_umlaut.png", package = "quadrangle") %>% 
      qr_scan(force_js = TRUE)
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
    zurich_latin1 <- "Z\xfcrich"
    Encoding(zurich_latin1) <- "latin1"
    expect_equal(x$values$value, zurich_latin1)
  }
)
