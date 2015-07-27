---
layout: post
title: Another one!
author: michel
---

This is just another test to see if everything works out.


{% highlight r %}
library(mlr)
{% endhighlight %}



{% highlight text %}
## Loading required package: BBmisc
## Loading required package: ggplot2
## Loading required package: methods
## Loading required package: ParamHelpers
{% endhighlight %}



{% highlight r %}
plotLearnerPrediction("classif.randomForest", iris.task)
{% endhighlight %}

![plot of chunk mlr-example-plot](../figures/mlr-example-plot-1.svg) 
