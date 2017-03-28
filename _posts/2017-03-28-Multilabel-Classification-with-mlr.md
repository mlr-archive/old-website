---
layout: post
title: Multilabel Classification with mlr
author: quay
draft: true
---
Multilabel classification has lately gained growing interest in the research community. 
We implemented several methods, which make use of the standardized mlr framework. Every available binary learner can be used for multilabel problem transformation methods.
So if you're interested in using several multilabel algorithms and want to know how to use them in the mlr framework, then this post is for you!


<!--more-->
### 1) Introduction to multilabel classification
First, let me introduce you to multilabel classification. This is a classification problem, where every instance can have more than one label. Let's have a look at a typical multilabel dataset (which I, of course, download from the OpenML server, tag = *2016_multilabel_r_benchmark_paper*):


{% highlight r %}
library(OpenML)
setOMLConfig(apikey = "c1994bdb7ecb3c6f3c8f3b35f4b47f1f") #read only api key
library(mlr)
scene = getOMLDataSet(data.id = 40595)
{% endhighlight %}


{% highlight r %}
head(scene$data[, c(1, 2, 295, 296, 297, 298, 299, 300)])
{% endhighlight %}



{% highlight text %}
##       Att1     Att2 Beach Sunset FallFoliage Field Mountain Urban
## 0 0.646467 0.666435  TRUE  FALSE       FALSE FALSE     TRUE FALSE
## 1 0.770156 0.767255  TRUE  FALSE       FALSE FALSE    FALSE  TRUE
## 2 0.793984 0.772096  TRUE  FALSE       FALSE FALSE    FALSE FALSE
## 3 0.938563 0.949260  TRUE  FALSE       FALSE FALSE    FALSE FALSE
## 4 0.512130 0.524684  TRUE  FALSE       FALSE FALSE    FALSE FALSE
## 5 0.824623 0.886845  TRUE  FALSE       FALSE FALSE    FALSE FALSE
{% endhighlight %}

As you can see above, one defining property of a multilabel dataset is, that the target variables (which are called *labels*) are binary. If you want to use your own data set, make sure to encode these variables in *logical*, where *TRUE* indicates the relevance of a label.

The basic idea behind many multilabel classification algorithms is to make use of possible correlation between labels. Maybe a learner is very good at predicting label 1, but rather bad at predicting label 2. If label 1 and label 2 are highly correlated, it may be beneficial to predict label 1 first and use this prediction as a feature for predicting label 2.

This approach is the main concept behind the so called *problem transformation methods*. The multilabel problem is transformed into binary classification problems. One for each label. Predicted labels are used as features for predicting other labels.

We implemented the following problem transformation methods:

* Classifier chains 
* Nested stacking
* Dependent binary relevance 
* Stacking

How these methods are defined can be read in the [mlr tutorial](http://mlr-org.github.io/mlr-tutorial/release/html/multilabel/index.html) or in more detail in our [paper](https://arxiv.org/pdf/1703.08991.pdf). Enough theory now, let's apply these methods on our dataset.

### 2) Let's Train and Predict!
First we need to create a multilabel task.

{% highlight r %}
set.seed(1729)
scene.task = makeMultilabelTask(data = scene$data, target = scene$target.features)
{% endhighlight %}
We set a seed, because the classifier chain wrapper uses a random chain order.
Next, we train a learner. I chose the classifier chain approach together with a decision tree for the binary classification problems. 

{% highlight r %}
binary.learner = makeLearner("classif.rpart")
lrnCC = makeMultilabelClassifierChainsWrapper(binary.learner)
{% endhighlight %}

Now let's train and predict on our dataset:

{% highlight r %}
n = getTaskSize(scene.task)
train.set = seq(1, n, by = 2)
test.set = seq(2, n, by = 2)

scene.mod.CC = train(lrnCC, scene.task, subset = train.set)
scene.pred.CC = predict(scene.mod.CC, task = scene.task, subset = test.set)
{% endhighlight %}

We also implemented common multilabel performance measures:


{% highlight r %}
performance(scene.pred.CC, measures = list(multilabel.hamloss, multilabel.subset01, multilabel.f1, multilabel.acc))
{% endhighlight %}



{% highlight text %}
##  multilabel.hamloss multilabel.subset01       multilabel.f1 
##           0.1298144           0.5162095           0.5581602 
##      multilabel.acc 
##           0.5392075
{% endhighlight %}

<!-- Maybe you are interested in binary performance values: -->
<!-- ```{r} -->
<!-- getMultilabelBinaryPerformances(scene.pred.CC, measures = list(acc, tpr, tnr)) -->
<!-- ``` -->

### 3) Comparison Binary Relevance vs. Classifier Chains
Now let's see if it can be beneficial to use predicted labels as features for other labels. Let us compare the performance of the classifier chains method with the binary relevance method (this method does not use predicted labels as features).

{% highlight r %}
lrnBR = makeMultilabelBinaryRelevanceWrapper(binary.learner)

scene.mod.BR = train(lrnBR, scene.task, subset = train.set)
scene.pred.BR = predict(scene.mod.BR, task = scene.task, subset = test.set)

performance(scene.pred.BR, measures = list(multilabel.hamloss, multilabel.subset01, multilabel.f1, multilabel.acc))
{% endhighlight %}



{% highlight text %}
##  multilabel.hamloss multilabel.subset01       multilabel.f1 
##           0.1305071           0.5719036           0.5357163 
##      multilabel.acc 
##           0.5083818
{% endhighlight %}
As can be seen here, it could indeed make sense to use more elaborate methods for multilabel classification, since classifier chains beat the binary relevance methods in many of these measures (Note, that hamming and subset01 are loss measures!).
