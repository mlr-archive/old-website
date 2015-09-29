---
title: "A deeper insight into random forest regression"
author: jakob
layout: post
draft: true
---

This time we want to explore how the uncertainty estimation of random forests behaves under different settings.

<!--more-->

Create the learner:

{% highlight r %}
library(mlr)
rf.learner = makeLearner("regr.randomForest", predict.type = "se", keep.inbag = TRUE)
{% endhighlight %}

In our toy example we cut some data to see how the interpolation and the uncertainty behaves in that gaps.

{% highlight r %}
set.seed(123)
f = function(x) sin(x)*x
n = 50
x = runif(n, 0, 13)
y = f(x) + rnorm(n, sd = 0.5)
x = x[y>-3]; y = y[y>-3]
plot(y~x)
x.r = seq(min(x),max(x),length.out = 100)
lines(x.r, f(x.r))
{% endhighlight %}

![plot of chunk the example](../figures/2015-09-29-A-deeper-insight-into-random-forest-regression/the example-1.svg) 

{% highlight r %}
toy.task = makeRegrTask(id = "toy", data = data.frame(x,y), target = "y")
{% endhighlight %}

With a little help of the *ParamHelpers* Package we can easily generate an exhaustive set of different settings:

{% highlight r %}
ps = makeParamSet(
  makeDiscreteParam("se.method", values = c("bootstrap", "jackknife", "noisy.bootstrap")),
  makeDiscreteParam("nr.of.bootstrap.samples", values = c(10,100)),
  makeDiscreteParam("ntree", values = c(500, 1000)),
  makeDiscreteParam("ntree.for.se", values = c(50, 500), requires = quote(se.method == "noisy.bootstrap"))
  )
design = generateGridDesign(par.set = ps, resolution = 1, trafo = TRUE) 
design = design[is.na(design$ntree.for.se) | as.integer(as.character((design$ntree.for.se))) < as.integer(as.character((design$ntree))),]
para.settings = dfRowsToList(design, par.set = ps)
{% endhighlight %}
Now we can iterate over all different parameter settings and see how it turns out.

{% highlight r %}
for(par.setting in para.settings) {
  lrn = setHyperPars(rf.learner, par.vals = removeMissingValues(par.setting))
  print(plotLearnerPrediction(lrn, toy.task, cv = 0))
}
{% endhighlight %}

![plot of chunk the plots](../figures/2015-09-29-A-deeper-insight-into-random-forest-regression/the plots-1.svg) ![plot of chunk the plots](../figures/2015-09-29-A-deeper-insight-into-random-forest-regression/the plots-2.svg) ![plot of chunk the plots](../figures/2015-09-29-A-deeper-insight-into-random-forest-regression/the plots-3.svg) ![plot of chunk the plots](../figures/2015-09-29-A-deeper-insight-into-random-forest-regression/the plots-4.svg) ![plot of chunk the plots](../figures/2015-09-29-A-deeper-insight-into-random-forest-regression/the plots-5.svg) ![plot of chunk the plots](../figures/2015-09-29-A-deeper-insight-into-random-forest-regression/the plots-6.svg) ![plot of chunk the plots](../figures/2015-09-29-A-deeper-insight-into-random-forest-regression/the plots-7.svg) ![plot of chunk the plots](../figures/2015-09-29-A-deeper-insight-into-random-forest-regression/the plots-8.svg) ![plot of chunk the plots](../figures/2015-09-29-A-deeper-insight-into-random-forest-regression/the plots-9.svg) ![plot of chunk the plots](../figures/2015-09-29-A-deeper-insight-into-random-forest-regression/the plots-10.svg) ![plot of chunk the plots](../figures/2015-09-29-A-deeper-insight-into-random-forest-regression/the plots-11.svg) ![plot of chunk the plots](../figures/2015-09-29-A-deeper-insight-into-random-forest-regression/the plots-12.svg) ![plot of chunk the plots](../figures/2015-09-29-A-deeper-insight-into-random-forest-regression/the plots-13.svg) ![plot of chunk the plots](../figures/2015-09-29-A-deeper-insight-into-random-forest-regression/the plots-14.svg) 
That all doesn't look so reliable to me.
