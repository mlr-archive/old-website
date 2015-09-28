---
title: "How do regression learners behave on a schoolbook example?"
author: jakob
date: "28. September 2015"
layout: post
---

Let's try out a little toy example to see how all the regression methods integrated in **mlr** behave on a schoolbook example.
Luckily this can be done with just a few lines of code - but let's narrow it done to those which support uncertainty estimation.

Let's generate a list with all mlr-learners fitting the criteria.

{% highlight r %}
#library(mlr)
devtools::load_all("~/gits/mlr/")
learners = listLearners("regr", properties = "se", create = TRUE)
{% endhighlight %}


Let's generate some easy data:

{% highlight r %}
set.seed(1)
n = 100
x = runif(n, min = 0, max = 10)
y = rnorm(n, mean = (x-2)^2, sd = seq(1, 3, length.out = n)^2)
toy.task = makeRegrTask(id = "toy", data = data.frame(x,y), target = "y")
{% endhighlight %}

Now we can already create all the graphs:

{% highlight r %}
for(lrn in learners) {
  print(plotLearnerPrediction(lrn, toy.task, gridsize = 5))
}
{% endhighlight %}

![plot of chunk regression visualization](../figures/2015-09-28-How-do-regression-learners-behave-on-a-schoolbook-exampleregression visualization-1.svg) ![plot of chunk regression visualization](../figures/2015-09-28-How-do-regression-learners-behave-on-a-schoolbook-exampleregression visualization-2.svg) ![plot of chunk regression visualization](../figures/2015-09-28-How-do-regression-learners-behave-on-a-schoolbook-exampleregression visualization-3.svg) ![plot of chunk regression visualization](../figures/2015-09-28-How-do-regression-learners-behave-on-a-schoolbook-exampleregression visualization-4.svg) ![plot of chunk regression visualization](../figures/2015-09-28-How-do-regression-learners-behave-on-a-schoolbook-exampleregression visualization-5.svg) ![plot of chunk regression visualization](../figures/2015-09-28-How-do-regression-learners-behave-on-a-schoolbook-exampleregression visualization-6.svg) ![plot of chunk regression visualization](../figures/2015-09-28-How-do-regression-learners-behave-on-a-schoolbook-exampleregression visualization-7.svg) 

{% highlight text %}
## Error in chol.default(R): der führende Minor der Ordnung 95 ist nicht positiv definit
{% endhighlight %}

![plot of chunk regression visualization](../figures/2015-09-28-How-do-regression-learners-behave-on-a-schoolbook-exampleregression visualization-8.svg) 

Hu? It looks like we shamelessly copied the code from the last blog-post.
How easy!
