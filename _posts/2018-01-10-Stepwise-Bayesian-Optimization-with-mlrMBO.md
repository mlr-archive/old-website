---
layout: post
title: Stepwise Bayesian Optimization with mlrMBO
author: jakob
draft: false
---
  


With the release of the new version of [mlrMBO](https://mlr-org.github.io/mlrMBO/) we added some minor fixes and added a practical feature called *[Human-in-the-loop MBO](https://mlr-org.github.io/mlrMBO/articles/supplementary/human_in_the_loop_MBO.html)*.
It enables you to sequentially

* visualize the state of the surrogate model,
* obtain the suggested parameter configuration for the next iteration and
* update the surrogate model with arbitrary evaluations.

In the following we will demonstrate this feature on a simple example.
<!--more-->

First we need an objective function we want to optimize.
For this post a simple function will suffice but note that this function could also be an external process as in this mode **mlrMBO** does not need to access the objective function as you will only have to pass the results of the function to **mlrMBO**.

{% highlight r %}
library(mlrMBO)
library(ggplot2)
set.seed(1)

fun = function(x) {
  x^2 + sin(2 * pi * x) * cos(0.3 * pi * x)
}
{% endhighlight %}

However we still need to define the our search space.
In this case we look for a real valued value between -3 and 3.
For more hints about how to define ParamSets you can look [here](http://jakob-r.de/mlrHyperopt/articles/working_with_parconfigs_and_paramsets.html#the-basics-of-a-paramset) or in the [help of ParamHelpers](https://rdrr.io/cran/ParamHelpers/man/makeParamSet.html).

{% highlight r %}
ps = makeParamSet(
  makeNumericParam("x", lower = -3, upper = 3)
)
{% endhighlight %}

We also need some initial evaluations to start the optimization.
The design has to be passed as a `data.frame` with one column for each dimension of the search space and one column `y` for the outcomes of the objective function.

{% highlight r %}
des = generateDesign(n = 3, par.set = ps)
des$y = apply(des, 1, fun)
des
{% endhighlight %}



{% highlight text %}
##            x         y
## 1 -1.1835844 0.9988801
## 2 -0.5966361 0.8386779
## 3  2.7967794 8.6592973
{% endhighlight %}

With these values we can initialize our sequential MBO object.

{% highlight r %}
ctrl = makeMBOControl()
ctrl = setMBOControlInfill(ctrl, crit = crit.ei)
opt.state = initSMBO(
  par.set = ps, 
  design = des, 
  control = ctrl, 
  minimize = TRUE, 
  noisy = FALSE)
{% endhighlight %}

The `opt.state` now contains all necessary information for the optimization.
We can even plot it to see how the Gaussian process models the objective function.

{% highlight r %}
plot(opt.state)
{% endhighlight %}

![plot of chunk optstate1](/figures/2018-01-10-Stepwise-Bayesian-Optimization-with-mlrMBO/optstate1-1.svg)

In the first panel the *expected improvement* ($EI = E(y_{min}-\hat{y})$) (see [Jones et.al.](http://www.ressources-actuarielles.net/EXT/ISFA/1226.nsf/0/f84f7ac703bf5862c12576d8002f5259/$FILE/Jones98.pdf)) is plotted over the search space.
The maximum of the *EI* indicates the point that we should evaluate next.
The second panel shows the mean prediction of the surrogate model, which is the Gaussian regression model aka *Kriging* in this example.
The third panel shows the uncertainty prediction of the surrogate.
We can see, that the *EI* is high at points, where the mean prediction is low and/or the uncertainty is high.

To obtain the specific configuration suggested by mlrMBO for the next evaluation of the objective we can run:

{% highlight r %}
prop = proposePoints(opt.state)
prop
{% endhighlight %}



{% highlight text %}
## $prop.points
##             x
## 969 -2.999979
## 
## $propose.time
## [1] 0.273
## 
## $prop.type
## [1] "infill_ei"
## 
## $crit.vals
##            [,1]
## [1,] -0.3733677
## 
## $crit.components
##       se     mean
## 1 2.8899 3.031364
## 
## $errors.model
## [1] NA
## 
## attr(,"class")
## [1] "Proposal" "list"
{% endhighlight %}

We will execute our objective function with the suggested value for `x` and feed it back to mlrMBO:

{% highlight r %}
y = fun(prop$prop.points$x)
y
{% endhighlight %}



{% highlight text %}
## [1] 8.999752
{% endhighlight %}



{% highlight r %}
updateSMBO(opt.state, x = prop$prop.points, y = y)
{% endhighlight %}

The nice thing about the *human-in-the-loop* mode is, that you don't have to stick to the suggestion.
In other words we can feed the model with values without receiving a proposal.
Let's assume we have an expert who tells us to evaluate the values $x=-1$ and $x=1$ we can easily do so:

{% highlight r %}
custom.prop = data.frame(x = c(-1,1))
ys = apply(custom.prop, 1, fun)
updateSMBO(opt.state, x = custom.prop, y = as.list(ys))
plot(opt.state, scale.panels = TRUE)
{% endhighlight %}

![plot of chunk feedmanual](/figures/2018-01-10-Stepwise-Bayesian-Optimization-with-mlrMBO/feedmanual-1.svg)

We can also automate the process easily:

{% highlight r %}
replicate(3, {
  prop = proposePoints(opt.state)
  y = fun(prop$prop.points$x)
  updateSMBO(opt.state, x = prop$prop.points, y = y)
})
{% endhighlight %}
*Note:* We suggest to use the normal mlrMBO if you are only doing this as mlrMBO has more advanced logging, termination and handling of errors etc.

Let's see how the surrogate models the true objective function after having seen seven configurations:

{% highlight r %}
plot(opt.state, scale.panels = TRUE)
{% endhighlight %}

![plot of chunk optstate2](/figures/2018-01-10-Stepwise-Bayesian-Optimization-with-mlrMBO/optstate2-1.svg)

You can convert the `opt.state` object from this run to a normal mlrMBO result object like this:

{% highlight r %}
res = finalizeSMBO(opt.state)
res
{% endhighlight %}



{% highlight text %}
## Recommended parameters:
## x=-0.22
## Objective: y = -0.913
## 
## Optimization path
## 3 + 6 entries in total, displaying last 10 (or less):
##            x          y dob eol error.message exec.time         ei
## 1 -1.1835844  0.9988801   0  NA          <NA>        NA         NA
## 2 -0.5966361  0.8386779   0  NA          <NA>        NA         NA
## 3  2.7967794  8.6592973   0  NA          <NA>        NA         NA
## 4 -2.9999793  8.9997519   4  NA          <NA>        NA -0.3733677
## 5 -1.0000000  1.0000000   5  NA          <NA>        NA -0.3136111
## 6  1.0000000  1.0000000   6  NA          <NA>        NA -0.1366630
## 7  0.3010828  1.0016337   7  NA          <NA>        NA -0.7750916
## 8 -0.2197165 -0.9126980   8  NA          <NA>        NA -0.1569065
## 9 -0.1090728 -0.6176863   9  NA          <NA>        NA -0.1064289
##   error.model train.time  prop.type propose.time        se       mean
## 1        <NA>         NA initdesign           NA        NA         NA
## 2        <NA>         NA initdesign           NA        NA         NA
## 3        <NA>         NA initdesign           NA        NA         NA
## 4        <NA>          0     manual           NA 2.8899005  3.0313640
## 5        <NA>          0     manual           NA 0.5709559  0.6836938
## 6        <NA>         NA       <NA>           NA 3.3577897  5.3791930
## 7        <NA>          0     manual           NA 1.2337881  0.3493416
## 8        <NA>          0     manual           NA 0.4513106  0.8870228
## 9        <NA>          0     manual           NA 0.3621550 -0.8288961
{% endhighlight %}
*Note:* You can always run the *human-in-the-loop MBO* on `res$final.opt.state`.

For the curious, let's see how our original function actually looks like and which points we evaluated during our optimization:

{% highlight r %}
plot(fun, -3, 3)
points(x = getOptPathX(res$opt.path)$x, y = getOptPathY(res$opt.path))
{% endhighlight %}

![plot of chunk plottrue](/figures/2018-01-10-Stepwise-Bayesian-Optimization-with-mlrMBO/plottrue-1.svg)

We can see, that we got pretty close to the global optimum and that the surrogate in the previous plot models the objective quite accurate.

For more in-depth information look at the [Vignette for Human-in-the-loop MBO](https://mlr-org.github.io/mlrMBO/articles/supplementary/human_in_the_loop_MBO.html) and check out the other topics of our [mlrMBO page](https://mlr-org.github.io/mlrMBO).






