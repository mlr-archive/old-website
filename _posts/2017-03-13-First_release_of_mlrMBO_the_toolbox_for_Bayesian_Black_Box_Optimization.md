---
layout: post
title: First release of mlrMBO - the toolbox for (Bayesian) Black-Box Optimization
author: jakob
---



We are happy to finally announce the first release of [**mlrMBO** on cran](https://cran.r-project.org/package=mlrMBO) after a quite long development time.
For the theoretical background and a nearly complete overview of mlrMBOs capabilities you can check our [paper on **mlrMBO** that we presubmitted to arxiv](https://arxiv.org/abs/1703.03373).

The key features of **mlrMBO** are:

* Global optimization of expensive Black-Box functions.
* Multi-Criteria Optimization.
* Parallelization through multi-point proposals.
* Support for optimization over categorical variables using random forests as a surrogate.

For examples covering different scenarios we have Vignettes that are also available as an [online documentation](https://mlr-org.github.io/mlrMBO/).
For **mlr** users **mlrMBO** is especially interesting for hyperparameter optimization.

<!--more-->

**mlrMBO** for **mlr** hyperparameter tuning was already used in [an earlier blog post](/How-to-win-a-drone-in-20-lines-of-R-code).
Nonetheless we want to provide a small toy example to demonstrate the work flow of **mlrMBO** in this post.

### Example

First, we define an objective function that we are going to minimize:


{% highlight r %}
set.seed(1)
library(mlrMBO)
fun = makeSingleObjectiveFunction(
  name = "SineMixture",
  fn = function(x) sin(x[1])*cos(x[2])/2 + 0.04 * sum(x^2),
  par.set = makeNumericParamSet(id = "x", len = 2, lower = -5, upper = 5)
)
{% endhighlight %}

To define the objective function we use `makeSingleObjectiveFunction` from the neat package [**smoof**](https://github.com/jakobbossek/smoof), which gives us the benefit amongst others to be able to directly visualize the function.
_If you happen to be in need of functions to optimize and benchmark your optimization algorithm I recommend you to have a look at the package!_


{% highlight r %}
library(plot3D)
plot3D(fun, contour = TRUE, lightning = TRUE)
{% endhighlight %}

![plot of chunk plotObjectiveFunction](/figures/2017-03-13-First_release_of_mlrMBO_the_toolbox_for_Bayesian_Black_Box_Optimization/plotObjectiveFunction-1.svg)

Let's start with the configuration of the optimization:


{% highlight r %}
# In this simple example we construct the control object with the defaults:
ctrl = makeMBOControl()
# For this numeric optimization we are going to use the Expected Improvement as infill criterion:
ctrl = setMBOControlInfill(ctrl, crit = crit.ei)
# We will allow for exactly 25 evaluations of the objective function:
ctrl = setMBOControlTermination(ctrl, max.evals = 25L)
{% endhighlight %}

The optimization has to so start with an initial design.
**mlrMBO** can automatically create one but here we are going to use a randomly sampled LHS design of our own:


{% highlight r %}
library(ggplot2)
des = generateDesign(n = 8L, par.set = getParamSet(fun), fun = lhs::randomLHS)
autoplot(fun, render.levels = TRUE) + geom_point(data = des)
{% endhighlight %}



{% highlight text %}
## Warning: Ignoring unknown aesthetics: fill
{% endhighlight %}

![plot of chunk design](/figures/2017-03-13-First_release_of_mlrMBO_the_toolbox_for_Bayesian_Black_Box_Optimization/design-1.svg)

The points demonstrate how the initial design already covers the search space but is missing the area of the global minimum.
Before we can start the Bayesian optimization we have to set the surrogate learner to *Kriging*.
Therefore we use an *mlr* regression learner.
In fact, with *mlrMBO* you can use any regression learner integrated in *mlr* as a surrogate allowing for many special optimization applications.


{% highlight r %}
sur.lrn = makeLearner("regr.km", predict.type = "se", config = list(show.learner.output = FALSE))
{% endhighlight %}

_Note:_ **mlrMBO** can automatically determine a good surrogate learner based on the search space defined for the objective function.
For a purely numeric domain it would have chosen *Kriging* as well with some slight modifications to make it a bit more stable against numerical problems that can occur during optimization.

Finally, we can start the optimization run:


{% highlight r %}
res = mbo(fun = fun, design = des, learner = sur.lrn, control = ctrl, show.info = TRUE)
{% endhighlight %}



{% highlight text %}
## Computing y column(s) for design. Not provided.
{% endhighlight %}



{% highlight text %}
## [mbo] 0: x=-0.0101,-4.52 : y = 0.817 : 0.0 secs : initdesign
{% endhighlight %}



{% highlight text %}
## [mbo] 0: x=-4.52,-2.48 : y = 0.677 : 0.0 secs : initdesign
{% endhighlight %}



{% highlight text %}
## [mbo] 0: x=-2.78,-3.27 : y = 0.913 : 0.0 secs : initdesign
{% endhighlight %}



{% highlight text %}
## [mbo] 0: x=4.92,1.09 : y = 0.787 : 0.0 secs : initdesign
{% endhighlight %}



{% highlight text %}
## [mbo] 0: x=2.77,2.93 : y = 0.469 : 0.0 secs : initdesign
{% endhighlight %}



{% highlight text %}
## [mbo] 0: x=0.815,-0.647 : y = 0.333 : 0.0 secs : initdesign
{% endhighlight %}



{% highlight text %}
## [mbo] 0: x=-2.34,4.5 : y = 1.11 : 0.0 secs : initdesign
{% endhighlight %}



{% highlight text %}
## [mbo] 0: x=1.58,1.87 : y = 0.0939 : 0.0 secs : initdesign
{% endhighlight %}



{% highlight text %}
## [mbo] 1: x=1.48,5 : y = 1.23 : 0.0 secs : infill_ei
{% endhighlight %}



{% highlight text %}
## [mbo] 2: x=-3.77,2.2 : y = 0.589 : 0.0 secs : infill_ei
{% endhighlight %}



{% highlight text %}
## [mbo] 3: x=0.429,1.49 : y = 0.113 : 0.0 secs : infill_ei
{% endhighlight %}



{% highlight text %}
## [mbo] 4: x=0.776,1.98 : y = 0.0413 : 0.0 secs : infill_ei
{% endhighlight %}



{% highlight text %}
## [mbo] 5: x=0.126,1.93 : y = 0.127 : 0.0 secs : infill_ei
{% endhighlight %}



{% highlight text %}
## [mbo] 6: x=1.01,2.15 : y = -0.00662 : 0.0 secs : infill_ei
{% endhighlight %}



{% highlight text %}
## [mbo] 7: x=0.963,2.36 : y = -0.0317 : 0.0 secs : infill_ei
{% endhighlight %}



{% highlight text %}
## [mbo] 8: x=0.922,0.539 : y = 0.388 : 0.0 secs : infill_ei
{% endhighlight %}



{% highlight text %}
## [mbo] 9: x=-2.7,-0.524 : y = 0.119 : 0.0 secs : infill_ei
{% endhighlight %}



{% highlight text %}
## [mbo] 10: x=-5,-0.253 : y = 1.47 : 0.0 secs : infill_ei
{% endhighlight %}



{% highlight text %}
## [mbo] 11: x=-1.46,-0.613 : y = -0.306 : 0.0 secs : infill_ei
{% endhighlight %}



{% highlight text %}
## [mbo] 12: x=-1.39,-1.1 : y = -0.098 : 0.0 secs : infill_ei
{% endhighlight %}



{% highlight text %}
## [mbo] 13: x=-1.29,-0.228 : y = -0.4 : 0.0 secs : infill_ei
{% endhighlight %}



{% highlight text %}
## [mbo] 14: x=-1.57,0.256 : y = -0.382 : 0.0 secs : infill_ei
{% endhighlight %}



{% highlight text %}
## [mbo] 15: x=-1.43,-0.0423 : y = -0.413 : 0.0 secs : infill_ei
{% endhighlight %}



{% highlight text %}
## [mbo] 16: x=-1.27,0.0745 : y = -0.412 : 0.0 secs : infill_ei
{% endhighlight %}



{% highlight text %}
## [mbo] 17: x=5,-3.84 : y = 1.96 : 0.0 secs : infill_ei
{% endhighlight %}



{% highlight r %}
res$x
{% endhighlight %}



{% highlight text %}
## $x
## [1] -1.42836803 -0.04234841
{% endhighlight %}



{% highlight r %}
res$y
{% endhighlight %}



{% highlight text %}
## [1] -0.4128122
{% endhighlight %}

We can see that we have found the global optimum of $y = -0.414964$ at $x = (-1.35265,0)$ quite sufficiently.
Let's have a look at the points mlrMBO evaluated.
Therefore we can use the `OptPath` which stores all information about all evaluations during the optimization run:


{% highlight r %}
opdf = as.data.frame(res$opt.path)
autoplot(fun, render.levels = TRUE, render.contours = FALSE) + geom_text(data = opdf, aes(label = dob))
{% endhighlight %}

![plot of chunk mboPoints](/figures/2017-03-13-First_release_of_mlrMBO_the_toolbox_for_Bayesian_Black_Box_Optimization/mboPoints-1.svg)

It is interesting to see, that for this run the algorithm first went to the local minimum on the top right in the 6th and 7th iteration but later, thanks to the explorative character of the _Expected Improvement_, found the real global minimum.

### Comparison

That is all good, but how do other optimization strategies perform?

#### Grid Search

Grid search is seldom a good idea.
But especially for hyperparameter tuning it is still used.
Probably because it kind of gives you the feeling that you know what is going on and have not left out any important area of the search space.
In reality the grid is usually so sparse that it leaves important areas untouched as you can see in this example:


{% highlight r %}
grid.des = generateGridDesign(par.set = getParamSet(fun), resolution = 5)
grid.des$y = apply(grid.des, 1, fun)
grid.des[which.min(grid.des$y),]
{% endhighlight %}



{% highlight text %}
##      x1 x2           y
## 12 -2.5  0 -0.04923607
{% endhighlight %}



{% highlight r %}
autoplot(fun, render.levels = TRUE, render.contours = FALSE) + geom_point(data = grid.des)
{% endhighlight %}

![plot of chunk gridSeach](/figures/2017-03-13-First_release_of_mlrMBO_the_toolbox_for_Bayesian_Black_Box_Optimization/gridSeach-1.svg)

It is no surprise, that the grid search could not cover the search space well enough and we only reach a bad result.

#### What about a simple random search?


{% highlight r %}
random.des = generateRandomDesign(par.set = getParamSet(fun), n = 25L)
random.des$y = apply(random.des, 1, fun)
random.des[which.min(random.des$y),]
{% endhighlight %}



{% highlight text %}
##           x1         x2          y
## 20 -1.784371 -0.9802194 -0.1063019
{% endhighlight %}



{% highlight r %}
autoplot(fun, render.levels = TRUE, render.contours = FALSE) + geom_point(data = random.des)
{% endhighlight %}

![plot of chunk randomSearch](/figures/2017-03-13-First_release_of_mlrMBO_the_toolbox_for_Bayesian_Black_Box_Optimization/randomSearch-1.svg)

With the random search you could always be lucky but in average the optimum is not reached if smarter optimization strategies work well.

#### A fair comarison

... for stochastic optimization algorithms can only be achieved by repeating the runs.
**mlrMBO** is stochastic as the initial design is generated randomly and the fit of the Kriging surrogate is also not deterministic.
Furthermore we should include other optimization strategies like a genetic algorithm and direct competitors like `rBayesOpt`.
An extensive benchmark is available in [our **mlrMBO** paper](https://arxiv.org/abs/1703.03373).
The examples here are just meant to demonstrate the package.

### Engage

If you want to contribute to [**mlrMBO**](https://github.com/mlr-org/mlrMBO) we ware always open to suggestions and pull requests on github.
You are also invited to fork the repository and build and extend your own optimizer based on our toolbox.




