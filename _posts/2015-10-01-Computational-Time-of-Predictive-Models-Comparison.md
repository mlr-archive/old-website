---
title: "Computational Time of Predictive Models - A comparison of mlr and caret"
author: "jakob"
layout: post
draft: true
---
In [a recent blogpost](http://freakonometrics.hypotheses.org/20345) Arthur from freakonometrics had a closer look into the computational times of different classification methods.
Interestingly he found out that that *caret* was way slower than calling the method directly in *R*.
It was pointed out in the comments that caret automatically does some kind of resampling and tuning and this makes it obviously slower.
So we have to keep in mind that for *caret* `train` always means parameter tuning as well - although it is not always clear which parameters and regions are taken into account.
For our comparison we will keep it fair and torn it off but still we got curious if *mlr* generates an computational overhead.

<!--more-->

Let's prepare the big data set accordingly to the original posts in freakonometrics. 

{% highlight r %}
myocarde = read.table("http://freakonometrics.free.fr/myocarde.csv", head=TRUE, sep=";")
levels(myocarde$PRONO) = c("Death","Survival")
idx = rep(1:nrow(myocarde), each=100*100)
TPS = matrix(NA,30,10)
myocarde_large_2 = myocarde[idx,]
k = 23
M = data.frame(matrix(rnorm(k*nrow(myocarde_large_2)), nrow(myocarde_large_2), k))
names(M) = paste("X", 1:k, sep="")
myocarde_large_2 = cbind(myocarde_large_2,M)
dim(myocarde_large_2)
{% endhighlight %}



{% highlight text %}
## [1] 710000     31
{% endhighlight %}

Now we run the simple glm fit.
For fairness we always set the model parameter to FALSE so that the model frame is not included redundantly.

{% highlight r %}
system.time({
  fit = glm(PRONO~., data=myocarde_large_2, family="binomial", model = FALSE)
  })
{% endhighlight %}



{% highlight text %}
##    user  system elapsed 
##  16.596   0.848  17.431
{% endhighlight %}



{% highlight r %}
print(object.size(fit), units = "Mb")
{% endhighlight %}



{% highlight text %}
## 671.9 Mb
{% endhighlight %}

For *caret* we turn off any special training method to get as close as possible to what the original `glm` does.

{% highlight r %}
library(caret)
system.time({
  caret.fit = train(PRONO~., 
                    data = myocarde_large_2, 
                    method="glm", 
                    model = FALSE,
                    trControl = trainControl(method = "none"))
  })
{% endhighlight %}



{% highlight text %}
##    user  system elapsed 
##  65.988   1.092  67.032
{% endhighlight %}



{% highlight r %}
print(object.size(caret.fit), units = "Mb")
{% endhighlight %}



{% highlight text %}
## 877.9 Mb
{% endhighlight %}
Strangely *caret* still is a fair amount slower.
It's not clear to us what happens here but one reason might also be that the `caret.fit` object contains also the complete training data.

Finally we let *mlr* compute the model. 

{% highlight r %}
library(mlr)
lrn = makeLearner("classif.binomial")
tsk = makeClassifTask(id = "myocarde", data = myocarde_large_2, target = "PRONO")
system.time({
  mlr.fit = train(learner = lrn, task = tsk)  
  })
{% endhighlight %}



{% highlight text %}
##    user  system elapsed 
##  14.824   0.832  15.644
{% endhighlight %}



{% highlight r %}
print(object.size(mlr.fit), units = "Mb")
{% endhighlight %}



{% highlight text %}
## 674.6 Mb
{% endhighlight %}
Note that we automatically store the time if you are interested and notice too late.

{% highlight r %}
mlr.fit$time
{% endhighlight %}



{% highlight text %}
## [1] 15.641
{% endhighlight %}
We are happy that *mlr* doesn't bring you too much computational overhead.

But did we get the same model everywhere?

{% highlight r %}
all.equal(caret.fit$finalModel$coefficients, fit$coefficients)
{% endhighlight %}



{% highlight text %}
## [1] TRUE
{% endhighlight %}



{% highlight r %}
all.equal(mlr.fit$learner.model$coefficients, fit$coefficients)
{% endhighlight %}



{% highlight text %}
## [1] TRUE
{% endhighlight %}

So even though we turned off the automatic tuning in *caret* it is still significantly slower with around a minute compared to 15 seconds in *mlr*. 
What did we do wrong?
