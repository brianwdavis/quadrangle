context("ECI 26 can be read with JS")

test_that(
  "An image with ECI 26 read with JS",
  {
    skip_if_not(qr_v8_checker_())
    x <- system.file("eci_26_simple.png", package = "quadrangle") %>% 
      qr_scan(force_js = TRUE)
    expect_equal(length(x), 2)
    expect_equal(
      unlist(lapply(x, class), use.names = FALSE), 
      c("data.frame", "data.frame")
    )
    expect_equal(names(x), c("values", "points"))
    expect_equal(names(x$values)[c(1, 2, 3)], c("id", "type", "value"))
    expect_equal(names(x$points), c("id", "corner", "x", "y"))
    expect_equal(nrow(x$values), 2)
    expect_equal(nrow(x$points), 8)
    vs <- x[["values"]]
    extract_text <- vs[vs[["type"]] == "byte", "value"]
    expect_equal(extract_text, "7948,328,1019,149,12,12,15,4,14,11,32,4")
  }
)
