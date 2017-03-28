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
First, let me introduce you to multilabel classification. This is a classification problem, where every instance can have more than one label. Let's have a look at a typical multilabel dataset (which I, of course, download from the [OpenML server](https://www.openml.org/search?q=2016_multilabel_r_benchmark_paper)):


{% highlight r %}
library(mlr)
library(OpenML)
setOMLConfig(apikey = "c1994bdb7ecb3c6f3c8f3b35f4b47f1f") #read only api key
oml.id = listOMLDataSets(tag = "2016_multilabel_r_benchmark_paper")$data.id
scene = getOMLDataSet(data.id = oml.id[8])
target = scene$target.features
feats = setdiff(colnames(scene$data), target)
{% endhighlight %}


{% highlight r %}
head(scene$data[, c(feats[1], feats[2], target)])
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

Here I took the [*scene*](http://www.sciencedirect.com/science/article/pii/S0031320304001074) dataset, where the features represent color information of pictures and the targets could be objects like *beach*, *sunset*, and so on.


As you can see above, one defining property of a multilabel dataset is, that the target variables (which are called *labels*) are binary. If you want to use your own data set, make sure to encode these variables in *logical*, where *TRUE* indicates the relevance of a label.

The basic idea behind many multilabel classification algorithms is to make use of possible correlation between labels. Maybe a learner is very good at predicting label 1, but rather bad at predicting label 2. If label 1 and label 2 are highly correlated, it may be beneficial to predict label 1 first and use this prediction as a feature for predicting label 2.

This approach is the main concept behind the so called *problem transformation methods*. The multilabel problem is transformed into binary classification problems, one for each label. Predicted labels are used as features for predicting other labels.

We implemented the following problem transformation methods:

* Classifier chains 
* Nested stacking
* Dependent binary relevance 
* Stacking

How these methods are defined, can be read in the [mlr tutorial](http://mlr-org.github.io/mlr-tutorial/release/html/multilabel/index.html) or in more detail in our [paper](https://arxiv.org/pdf/1703.08991.pdf). Enough theory now, let's apply these methods on our dataset.

### 2) Let's Train and Predict!
First we need to create a multilabel task.

{% highlight r %}
set.seed(1729)
target
{% endhighlight %}



{% highlight text %}
## [1] "Beach"       "Sunset"      "FallFoliage" "Field"      
## [5] "Mountain"    "Urban"
{% endhighlight %}



{% highlight r %}
scene.task = makeMultilabelTask(data = scene$data, target = target)
{% endhighlight %}
We set a seed, because the classifier chain wrapper uses a random chain order.
Next, we train a learner. I chose the classifier chain approach together with a decision tree for the binary classification problems. 

{% highlight r %}
binary.learner = makeLearner("classif.rpart")
lrncc = makeMultilabelClassifierChainsWrapper(binary.learner)
{% endhighlight %}

Now let's train and predict on our dataset:

{% highlight r %}
n = getTaskSize(scene.task)
train.set = seq(1, n, by = 2)
test.set = seq(2, n, by = 2)

scene.mod.cc = train(lrncc, scene.task, subset = train.set)
scene.pred.cc = predict(scene.mod.cc, task = scene.task, subset = test.set)
{% endhighlight %}

We also implemented common multilabel performance measures. Here is a list with [available multilabel performance measures](http://mlr-org.github.io/mlr-tutorial/devel/html/measures/index.html#multilabel-classification):

{% highlight r %}
listMeasures("multilabel")
{% endhighlight %}



{% highlight text %}
##  [1] "multilabel.f1"       "multilabel.subset01" "multilabel.tpr"     
##  [4] "multilabel.ppv"      "multilabel.acc"      "timeboth"           
##  [7] "timepredict"         "multilabel.hamloss"  "featperc"           
## [10] "timetrain"
{% endhighlight %}

Here is how the classifier chains method performed:

{% highlight r %}
performance(scene.pred.cc, measures = list(multilabel.hamloss, multilabel.subset01, multilabel.f1, multilabel.acc))
{% endhighlight %}



{% highlight text %}
##  multilabel.hamloss multilabel.subset01       multilabel.f1 
##           0.1298144           0.5162095           0.5581602 
##      multilabel.acc 
##           0.5392075
{% endhighlight %}

<!-- Maybe you are interested in binary performance values: -->
<!-- ```{r} -->
<!-- getMultilabelBinaryPerformances(scene.pred.cc, measures = list(acc, tpr, tnr)) -->
<!-- ``` -->

### 3) Comparison Binary Relevance vs. Classifier Chains
Now let's see if it can be beneficial to use predicted labels as features for other labels. Let us compare the performance of the classifier chains method with the binary relevance method (this method does not use predicted labels as features).

{% highlight r %}
lrnbr = makeMultilabelBinaryRelevanceWrapper(binary.learner)

scene.mod.br = train(lrnbr, scene.task, subset = train.set)
scene.pred.br = predict(scene.mod.br, task = scene.task, subset = test.set)

performance(scene.pred.br, measures = list(multilabel.hamloss, multilabel.subset01, multilabel.f1, multilabel.acc))
{% endhighlight %}



{% highlight text %}
##  multilabel.hamloss multilabel.subset01       multilabel.f1 
##           0.1305071           0.5719036           0.5357163 
##      multilabel.acc 
##           0.5083818
{% endhighlight %}
As can be seen here, it could indeed make sense to use more elaborate methods for multilabel classification, since classifier chains beat the binary relevance methods in all of these measures (Note, that hamming and subset01 are loss measures!).


### 4) Resampling
Here I'll show you how to use resampling methods in the multilabel setting. Resampling methods are key for assessing the performance of a learning algorithm. To read more about resampling, see the page on our [tutorial](http://mlr-org.github.io/mlr-tutorial/devel/html/resample/index.html).

First, we need define a resampling strategy. I chose subsampling, which is also called Monte-Carlo cross-validation. The dataset is split into training and test set at a predefined ratio. The learner is trained on the training set, the performance is evaluated with the test set. This whole process is repeated many times and the performance values are averaged. In mlr this is done the following way:


{% highlight r %}
rdesc = makeResampleDesc("Subsample", iters = 10, split = 2/3)
{% endhighlight %}

Now we can choose a measure, which shall be resampled. All there is left to do is to run the resampling:


{% highlight r %}
r = resample(lrncc, scene.task, rdesc, measures = multilabel.subset01)
{% endhighlight %}

{% highlight r %}
r
{% endhighlight %}



{% highlight text %}
## Resample Result
## Task: scene$data
## Learner: multilabel.classif.rpart
## Aggr perf: multilabel.subset01.test.mean=0.484
## Runtime: 20.3391
{% endhighlight %}

If you followed the mlr tutorial or if you are already familiar with mlr, you most likely saw, that using resampling in the multilabel setting isn't any different than generally using resampling in mlr.
Many methods, which are available in mlr, like [preprocessing](http://mlr-org.github.io/mlr-tutorial/devel/html/preproc/index.html), [tuning](http://mlr-org.github.io/mlr-tutorial/devel/html/tune/index.html) or [benchmark experiments](http://mlr-org.github.io/mlr-tutorial/devel/html/benchmark_experiments/index.html) can also be used for multilabel datasets and the good thing here is: the syntax stays the same!






