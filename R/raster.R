# Convert RasterLayers to png or RasterStacks/Bricks to RGB png

## raster layer -----------------------------------------------------------
raster2PNG <- function(x,
                       col.regions,
                       at,
                       na.color,
                       maxpixels) {

  is_spatraster <- inherits(x, "SpatRaster")
  x <- rasterCheckSize(x, maxpixels = maxpixels, is_spatraster)
  if (is_spatraster) {
	mat <- t(terra::as.matrix(x, wide=TRUE))
  } else {
	mat <- t(raster::as.matrix(x))
  }
  if (missing(at)) at <- lattice::do.breaks(range(mat, na.rm = TRUE), 256)

  cols <- lattice::level.colors(mat,
                                at = at,
                                col.regions = col.regions)
  cols[is.na(cols)] = na.color
  cols = col2Hex(cols, alpha = TRUE)
  #cols <- clrs(t(mat))
  png_dat <- as.raw(grDevices::col2rgb(cols, alpha = TRUE))
  dim(png_dat) <- c(4, ncol(x), nrow(x))

  return(png_dat)
}


## raster stack/brick -----------------------------------------------------

rgbStack2PNG <- function(x, r, g, b,
                         na.color,
                         quantiles = c(0.02, 0.98),
                         maxpixels,
                         ...) {

  is_spatraster <- inherits(x, "SpatRaster")
  x <- rasterCheckSize(x, maxpixels = maxpixels, is_spatraster)

  x <- x[[c(r, g, b)]]
  mat <- values(x)
 
  for(i in seq(ncol(mat))){
    z <- mat[, i]
    lwr <- stats::quantile(z, quantiles[1], na.rm = TRUE)
    upr <- stats::quantile(z, quantiles[2], na.rm = TRUE)
    z <- (z - lwr) / (upr - lwr)
    z[z < 0] <- 0
    z[z > 1] <- 1
    mat[, i] <- z
  }

  na_indx <- apply(mat, 1, base::anyNA) # rowNA(mat)
  cols <- rep(na.color, nrow(mat)) #mat[, 1] #
  #cols[na_indx] <- na.color
  cols[!na_indx] <- grDevices::rgb(mat[!na_indx, ], alpha = 1)
  png_dat <- as.raw(grDevices::col2rgb(cols, alpha = TRUE))
  dim(png_dat) <- c(4, ncol(x), nrow(x))

  return(png_dat)
}


rasterCheckSize <- function(x, maxpixels, is_spatraster) {
  if (maxpixels < raster::ncell(x)) {
    warning(paste("maximum number of pixels for Raster* viewing is",
                  maxpixels, "; \nthe supplied Raster* has", raster::ncell(x), "\n",
                  "... decreasing Raster* resolution to", maxpixels, "pixels\n",
                  "to view full resolution set 'maxpixels = ", raster::ncell(x), "'"))
    if (is_spatraster) {
		x <- terra::spatSample(x, maxpixels, "regular", as.raster = TRUE)	
	} else {
		x <- raster::sampleRegular(x, maxpixels, asRaster = TRUE, useGDAL = TRUE)
	}
  }
  return(x)
}
