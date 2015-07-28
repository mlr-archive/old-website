---
layout: post
title: Visualisation of predictions
author: jakob
---

In our second post we want to shortly introduce you to the great visualization possibilities of `mlr`.
Within the last months a lot of work has been put into that field.
This post is not a [tutorial](http://mlr-org.github.io/mlr-tutorial/) but more a demonstration of how little code you have write with `mlr` to get some nice plots showing the prediction areas of different learners.

<!--more-->

First we define a list containing all the [learners](http://mlr-org.github.io/mlr-tutorial/release/html/integrated_learners/index.html) we want to visualize.
Notice that most of the `mlr` methods are able to work with just the string as `"classif.svm"` to know what learner you mean.
Nevertheless you can define the learner more precisely with `makeLearner()` and set some parameters such as the `kernel` in this example.


{% highlight r %}
library(mlr)
learners = list(
  "classif.randomForest", 
  makeLearner("classif.svm", kernel = "linear"),
  makeLearner("classif.svm", kernel = "polynomial"),
  makeLearner("classif.svm", kernel = "radial"), 
  "classif.qda", 
  "classif.knn"
  )
for(lrn in learners) {
  print(plotLearnerPrediction(lrn, iris.task))
}
{% endhighlight %}

![plot of chunk mlr-example-plot](../figures/mlr-example-plot-1.svg) ![plot of chunk mlr-example-plot](../figures/mlr-example-plot-2.svg) ![plot of chunk mlr-example-plot](../figures/mlr-example-plot-3.svg) ![plot of chunk mlr-example-plot](../figures/mlr-example-plot-4.svg) ![plot of chunk mlr-example-plot](../figures/mlr-example-plot-5.svg) ![plot of chunk mlr-example-plot](../figures/mlr-example-plot-6.svg) 
