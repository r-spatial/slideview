## legend for plainview, slideview, cubeview ==============================
rasterLegend <- function(key) {
  lattice::draw.colorkey(key = key, draw = TRUE)
}
