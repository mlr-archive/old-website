---
layout: post
title: Parameter tuning with mlrHyperopt
author: jakob
---



Hyperparameter tuning with [**mlr**](https://github.com/mlr-org/mlr#-machine-learning-in-r) is rich in options as they are multiple tuning methods:

* Simple Random Search
* Grid Search
* Iterated F-Racing (via [**irace**](http://iridia.ulb.ac.be/irace/))
* Sequential Model-Based Optimization (via [**mlrMBO**](https://mlr-org.github.io/mlrMBO/))

Also the search space is easily definable and customizable for each of the [60+ learners of mlr](https://mlr-org.github.io/mlr/devel/html/integrated_learners/index.html) using the ParamSets from the [**ParamHelpers**](https://github.com/berndbischl/ParamHelpers) Package.

The only drawback and shortcoming of **mlr** in comparison to [**caret**](http://topepo.github.io/caret/index.html) in this regard is that **mlr** itself does not have defaults for the search spaces.
This is where [**mlrHyperopt**](http://jakob-r.de/mlrHyperopt/) comes into play.

<!--more-->

**mlrHyperopt** offers

* default search spaces for the most important learners in **mlr**,
* parameter tuning in one line of code,
* and an API to add and access custom search spaces from the [mlrHyperopt Database](http://mlrhyperopt.jakob-r.de/parconfigs).

### Installation


{% highlight r %}
devtools::install_github("berndbischl/ParamHelpers") # version >= 1.11 needed.
devtools::install_github("jakob-r/mlrHyperopt", dependencies = TRUE)
{% endhighlight %}

### Tuning in one line

Tuning can be done in one line relying on the defaults.
The default will automatically minimize the _missclassification rate_.


{% highlight r %}
library(mlrHyperopt)
res = hyperopt(iris.task, learner = "classif.svm")
res
{% endhighlight %}



{% highlight text %}
## Tune result:
## Op. pars: cost=1.44e+03; gamma=0.00167
## mmce.test.mean=0.0333333
{% endhighlight %}

We can find out what `hyperopt` did by inspecting the `res` object.

Depending on the parameter space **mlrHyperopt** will automatically decide for a suitable tuning method:


{% highlight r %}
res$opt.path$par.set
{% endhighlight %}



{% highlight text %}
##          Type len Def    Constr Req Tunable Trafo
## cost  numeric   -   0 -15 to 15   -    TRUE     Y
## gamma numeric   -  -2 -15 to 15   -    TRUE     Y
{% endhighlight %}



{% highlight r %}
res$control
{% endhighlight %}



{% highlight text %}
## Tune control: TuneControlMBO
## Same resampling instance: TRUE
## Imputation value: 1
## Start: <NULL>
## 
## Tune threshold: FALSE
## Further arguments:
{% endhighlight %}

As the search space defined in the ParamSet is only numeric, sequential Bayesian optimization was chosen.
We can look into the evaluated parameter configurations and we can visualize the optimization run.


{% highlight r %}
tail(as.data.frame(res$opt.path))
{% endhighlight %}



{% highlight text %}
##         cost      gamma mmce.test.mean dob eol error.message
## 20 10.491840  -9.222250     0.03333333  20  NA          <NA>
## 21 14.998822 -12.916888     0.04000000  21  NA          <NA>
## 22  7.121047  -4.548062     0.04000000  22  NA          <NA>
## 23  8.877556  -7.047145     0.03333333  23  NA          <NA>
## 24 14.998896  -6.779985     0.04000000  24  NA          <NA>
## 25 11.641461 -12.157508     0.04000000  25  NA          <NA>
##    exec.time
## 20     0.083
## 21     0.083
## 22     0.080
## 23     0.091
## 24     0.088
## 25     0.077
{% endhighlight %}



{% highlight r %}
plotOptPath(res$opt.path)
{% endhighlight %}

![plot of chunk resObjectOptPath](/figures/2017-07-19-Parameter-tuning-with-mlrHyperopt/resObjectOptPath-1.svg)

The upper left plot shows the distribution of the tried settings in the search space and contour lines indicate where regions of good configurations are located.
The lower right plot shows the value of the objective (the miss-classification rate) and how it decreases over the time. 
This also shows nicely that wrong settings can lead to bad results.

### Using the mlrHyperopt API with mlr

If you just want to use **mlrHyperopt** to access the default parameter search spaces from the 
Often you don't want to rely on the default procedures of **mlrHyperopt** and just incorporate it into your **mlr**-workflow.
Here is one example how you can use the default search spaces for an easy benchmark:



{% highlight r %}
lrns = c("classif.xgboost", "classif.nnet")
lrns = makeLearners(lrns)
tsk = pid.task
rr = makeResampleDesc('CV', stratify = TRUE, iters = 10)
lrns.tuned = lapply(lrns, function(lrn) {
  if (getLearnerName(lrn) == "xgboost") {
    # for xgboost we download a custom ParConfig from the Database
    pcs = downloadParConfigs(learner.name = getLearnerName(lrn))
    pc = pcs[[1]]
  } else {
    pc = getDefaultParConfig(learner = lrn)
  }
  ps = getParConfigParSet(pc)
  # some parameters are dependend on the data (eg. the number of columns)
  ps = evaluateParamExpressions(ps, dict = mlrHyperopt::getTaskDictionary(task = tsk))
  lrn = setHyperPars(lrn, par.vals = getParConfigParVals(pc))
  ctrl = makeTuneControlRandom(maxit = 20)
  makeTuneWrapper(learner = lrn, resampling = rr, par.set = ps, control = ctrl)
})
res = benchmark(learners = c(lrns, lrns.tuned), tasks = tsk, resamplings = cv10)
plotBMRBoxplots(res) 
{% endhighlight %}

![plot of chunk benchmark](/figures/2017-07-19-Parameter-tuning-with-mlrHyperopt/benchmark-1.svg)

As we can see we were able to improve the performance of xgboost and the nnet without any additional knowledge on what parameters we should tune.
Especially for nnet improved performance is noticable.

### Additional Information

Some recommended additional reads

* [Vignette](http://jakob-r.de/mlrHyperopt/articles/mlrHyperopt.html) on getting started and also how to contribute by uploading alternative or additional ParConfigs.
* [How to work with ParamSets](http://jakob-r.de/mlrHyperopt/articles/working_with_parconfigs_and_paramsets.html#the-basics-of-a-paramset) as part of the [Vignette](http://jakob-r.de/mlrHyperopt/articles/working_with_parconfigs_and_paramsets.html).
* The [slides of the useR 2017 Talk](https://github.com/jakob-r/mlrHyperopt/raw/master/meta/useR2017/beamer/jakob_richter_mlrHyperopt.pdf) on **mlrHyperopt**.
