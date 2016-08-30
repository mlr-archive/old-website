---
title: "A deeper insight into random forest regression"
author: jakob
layout: post
draft: true
---

Let's try out a little toy example to see how all the regression methods integrated in **mlr** behave on a schoolbook example.
Luckily this can be done with just a few lines of code - but let's narrow it done to those which support uncertainty estimation.
<!-- more -->
Let's generate a list with all mlr-learners fitting the criteria.

{% highlight r %}
library(mlr)
learners = listLearners("regr", properties = "se", create = TRUE)
{% endhighlight %}


Let's generate some easy data:

{% highlight r %}
set.seed(123)
n = 50
x = rchisq(n, df = 2, ncp = 3)
y = rnorm(n, mean = (x-2)^2, sd = seq(1, 3, length.out = n)^2)
y[1:5] = -20 # generate some measuring error
toy.task = makeRegrTask(id = "toy", data = data.frame(x,y), target = "y")
{% endhighlight %}

Now we can already create all the graphs:

{% highlight r %}
for(lrn in learners) {
  print(plotLearnerPrediction(lrn, toy.task, cv = 0))
}
{% endhighlight %}

![plot of chunk regression visualization](/figures/2015-09-28-How-do-regression-learners-behave-on-a-schoolbook-example/regression visualization-1.svg)![plot of chunk regression visualization](/figures/2015-09-28-How-do-regression-learners-behave-on-a-schoolbook-example/regression visualization-2.svg)![plot of chunk regression visualization](/figures/2015-09-28-How-do-regression-learners-behave-on-a-schoolbook-example/regression visualization-3.svg)![plot of chunk regression visualization](/figures/2015-09-28-How-do-regression-learners-behave-on-a-schoolbook-example/regression visualization-4.svg)![plot of chunk regression visualization](/figures/2015-09-28-How-do-regression-learners-behave-on-a-schoolbook-example/regression visualization-5.svg)![plot of chunk regression visualization](/figures/2015-09-28-How-do-regression-learners-behave-on-a-schoolbook-example/regression visualization-6.svg)![plot of chunk regression visualization](/figures/2015-09-28-How-do-regression-learners-behave-on-a-schoolbook-example/regression visualization-7.svg)![plot of chunk regression visualization](/figures/2015-09-28-How-do-regression-learners-behave-on-a-schoolbook-example/regression visualization-8.svg)![plot of chunk regression visualization](/figures/2015-09-28-How-do-regression-learners-behave-on-a-schoolbook-example/regression visualization-9.svg)

{% highlight text %}
## Error in apply(d$data[, not.const], 2, function(x) x = (x - min(x))/(max(x) - : dim(X) must have a positive length
{% endhighlight %}

![plot of chunk regression visualization](/figures/2015-09-28-How-do-regression-learners-behave-on-a-schoolbook-example/regression visualization-10.svg)

Hu? It looks like we shamelessly copied the code from the last blog-post.
How easy!
