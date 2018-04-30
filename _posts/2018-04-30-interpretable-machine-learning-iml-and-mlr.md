---
layout: post
title: Interpretable Machine Learning with iml and mlr
author: christoph
draft: true 
---



Machine learning models repeatedly outperform interpretable, parametric models like the linear regression model. 
The gains in performance have a price: The models operate as black boxes which are not interpretable.

Fortunately, there are many methods that can make machine learning models interpretable. 
The R package `iml` provides tools for analysing any black box machine learning model:

<!--more-->
* Feature importance: Which were the most important features?

* Feature effects: How does a feature influence the prediction? (Partial dependence plots and individual conditional expectation curves)

* Explanations for single predictions: How did the feature values of a single data point affect its prediction?  (LIME and Shapley value)

* Surrogate trees: Can we approximate the underlying black box model with a short decision tree?

* The iml package works for any classification and regression machine learning model: random forests, linear models, neural networks, xgboost, etc.

This blog post shows you how to use the `iml` package to analyse machine learning models. 
While the `mlr` package makes it super easy to train machine learning models, the `iml` package makes it easy to extract insights about the learned black box machine learning models.

If you want to learn more about the technical details of all the methods, read the [Interpretable Machine Learning book]( https://christophm.github.io/interpretable-ml-book/agnostic.html).

![Time for Interpretable Machine Learning](../images/2018-04-27-interpretable-machine-learning-iml-and-mlr/iml-bear.jpg)

Let's explore the `iml`-toolbox for interpreting an `mlr` machine learning model with concrete examples!

## Data: Boston Housing

We'll use the `MASS::Boston` dataset to demonstrate the abilities of the iml package. This dataset contains median house values from Boston neighbourhoods. 


{% highlight r %}
data("Boston", package  = "MASS")
head(Boston)
{% endhighlight %}



{% highlight text %}
#>      crim zn indus chas   nox    rm  age    dis rad tax ptratio
#> 1 0.00632 18  2.31    0 0.538 6.575 65.2 4.0900   1 296    15.3
#> 2 0.02731  0  7.07    0 0.469 6.421 78.9 4.9671   2 242    17.8
#> 3 0.02729  0  7.07    0 0.469 7.185 61.1 4.9671   2 242    17.8
#> 4 0.03237  0  2.18    0 0.458 6.998 45.8 6.0622   3 222    18.7
#> 5 0.06905  0  2.18    0 0.458 7.147 54.2 6.0622   3 222    18.7
#> 6 0.02985  0  2.18    0 0.458 6.430 58.7 6.0622   3 222    18.7
#>    black lstat medv
#> 1 396.90  4.98 24.0
#> 2 396.90  9.14 21.6
#> 3 392.83  4.03 34.7
#> 4 394.63  2.94 33.4
#> 5 396.90  5.33 36.2
#> 6 394.12  5.21 28.7
{% endhighlight %}


## Fitting the machine learning model

First we train a randomForest to predict the Boston median housing value:


{% highlight r %}
library("mlr")
data("Boston", package  = "MASS")

# create an mlr task and model
tsk = makeRegrTask(data = Boston, target = "medv")
lrn = makeLearner("regr.randomForest", ntree = 100)
mod = train(lrn, tsk)
{% endhighlight %}

## Using the iml Predictor container

We create a `Predictor` object, that holds the model and the data. The `iml` package uses R6 classes: New objects can be created by calling `Predictor$new()`.
`Predictor` works best with mlr models (`WrappedModel`-class), but it is also possible to use models from other packages.


{% highlight r %}
library("iml")
X = Boston[which(names(Boston) != "medv")]
predictor = Predictor$new(mod, data = X, y = Boston$medv)
{% endhighlight %}


## Feature importance

We can measure how important each feature was for the predictions with `FeatureImp`. The feature importance measure works by shuffling each feature and measuring how much the performance drops. For this regression task we choose to measure the loss in performance with the mean absolute error ('mae'); another choice would be the  mean squared error ('mse').


Once we created a new object of `FeatureImp`, the importance is automatically computed. 
We can call the `plot()` function of the object or look at the results in a data.frame.

{% highlight r %}
imp = FeatureImp$new(predictor, loss = "mae")
plot(imp)
{% endhighlight %}

![plot of chunk unnamed-chunk-5](/figures/2018-04-30-interpretable-machine-learning-iml-and-mlr/unnamed-chunk-5-1.svg)

{% highlight r %}
imp$results
{% endhighlight %}



{% highlight text %}
#>    feature original.error permutation.error importance
#> 1    lstat       0.929379         4.3533565   4.684156
#> 2       rm       0.929379         3.0678264   3.300942
#> 3      nox       0.929379         1.6636358   1.790051
#> 4      dis       0.929379         1.6288497   1.752622
#> 5     crim       0.929379         1.6115494   1.734007
#> 6  ptratio       0.929379         1.5988103   1.720300
#> 7    indus       0.929379         1.4023210   1.508880
#> 8      tax       0.929379         1.3150335   1.414959
#> 9      age       0.929379         1.2712218   1.367819
#> 10   black       0.929379         1.1936640   1.284367
#> 11     rad       0.929379         1.0826712   1.164941
#> 12    chas       0.929379         0.9753240   1.049436
#> 13      zn       0.929379         0.9585688   1.031408
{% endhighlight %}

## Partial dependence

Besides learning which features were important, we are interested in how the features influence the predicted outcome. The `Partial` class implements partial dependence plots and individual conditional expectation curves. Each individual line represents the predictions (y-axis) for one data point when we change one of the features (e.g. 'lstat' on the x-axis). The highlighted line is the point-wise average of the individual lines and equals the partial dependence plot. The marks on the x-axis indicates the distribution of the 'lstat' feature, showing how relevant a region is for interpretation (little or no points mean that we should not over-interpret this region).


{% highlight r %}
pdp.obj = Partial$new(predictor, feature = "lstat")
plot(pdp.obj)
{% endhighlight %}

![plot of chunk unnamed-chunk-6](/figures/2018-04-30-interpretable-machine-learning-iml-and-mlr/unnamed-chunk-6-1.svg)

If we want to compute the partial dependence curves for another feature, we can simply reset the feature.
Also, we can center the curves at a feature value of our choice, which makes it easier to see the trend of the curves:


{% highlight r %}
pdp.obj$set.feature("rm")
pdp.obj$center(min(Boston$rm))
plot(pdp.obj)
{% endhighlight %}

![plot of chunk unnamed-chunk-7](/figures/2018-04-30-interpretable-machine-learning-iml-and-mlr/unnamed-chunk-7-1.svg)

## Surrogate model
Another way to make the models more interpretable is to replace the black box with a simpler model - a decision tree. We take the predictions of the black box model (in our case the random forest) and train a decision tree on the original features and the predicted outcome. 
The plot shows the terminal nodes of the fitted tree.
The maxdepth parameter controls how deep the tree can grow and therefore how interpretable it is.

{% highlight r %}
tree = TreeSurrogate$new(predictor, maxdepth = 2)
plot(tree)
{% endhighlight %}

![plot of chunk unnamed-chunk-8](/figures/2018-04-30-interpretable-machine-learning-iml-and-mlr/unnamed-chunk-8-1.svg)


We can use the tree to make predictions:


{% highlight r %}
head(tree$predict(Boston))
{% endhighlight %}



{% highlight text %}
#>     .y.hat
#> 1 28.43299
#> 2 21.74169
#> 3 28.43299
#> 4 28.43299
#> 5 28.43299
#> 6 28.43299
{% endhighlight %}

## Explain single predictions with a local model
Global surrogate model can improve the understanding of the global model behaviour. 
We can also fit a model locally to understand an individual prediction better. The local model fitted by `LocalModel` is a linear regression model and the data points are weighted by how close they are to the data point for wich we want to explain the prediction.


{% highlight r %}
lime.explain = LocalModel$new(predictor, x.interest = X[1,])
lime.explain$results
{% endhighlight %}



{% highlight text %}
#>               beta x.recoded    effect x.original feature
#> rm       4.3190928     6.575 28.398035      6.575      rm
#> ptratio -0.5285876    15.300 -8.087391       15.3 ptratio
#> lstat   -0.4273493     4.980 -2.128199       4.98   lstat
#>         feature.value
#> rm           rm=6.575
#> ptratio  ptratio=15.3
#> lstat      lstat=4.98
{% endhighlight %}



{% highlight r %}
plot(lime.explain)
{% endhighlight %}

![plot of chunk unnamed-chunk-10](/figures/2018-04-30-interpretable-machine-learning-iml-and-mlr/unnamed-chunk-10-1.svg)

## Explain single predictions with game theory
An alternative for explaining individual predictions is a method from coalitional game theory named Shapley value.
Assume that for one data point, the feature values play a game together, in which they get the prediction as a payout. The Shapley value tells us how to fairly distribute the payout among the feature values.



{% highlight r %}
shapley = Shapley$new(predictor, x.interest = X[1,])
plot(shapley)
{% endhighlight %}

![plot of chunk unnamed-chunk-11](/figures/2018-04-30-interpretable-machine-learning-iml-and-mlr/unnamed-chunk-11-1.svg)

We can reuse the object to explain other data points:


{% highlight r %}
shapley$explain(x.interest = X[2,])
plot(shapley)
{% endhighlight %}

![plot of chunk unnamed-chunk-12](/figures/2018-04-30-interpretable-machine-learning-iml-and-mlr/unnamed-chunk-12-1.svg)

The results in data.frame form can be extracted like this:


{% highlight r %}
results = shapley$results
head(results)
{% endhighlight %}



{% highlight text %}
#>   feature         phi      phi.var feature.value
#> 1    crim -0.02168342  1.071941296  crim=0.02731
#> 2      zn -0.00016250  0.006865947          zn=0
#> 3   indus -0.27755494  0.492201863    indus=7.07
#> 4    chas -0.01886100  0.016614559        chas=0
#> 5     nox  0.33932047  0.925398396     nox=0.469
#> 6      rm -1.19031582 13.544574195      rm=6.421
{% endhighlight %}

The `iml` package is available on [CRAN](https://cran.r-project.org/web/packages/iml/index.html) and on [Github](https://github.com/christophM/iml).
