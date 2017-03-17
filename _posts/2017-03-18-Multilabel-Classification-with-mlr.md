---
layout: post
title: Multilabel Classification with mlr
author: quay
draft: true
---
Multilabel classification has lately gained growing interest in the research community. 
We implemented several methods, which make use of the standardized mlr framework. So if you're interested in using several multilabel algorithms and want to know how to use them in the mlr framework, then this post is for you!


<!--more-->
### 1) Introduction into multilabel classification
First, let me introduce you into multilabel classification. Basically, multilabel classification is a classification problem, where every instance can have more than one label. Before diving too deep into definitions, let's have a look at a typical multilabel dataset (which I, of course, download from the OpenML server, tag = *2016_multilabel_r_benchmark_paper*):


{% highlight r %}
library(OpenML)
setOMLConfig(apikey = "c1994bdb7ecb3c6f3c8f3b35f4b47f1f") #read only api key
library(mlr)
scene = getOMLDataSet(data.id = 40595)
{% endhighlight %}


{% highlight r %}
head(scene$data[, c(1, 2, 3, 295, 296, 297, 298, 299, 300)])
{% endhighlight %}



{% highlight text %}
##       Att1     Att2     Att3 Beach Sunset FallFoliage Field Mountain
## 0 0.646467 0.666435 0.685047  TRUE  FALSE       FALSE FALSE     TRUE
## 1 0.770156 0.767255 0.761053  TRUE  FALSE       FALSE FALSE    FALSE
## 2 0.793984 0.772096 0.761820  TRUE  FALSE       FALSE FALSE    FALSE
## 3 0.938563 0.949260 0.955621  TRUE  FALSE       FALSE FALSE    FALSE
## 4 0.512130 0.524684 0.520020  TRUE  FALSE       FALSE FALSE    FALSE
## 5 0.824623 0.886845 0.933213  TRUE  FALSE       FALSE FALSE    FALSE
##   Urban
## 0 FALSE
## 1  TRUE
## 2 FALSE
## 3 FALSE
## 4 FALSE
## 5 FALSE
{% endhighlight %}

As you can see above, one defining property of a multilabel dataset is, that the target variables (which are called *labels*) are binary. If you want to use your own data set, make sure to encode the variables in *logical*, where *TRUE* indicates the relevance of a label.

The basic idea behind many multilabel classification algorithms is to make use of possible correlation between labels. Maybe a learner is very good at predicting the label *Beach*, but rather bad at predicting the label *Field*. Let's assume that beaches and fields typically don't appear together in one picture.
If we now can predict that there is a beach in a picture, we should use this information, that there unlikely is a field in that picture, too.

This approach is the main concept behind the so called *problem transformation methods*. The multilabel problem is transformed into binary classification problems. One for each label. Predicted labels are used as features for predicting other labels.

We implemented the following problem transformation methods:

* Classifier chains 
* Nested stacking
* Dependent binary relevance 
* Stacking

How these methods are defined can be read in the tutorial or in more detail in MULTILABEL PAPER. Enough theory now, let's apply these methods on our dataset.

### 2) Let's Train and Predict!
First we need to create a multilabel task.

{% highlight r %}
set.seed(1)
scene.task = makeMultilabelTask(data = scene$data, target = scene$target.features)
{% endhighlight %}
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

scene.mod = train(lrnCC, scene.task, subset = train.set)
scene.pred = predict(scene.mod, task = scene.task, subset = test.set)
{% endhighlight %}

We also implemented usual multilabel performance measures:


{% highlight r %}
performance(scene.pred, measures = list(multilabel.hamloss, multilabel.subset01, multilabel.f1))
{% endhighlight %}



{% highlight text %}
##  multilabel.hamloss multilabel.subset01       multilabel.f1 
##           0.1406207           0.4979219           0.5808257
{% endhighlight %}

Maybe you are interested in binary performance values:

{% highlight r %}
getMultilabelBinaryPerformances(scene.pred, measures = list(acc, tpr, tnr))
{% endhighlight %}



{% highlight text %}
##             acc.test.mean tpr.test.mean tnr.test.mean
## Beach           0.8669992     0.5070423     0.9444444
## Sunset          0.9218620     0.6994536     0.9617647
## FallFoliage     0.9002494     0.5909091     0.9611940
## Field           0.9085619     0.7260274     0.9491870
## Mountain        0.7506234     0.5531136     0.8086022
## Urban           0.8079800     0.4672897     0.8816987
{% endhighlight %}

<!-- ### 3) A Small Benchmark -->
<!-- Now let's see in a (really small) benchmark experiment, if it really is beneficial to use predicted labels as features for other labels. Let us compare the performance of the classifier chains method with the binary relevance method (the binary relevance method does not use predicted labels as features). -->
<!-- ```{r} -->
<!-- lrnBR = makeMultilabelBinaryRelevanceWrapper(binary.learner) -->
<!-- learners = list(CC = lrnCC, BR = lrnBR) -->
<!-- benchmark(learners, scene.task) -->
<!-- ``` -->

























