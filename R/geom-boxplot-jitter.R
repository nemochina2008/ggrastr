DrawGeomBoxplotJitter <- function(data, panel_params, coord, ...,
                                  outlier.jitter.width=NULL,
                                  outlier.jitter.height=0,
                                  outlier.colour = NULL,
                                  outlier.fill = NULL,
                                  outlier.shape = 19,
                                  outlier.size = 1.5,
                                  outlier.stroke = 0.5,
                                  outlier.alpha = NULL,
                                  raster=FALSE, raster.dpi=300,
                                  raster.width=NULL, raster.height=NULL
                                  ) {
  boxplot_grob <- ggplot2::GeomBoxplot$draw_group(data, panel_params, coord, ...)
  point_grob <- grep("geom_point.*", names(boxplot_grob$children))
  if (length(point_grob) == 0)
    return(boxplot_grob)

  ifnotnull <- function(x, y) if(is.null(x)) y else x

  if (is.null(outlier.jitter.width)) {
    outlier.jitter.width <- (data$xmax - data$xmin) / 2
  }

  x <- data$x[1]
  y <- data$outliers[[1]]
  if (outlier.jitter.width > 0 & length(y) > 1) {
    x <- jitter(rep(x, length(y)), amount=outlier.jitter.width)
  }

  if (outlier.jitter.height > 0 & length(y) > 1) {
    y <- jitter(y, amount=outlier.jitter.height)
  }

  outliers <- data.frame(
    x = x, y = y,
    colour = ifnotnull(outlier.colour, data$colour[1]),
    fill = ifnotnull(outlier.fill, data$fill[1]),
    shape = ifnotnull(outlier.shape, data$shape[1]),
    size = ifnotnull(outlier.size, data$size[1]),
    stroke = ifnotnull(outlier.stroke, data$stroke[1]),
    fill = NA,
    alpha = ifnotnull(outlier.alpha, data$alpha[1]),
    stringsAsFactors = FALSE
  )

  if (raster) {
    boxplot_grob$children[[point_grob]] <- GeomPointRast$draw_panel(outliers, panel_params, coord, width=raster.width,
                                                                    height=raster.height, dpi=raster.dpi)
  } else {
    boxplot_grob$children[[point_grob]] <- ggplot2::GeomPoint$draw_panel(outliers, panel_params, coord)
  }

  return(boxplot_grob)
}

GeomBoxplotJitter <- ggplot2::ggproto("GeomBoxplotJitter",
                                             ggplot2::GeomBoxplot,
                                             draw_group = DrawGeomBoxplotJitter)

#' This geom is similar to \code{\link[ggplot2]{geom_boxplot}}, but allows to jitter outlier points and to raster points layer.
#'
#' @inheritParams ggplot2::geom_boxplot
#' @inheritSection ggplot2::geom_boxplot Aesthetics
#'
#' @param outlier.jitter.width Amount of horizontal jitter. The jitter is added in both positive and negative directions,
#' so the total spread is twice the value specified here. Default: boxplot width.
#' @param outlier.jitter.height Amount of horizontal jitter. The jitter is added in both positive and negative directions,
#' so the total spread is twice the value specified here. Default: 0.
#' @param raster Should outlier points be rastered?.
#' @param dpi Resolution of the rastered image. Ignored if \code{raster == FALSE}.
#'
#' @examples
#' ggplot() + geom_boxplot_jitter(aes(y=rt(1000, df=3), x=as.factor(1:1000 %% 2)), outlier.jitter.width = 0.1, raster = T)
#'
#' @export
geom_boxplot_jitter <- function(mapping = NULL, data = NULL,
                                stat = "boxplot", position = "dodge",
                                na.rm = FALSE, show.legend = NA,
                                inherit.aes = TRUE, ...,
                                outlier.jitter.width=NULL,
                                outlier.jitter.height=0,
                                raster=FALSE, raster.dpi=300,
                                raster.width=NULL, raster.height=NULL
                                ) {
  ggplot2::layer(
    geom = GeomBoxplotJitter, mapping = mapping, data = data, stat = stat,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(na.rm = na.rm,
                  outlier.jitter.width=outlier.jitter.width,
                  outlier.jitter.height=outlier.jitter.height,
                  raster=raster, raster.dpi=raster.dpi,
                  raster.width=raster.width, raster.height=raster.height,
                  ...))
}
