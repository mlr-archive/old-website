---
layout: post
title: Visualization of spatial cross-validation partitioning
author: patrick
draft: true 
---

# Introduction

In July `mlr` got a new feature that extended the support for spatial data: The ability to visualize spatial partitions in cross-validation (CV).
When one uses the resampling description "SpCV" or "SpRepCV" in `mlr`, the k-means clustering approach after Brenning (2005) is used to partition the dataset into equally sized, spatially disjoint subsets.
See also [this](https://www.r-spatial.org/r/2018/03/03/spatial-modeling-mlr.html) post on r-spatial.org and the [vignette](http://mlr-org.github.io/mlr/articles/handling_of_spatial_data.html) about spatial data handling for more information.

# Visualization of partitions

When using random partitiong in the default cross-validation approach, one is usually not interested in the random pattern of the datasets train/test splitting.
However, for spatial data this information is important since it can help identifying problematic folds (ones that did not converge or showed a bad performance) and also prooves that the k-means clustering algorithm did a good job on partitioning the dataset.

The new function is called `createSpatialResamplingPlots()`. 
It uses `ggplot2` and its new `geom_sf()` function to create spatial plots based on resampling indices of a `resample()` object.

In this post I will use the examples of the function to demonstrate its use.

First, we create a resampling description using a spatial partitioning with five folds and repeat ir 4 times.
This `rdesc` object is put into a `resample()` call together with our example task for spatial stuff, `spatial.task`.
The only requirement here is to have a "spatial" task, meaning a task that also comes with coordinate information. 
Otherwise we cannot use spatial partitioning in the first place.
Finally, we use the `classif.qda` learner to have a quick model fit.


{% highlight r %}
library(mlr)
{% endhighlight %}



{% highlight text %}
## Loading required package: ParamHelpers
{% endhighlight %}



{% highlight r %}
rdesc = makeResampleDesc("SpRepCV", folds = 5, reps = 4)
r = resample(makeLearner("classif.qda"), spatial.task, rdesc)
{% endhighlight %}



{% highlight text %}
## Resampling: repeated spatial cross-validation
{% endhighlight %}



{% highlight text %}
## Measures:             mmce
{% endhighlight %}



{% highlight text %}
## [Resample] iter 1:    0.5988701
{% endhighlight %}



{% highlight text %}
## [Resample] iter 2:    0.3396226
{% endhighlight %}



{% highlight text %}
## [Resample] iter 3:    0.2824427
{% endhighlight %}



{% highlight text %}
## [Resample] iter 4:    0.3239437
{% endhighlight %}



{% highlight text %}
## [Resample] iter 5:    0.4366197
{% endhighlight %}



{% highlight text %}
## [Resample] iter 6:    0.3354037
{% endhighlight %}



{% highlight text %}
## [Resample] iter 7:    0.2689655
{% endhighlight %}



{% highlight text %}
## [Resample] iter 8:    0.5773810
{% endhighlight %}



{% highlight text %}
## [Resample] iter 9:    0.3312102
{% endhighlight %}



{% highlight text %}
## [Resample] iter 10:   0.5083333
{% endhighlight %}



{% highlight text %}
## [Resample] iter 11:   0.5083333
{% endhighlight %}



{% highlight text %}
## [Resample] iter 12:   0.3312102
{% endhighlight %}



{% highlight text %}
## [Resample] iter 13:   0.2689655
{% endhighlight %}



{% highlight text %}
## [Resample] iter 14:   0.3354037
{% endhighlight %}



{% highlight text %}
## [Resample] iter 15:   0.5773810
{% endhighlight %}



{% highlight text %}
## [Resample] iter 16:   0.2824427
{% endhighlight %}



{% highlight text %}
## [Resample] iter 17:   0.3396226
{% endhighlight %}



{% highlight text %}
## [Resample] iter 18:   0.3239437
{% endhighlight %}



{% highlight text %}
## [Resample] iter 19:   0.5988701
{% endhighlight %}



{% highlight text %}
## [Resample] iter 20:   0.4366197
{% endhighlight %}



{% highlight text %}
## 
{% endhighlight %}



{% highlight text %}
## Aggregated Result: mmce.test.mean=0.4002793
{% endhighlight %}



{% highlight text %}
## 
{% endhighlight %}

Now we can use `createSpatialResamplingPlots()` to automatically create one plot for each fold of our `r` object.
Usually we do not want to plot all repetitions of the CV.
We can restrict the number of repetitions in the argument `repetitions`.
Besides the required arguments `task` and `resample`, the user can specifiy the coordinate reference system that should be used for the plots.
Here it is important to set the correct EPSG number in argument `crs` to receive accurate spatial plots.
In the background, `geom_sf()` (more specifically `coords_sf()`) will transform the CRS on the fly to EPSG: 4326.
This is done because lat/lon reference systems are better for plotting as UTM coordinates usually clutter the axis.
However, if you insist on using UTM projection instead of WGS84 (EPSG: 4326) you can set the EPSG code of your choice in argument `datum`.


{% highlight r %}
plots = createSpatialResamplingPlots(spatial.task, r, crs = 32717,
  repetitions = 2, x.axis.breaks = c(-79.065, -79.085),
  y.axis.breaks = c(-3.970, -4))
{% endhighlight %}

To avoid overlapping axis breaks you might have to set the axis breaks on your own as we did it in the example.

Now we got a list of 2L back from calling the function. 
In the first list we got all the plots, one for each fold.
Since we used two repetitions and five folds, we have ten plots in there.

The second list consists of labels for each plot.
These are automatically created by `createSpatialResamplingPlots()` and can serve as titles later on.
Note that for now we just created the `ggplot` objects.
We did not plot them yet.

The plotting is left to the user.
Single `ggplot` objects can be plotted by just extracting a certain object from the list, e.g. `plots[[1]][[3]]`.
This would plot fold #3 of repetition one.


{% highlight r %}
plots[[1]][[3]]
{% endhighlight %}



{% highlight text %}
## Warning in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x,
## x$y, : font family 'Roboto Condensed' not found in PostScript font
## database
{% endhighlight %}



{% highlight text %}
## Warning in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x,
## x$y, : font family 'Roboto Condensed' not found in PostScript font
## database
{% endhighlight %}



{% highlight text %}
## Warning in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x,
## x$y, : font family 'Roboto Condensed' not found in PostScript font
## database
{% endhighlight %}



{% highlight text %}
## Warning in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x,
## x$y, : font family 'Roboto Condensed' not found in PostScript font
## database
{% endhighlight %}



{% highlight text %}
## Warning in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x,
## x$y, : font family 'Roboto Condensed' not found in PostScript font
## database
{% endhighlight %}



{% highlight text %}
## Warning in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x,
## x$y, : font family 'Roboto Condensed' not found in PostScript font
## database
{% endhighlight %}



{% highlight text %}
## Warning in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x,
## x$y, : font CMap for family 'Roboto Condensed' not found in font
## database
{% endhighlight %}



{% highlight text %}
## Error in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, : failed to find or load PDF CID font
{% endhighlight %}

<img src="/figures/2018-07-25-visualize-spatial-cv/unnamed-chunk-3-1.svg" title="plot of chunk unnamed-chunk-3" alt="plot of chunk unnamed-chunk-3" style="display: block; margin: auto;" />
However usually we want to visualize all plots in a grid.
For this purpose we highly recommend to use the `cowplot` package and its function `plot_grid()`.

The returned objects of `createSpatialResamplingPlots()` are already tailored to be used with this function.
We just need to hand over the list of plots and (optional) the labels:


{% highlight r %}
cowplot::plot_grid(plotlist = plots[["Plots"]], ncol = 5, nrow = 2,
  labels = plots[["Labels"]])
{% endhighlight %}



{% highlight text %}
## Warning in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x,
## x$y, : font family 'Roboto Condensed' not found in PostScript font
## database
{% endhighlight %}



{% highlight text %}
## Warning in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x,
## x$y, : font family 'Roboto Condensed' not found in PostScript font
## database
{% endhighlight %}



{% highlight text %}
## Warning in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x,
## x$y, : font family 'Roboto Condensed' not found in PostScript font
## database
{% endhighlight %}



{% highlight text %}
## Warning in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x,
## x$y, : font family 'Roboto Condensed' not found in PostScript font
## database
{% endhighlight %}



{% highlight text %}
## Warning in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x,
## x$y, : font family 'Roboto Condensed' not found in PostScript font
## database
{% endhighlight %}



{% highlight text %}
## Warning in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x,
## x$y, : font family 'Roboto Condensed' not found in PostScript font
## database
{% endhighlight %}



{% highlight text %}
## Warning in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x,
## x$y, : font CMap for family 'Roboto Condensed' not found in font
## database
{% endhighlight %}



{% highlight text %}
## Error in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, : failed to find or load PDF CID font
{% endhighlight %}

<img src="/figures/2018-07-25-visualize-spatial-cv/unnamed-chunk-4-1.svg" title="plot of chunk unnamed-chunk-4" alt="plot of chunk unnamed-chunk-4" style="display: block; margin: auto;" />

# Multiple resample objects

`createSpatialResamplingPlots()` is quite powerful and can also take multiple `resample()` objects as inputs with the aim to compare both.
A typical use case is to visualize the differences between spatial and non-spatial partitioning.

To do so, we first create two `resample()` objects (one using "SpRepCV", one using "RepCV"):


{% highlight r %}
rdesc1 = makeResampleDesc("SpRepCV", folds = 5, reps = 4)
r1 = resample(makeLearner("classif.qda"), spatial.task, rdesc1)
{% endhighlight %}



{% highlight text %}
## Resampling: repeated spatial cross-validation
{% endhighlight %}



{% highlight text %}
## Measures:             mmce
{% endhighlight %}



{% highlight text %}
## [Resample] iter 1:    0.3395062
{% endhighlight %}



{% highlight text %}
## [Resample] iter 2:    0.5042735
{% endhighlight %}



{% highlight text %}
## [Resample] iter 3:    0.6035503
{% endhighlight %}



{% highlight text %}
## [Resample] iter 4:    0.3354430
{% endhighlight %}



{% highlight text %}
## [Resample] iter 5:    0.2689655
{% endhighlight %}



{% highlight text %}
## [Resample] iter 6:    0.5083333
{% endhighlight %}



{% highlight text %}
## [Resample] iter 7:    0.5773810
{% endhighlight %}



{% highlight text %}
## [Resample] iter 8:    0.3354037
{% endhighlight %}



{% highlight text %}
## [Resample] iter 9:    0.2689655
{% endhighlight %}



{% highlight text %}
## [Resample] iter 10:   0.3312102
{% endhighlight %}



{% highlight text %}
## [Resample] iter 11:   0.4375000
{% endhighlight %}



{% highlight text %}
## [Resample] iter 12:   0.3308824
{% endhighlight %}



{% highlight text %}
## [Resample] iter 13:   0.3354037
{% endhighlight %}



{% highlight text %}
## [Resample] iter 14:   0.5988701
{% endhighlight %}



{% highlight text %}
## [Resample] iter 15:   0.2781955
{% endhighlight %}



{% highlight text %}
## [Resample] iter 16:   0.3333333
{% endhighlight %}



{% highlight text %}
## [Resample] iter 17:   0.2719298
{% endhighlight %}



{% highlight text %}
## [Resample] iter 18:   0.3353293
{% endhighlight %}



{% highlight text %}
## [Resample] iter 19:   0.5106383
{% endhighlight %}



{% highlight text %}
## [Resample] iter 20:   0.3010204
{% endhighlight %}



{% highlight text %}
## 
{% endhighlight %}



{% highlight text %}
## Aggregated Result: mmce.test.mean=0.3903068
{% endhighlight %}



{% highlight text %}
## 
{% endhighlight %}



{% highlight r %}
rdesc2 = makeResampleDesc("RepCV", folds = 5, reps = 4)
r2 = resample(makeLearner("classif.qda"), spatial.task, rdesc2)
{% endhighlight %}



{% highlight text %}
## Resampling: repeated cross-validation
{% endhighlight %}



{% highlight text %}
## Measures:             mmce
{% endhighlight %}



{% highlight text %}
## [Resample] iter 1:    0.3600000
{% endhighlight %}



{% highlight text %}
## [Resample] iter 2:    0.3933333
{% endhighlight %}



{% highlight text %}
## [Resample] iter 3:    0.3377483
{% endhighlight %}



{% highlight text %}
## [Resample] iter 4:    0.2866667
{% endhighlight %}



{% highlight text %}
## [Resample] iter 5:    0.3133333
{% endhighlight %}



{% highlight text %}
## [Resample] iter 6:    0.3800000
{% endhighlight %}



{% highlight text %}
## [Resample] iter 7:    0.3533333
{% endhighlight %}



{% highlight text %}
## [Resample] iter 8:    0.3178808
{% endhighlight %}



{% highlight text %}
## [Resample] iter 9:    0.3533333
{% endhighlight %}



{% highlight text %}
## [Resample] iter 10:   0.2733333
{% endhighlight %}



{% highlight text %}
## [Resample] iter 11:   0.4000000
{% endhighlight %}



{% highlight text %}
## [Resample] iter 12:   0.2980132
{% endhighlight %}



{% highlight text %}
## [Resample] iter 13:   0.3533333
{% endhighlight %}



{% highlight text %}
## [Resample] iter 14:   0.2933333
{% endhighlight %}



{% highlight text %}
## [Resample] iter 15:   0.3400000
{% endhighlight %}



{% highlight text %}
## [Resample] iter 16:   0.3066667
{% endhighlight %}



{% highlight text %}
## [Resample] iter 17:   0.3046358
{% endhighlight %}



{% highlight text %}
## [Resample] iter 18:   0.3933333
{% endhighlight %}



{% highlight text %}
## [Resample] iter 19:   0.3733333
{% endhighlight %}



{% highlight text %}
## [Resample] iter 20:   0.3066667
{% endhighlight %}



{% highlight text %}
## 
{% endhighlight %}



{% highlight text %}
## Aggregated Result: mmce.test.mean=0.3369139
{% endhighlight %}



{% highlight text %}
## 
{% endhighlight %}

Now we can hand over both objects using a named list. 
This way the list names will also directly be used as a prefix in the resulting plot labels.


{% highlight r %}
plots = createSpatialResamplingPlots(spatial.task,
  list("SpRepCV" = r1, "RepCV" = r2), crs = 32717, repetitions = 1,
  x.axis.breaks = c(-79.055, -79.085), y.axis.breaks = c(-3.975, -4))

cowplot::plot_grid(plotlist = plots[["Plots"]], ncol = 5, nrow = 2,
  labels = plots[["Labels"]])
{% endhighlight %}



{% highlight text %}
## Warning in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x,
## x$y, : font family 'Roboto Condensed' not found in PostScript font
## database
{% endhighlight %}



{% highlight text %}
## Warning in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x,
## x$y, : font family 'Roboto Condensed' not found in PostScript font
## database
{% endhighlight %}



{% highlight text %}
## Warning in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x,
## x$y, : font family 'Roboto Condensed' not found in PostScript font
## database
{% endhighlight %}



{% highlight text %}
## Warning in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x,
## x$y, : font family 'Roboto Condensed' not found in PostScript font
## database
{% endhighlight %}



{% highlight text %}
## Warning in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x,
## x$y, : font family 'Roboto Condensed' not found in PostScript font
## database
{% endhighlight %}



{% highlight text %}
## Warning in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x,
## x$y, : font family 'Roboto Condensed' not found in PostScript font
## database
{% endhighlight %}



{% highlight text %}
## Warning in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x,
## x$y, : font family 'Roboto Condensed' not found in PostScript font
## database
{% endhighlight %}



{% highlight text %}
## Warning in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x,
## x$y, : font CMap for family 'Roboto Condensed' not found in font
## database
{% endhighlight %}



{% highlight text %}
## Error in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, : failed to find or load PDF CID font
{% endhighlight %}

<img src="/figures/2018-07-25-visualize-spatial-cv/unnamed-chunk-6-1.svg" title="plot of chunk unnamed-chunk-6" alt="plot of chunk unnamed-chunk-6" style="display: block; margin: auto;" />



# References

Brenning, A. (2012). Spatial cross-validation and bootstrap for the assessment of prediction rules in remote sensing: The R package sperrorest. In 2012 IEEE International Geoscience and Remote Sensing Symposium. IEEE. https://doi.org/10.1109/igarss.2012.6352393




