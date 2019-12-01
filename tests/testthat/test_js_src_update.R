context("Network needed - Updating JS source and resetting")

test_that(
  "JS source can be pulled from GitHub",
  {
    skip_if_not(qr_v8_checker_())
    skip_if_offline()
    skip_on_cran()
    
    temp_path <- tempdir()
    
    new_src <- suppressMessages(
      qr_js_src_update(local_path = temp_path)
    )
    
    expect_true(file.exists(new_src))
    expect_match(basename(new_src), "^jsQR_.+js$")
    
    new_src_string <- paste(
      readLines(new_src, warn = FALSE), 
      collapse = "\n"
    )
    expect_gt(nchar(new_src_string), 200000)
    expect_true(V8::v8()$validate(new_src_string))
  }
)

test_that(
  "JS source can be reset",
  {
    skip_if_not(qr_v8_checker_())
    old_src <- qr_js_src_update(reset = TRUE)
    
    expect_true(file.exists(old_src))
    expect_match(basename(old_src), "^jsQR.js$")
    
    old_src_string <- paste(
      readLines(old_src, warn = FALSE), 
      collapse = "\n"
    )
    expect_gt(nchar(old_src_string), 200000)
    expect_true(V8::v8()$validate(old_src_string))
  }
)
