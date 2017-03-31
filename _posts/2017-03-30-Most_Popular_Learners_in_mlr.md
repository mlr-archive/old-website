---
layout: post
title: Most Popular Learners in mlr
author: jakob
draft: false
---



For the development of [mlr](https://github.com/mlr-org/mlr) as well as for an "machine learning expert" it can be handy to know what are the most popular learners used.
Not necessarily to see, what are the top notch performing methods but to see what is used "out there" in the real world. 
Thanks to the nice little package [cranlogs](https://github.com/metacran/cranlogs) from [metacran](https://www.r-pkg.org/) you can at least get a slight estimate as I will show in the following...

<!--more-->

First we need to install the `cranlogs` package using `devtools`:


{% highlight r %}
devtools::install_github("metacran/cranlogs")
{% endhighlight %}

Now let's load all the packages we will need:


{% highlight r %}
library(mlr)
library(stringi)
library(cranlogs)
library(data.table)
{% endhighlight %}

Do obtain a neat table of all available learners in _mlr_ we can call `listLearners()`.
This table also contains a column with the needed packages for each learner separated with a `,`.


{% highlight r %}
# obtain used packages for all learners
lrns = as.data.table(listLearners())
all.pkgs = stri_split(lrns$package, fixed = ",")
{% endhighlight %}

_Note:_ You might get some warnings here because you likely did not install all packages that _mlr_ suggests -- which is totally fine.

Now we can obtain the download counts from the _rstudio cran mirror_, i.e. from the last month.
We use `data.table` to easily sum up the download counts of each day.


{% highlight r %}
all.downloads = cran_downloads(packages = unique(unlist(all.pkgs)), when = "last-month")
all.downloads = as.data.table(all.downloads)
monthly.downloads = all.downloads[, list(monthly = sum(count)), by = package]
{% endhighlight %}

As some learners need multiple packages we will use the download count of the package with the least downloads.


{% highlight r %}
lrn.downloads = sapply(all.pkgs, function(pkgs) {
  monthly.downloads[package %in% pkgs, min(monthly)]
})
{% endhighlight %}

Let's put these numbers in our table:


{% highlight r %}
lrns$downloads = lrn.downloads
lrns = lrns[order(downloads, decreasing = TRUE),]
lrns[, .(class, name, package, downloads)]
{% endhighlight %}
_Here are the first 5 rows of the table:_

|class              |name                             |package  | downloads|
|:------------------|:--------------------------------|:--------|---------:|
|surv.coxph         |Cox Proportional Hazard Model    |survival |    153681|
|classif.naiveBayes |Naive Bayes                      |e1071    |    102249|
|classif.svm        |Support Vector Machines (libsvm) |e1071    |    102249|
|regr.svm           |Support Vector Machines (libsvm) |e1071    |    102249|
|classif.lda        |Linear Discriminant Analysis     |MASS     |     55852|

Now let's get rid of the duplicates introduced by the distinction of the type _classif_, _regr_ and we already have our...

## nearly final table


{% highlight r %}
lrns.small = lrns[, .SD[1,], by = .(name, package)]
lrns.small[, .(class, name, package, downloads)]
{% endhighlight %}

The top 20 according to the _rstudio cran mirror_:


|class                |name                                                                                                      |package          | downloads|
|:--------------------|:---------------------------------------------------------------------------------------------------------|:----------------|---------:|
|surv.coxph           |Cox Proportional Hazard Model                                                                             |survival         |    153681|
|classif.naiveBayes   |Naive Bayes                                                                                               |e1071            |    102249|
|classif.svm          |Support Vector Machines (libsvm)                                                                          |e1071            |    102249|
|classif.lda          |Linear Discriminant Analysis                                                                              |MASS             |     55852|
|classif.qda          |Quadratic Discriminant Analysis                                                                           |MASS             |     55852|
|classif.randomForest |Random Forest                                                                                             |randomForest     |     52094|
|classif.gausspr      |Gaussian Processes                                                                                        |kernlab          |     44812|
|classif.ksvm         |Support Vector Machines                                                                                   |kernlab          |     44812|
|classif.lssvm        |Least Squares Support Vector Machine                                                                      |kernlab          |     44812|
|cluster.kkmeans      |Kernel K-Means                                                                                            |kernlab          |     44812|
|regr.rvm             |Relevance Vector Machine                                                                                  |kernlab          |     44812|
|classif.cvglmnet     |GLM with Lasso or Elasticnet Regularization (Cross Validated Lambda)                                      |glmnet           |     41179|
|classif.glmnet       |GLM with Lasso or Elasticnet Regularization                                                               |glmnet           |     41179|
|surv.cvglmnet        |GLM with Regularization (Cross Validated Lambda)                                                          |glmnet           |     41179|
|surv.glmnet          |GLM with Regularization                                                                                   |glmnet           |     41179|
|classif.cforest      |Random forest based on conditional inference trees                                                        |party            |     36492|
|classif.ctree        |Conditional Inference Trees                                                                               |party            |     36492|
|regr.cforest         |Random Forest Based on Conditional Inference Trees                                                        |party            |     36492|
|regr.mob             |Model-based Recursive Partitioning  Yielding a Tree with Fitted Models Associated with each Terminal Node |party,modeltools |     36492|
|surv.cforest         |Random Forest based on Conditional Inference Trees                                                        |party,survival   |     36492|

As we are just looking for the packages let's compress the table a bit further and come to our...

## final table


{% highlight r %}
lrns.pgks = lrns[,list(learners = paste(class, collapse = ",")),by = .(package, downloads)]
lrns.pgks
{% endhighlight %}
_Here are the first 20 rows of the table:_

|package          | downloads|learners                                                                                                                                                    |
|:----------------|---------:|:-----------------------------------------------------------------------------------------------------------------------------------------------------------|
|survival         |    153681|surv.coxph                                                                                                                                                  |
|e1071            |    102249|classif.naiveBayes,classif.svm,regr.svm                                                                                                                     |
|MASS             |     55852|classif.lda,classif.qda                                                                                                                                     |
|randomForest     |     52094|classif.randomForest,regr.randomForest                                                                                                                      |
|kernlab          |     44812|classif.gausspr,classif.ksvm,classif.lssvm,cluster.kkmeans,regr.gausspr,regr.ksvm,regr.rvm                                                                  |
|glmnet           |     41179|classif.cvglmnet,classif.glmnet,regr.cvglmnet,regr.glmnet,surv.cvglmnet,surv.glmnet                                                                         |
|party            |     36492|classif.cforest,classif.ctree,multilabel.cforest,regr.cforest,regr.ctree                                                                                    |
|party,modeltools |     36492|regr.mob                                                                                                                                                    |
|party,survival   |     36492|surv.cforest                                                                                                                                                |
|fpc              |     33664|cluster.dbscan                                                                                                                                              |
|rpart            |     28609|classif.rpart,regr.rpart,surv.rpart                                                                                                                         |
|RWeka            |     20583|classif.IBk,classif.J48,classif.JRip,classif.OneR,classif.PART,cluster.Cobweb,cluster.EM,cluster.FarthestFirst,cluster.SimpleKMeans,cluster.XMeans,regr.IBk |
|gbm              |     19554|classif.gbm,regr.gbm,surv.gbm                                                                                                                               |
|nnet             |     19538|classif.multinom,classif.nnet,regr.nnet                                                                                                                     |
|caret,pls        |     18106|classif.plsdaCaret                                                                                                                                          |
|pls              |     18106|regr.pcr,regr.plsr                                                                                                                                          |
|FNN              |     16107|classif.fnn,regr.fnn                                                                                                                                        |
|earth            |     15824|regr.earth                                                                                                                                                  |
|neuralnet        |     15506|classif.neuralnet                                                                                                                                           |
|class            |     14493|classif.knn,classif.lvq1                                                                                                                                    |

And of course we want to have a small visualization:

{% highlight r %}
library(ggplot2)
library(forcats)
lrns.pgks$learners = factor(lrns.pgks$learners, lrns.pgks$learners)
g = ggplot(lrns.pgks[20:1], aes(x = fct_inorder(stri_sub(paste0(package,": ",learners), 0, 64)), y = downloads, fill = downloads))
g + geom_bar(stat = "identity") + coord_flip() + xlab("") + scale_fill_continuous(guide=FALSE)
{% endhighlight %}

![plot of chunk compressTablePlot](/figures/2017-03-30-Most_Popular_Learners_in_mlr/compressTablePlot-1.svg)

## Remarks

This is not really representative of how popular each learner is, as some packages have multiple purposes (e.g. multiple learners).
Furthermore it would be great to have access to the [trending](https://www.r-pkg.org/trending) list.
Also [_most stars at GitHub_](https://www.r-pkg.org/starred) gives a better view of what the developers are interested in.
Looking for machine learning packages we see there e.g: [xgboost](https://github.com/dmlc/xgboost), [h2o](https://github.com/h2oai/h2o-3) and [tensorflow](https://github.com/rstudio/tensorflow).


