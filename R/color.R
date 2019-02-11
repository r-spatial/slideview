## hex color conversion
col2Hex <- function(col, alpha = FALSE) {

  mat <- grDevices::col2rgb(col, alpha = TRUE)
  if (alpha) {
    hx <- grDevices::rgb(mat[1, ]/255, mat[2, ]/255,
                         mat[3, ]/255, mat[4, ]/255)
  } else {
    hx <- grDevices::rgb(mat[1, ]/255, mat[2, ]/255, mat[3, ]/255)
  }
  return(hx)

}
