---
layout: post
title: "Parallel benchmarking with OpenML and mlr"
author: heidi
draft: false
---


With this post I want to show you how to benchmark several learners (or learners with different parameter settings) using several data sets in a structured and parallelized fashion. 
For this we want to use [`batchtools`](https://mllg.github.io/batchtools/). 

The data that we will use here is stored on the open machine learning platform [openml.org](https://www.openml.org/) and we can download it together with information on what to do with it in form of a task.

<!--more-->

If you have a small project and don't need to parallelize, you might want to just look at the previous blog post called [mlr loves OpenML](http://mlr-org.github.io/mlr-loves-OpenML/).

The following packages are needed for this:

{% highlight r %}
library("OpenML")
library("mlr")
library("batchtools")
library("ggplot2")
{% endhighlight %}

Now we download five OpenML-tasks from OpenML:

{% highlight r %}
set.seed(2017)

## get useful tasks
task_infos = listOMLTasks(tag = "study_14")

## take a sample of 5 tasks from these
task_ids = sample(task_infos$task.id, size = 5)
tasks = lapply(task_ids, getOMLTask)
{% endhighlight %}

In a next step we need to create the so called registry. 
What this basically does is to create a folder with a certain subfolder structure.


{% highlight r %}
## create the experiment registry
reg = makeExperimentRegistry(
  file.dir = "parallel_benchmarking_blogpost",
  packages= c("mlr", "OpenML", "party"),
  seed = 123)
names(reg)
reg$cluster.functions

## allow for parallel computing, for other options see ?makeClusterFunctions
reg$cluster.functions = makeClusterFunctionsMulticore()
{% endhighlight %}

Now you should have a new folder in your working directory with the name `parallel_benchmarking_blogpost` and the following subfolders / files:
```{}
parallel_benchmarking_blogpost/
├── algorithms
├── exports
├── external
├── jobs
├── logs
├── problems
├── registry.rds
├── results
└── updates
```


In the next step we get to the interesting point. 
We need to define...

- the **problems**, which in our case are simply the OpenML tasks we downloaded.
- the **algorithm**, which with mlr and OpenML is quite simply achieved using `makeLearner` and `runTaskMlr`. 
We do not have to save the run results (result of applying the learner to the task), but we can directly upload it to OpenML where the results are automatically evaluated.
- the machine learning **experiment**, i.e. in our case which parameters do we want to set for which learner. 
As an example here, we will look at the _ctree_ algorithm from the [_party_](https://cran.r-project.org/package=party) package and see whether Bonferroni correction (correction for multiple testing) helps getting better predictions and also we want to check whether we need a tree that has more than two leaf nodes (`stump = FALSE`) or if a small tree is enough (`stump = TRUE`).

{% highlight r %}
## add the problem, in our case the tasks from OpenML
for(task in tasks) {
  addProblem(name = paste("omltask", task$task.id, sep = "_"), data = task)
}

##' Function that takes the task (data) and the learner, runs the learner on
##' the task, uploads the run and returns the run ID.
##' 
##' @param job required argument for addAlgorithm
##' @param instance required argument for addAlgorithm
##' @param data the task
##' @param learner the string that defines the learner, see listLearners()
runTask_uploadRun = function(job, instance, data, learner, ...) {
  
  learner = makeLearner(learner, par.vals = list(...))
  run = runTaskMlr(data, learner)
  
  run_id = uploadOMLRun(run, tag = "test", confirm.upload = FALSE)
  return(run_id)
  
}

## add the algorithm
addAlgorithm(name = "mlr", fun = runTask_uploadRun)

## what versions of the algorithm do we want to compute
algo.design = list(mlr = expand.grid(
  learner = "classif.ctree",
  testtype = c("Bonferroni", "Univariate"),
  stump = c(FALSE, TRUE),
  stringsAsFactors = FALSE))
algo.design$mlr

addExperiments(algo.designs = algo.design, repls = 1)

## get an overview of what we will submit
summarizeExperiments()
{% endhighlight %}

Now we can simply run our experiment:

{% highlight r %}
submitJobs()
{% endhighlight %}

While your job is running, you can check the progress using `getStatus()`.
As soon as `getStatus()` tells us that all our runs are done, we can collect the results of our experiment from OpenML.
To be able to do this we need to collect the run IDs from the uploaded runs we did during the experiment. 
Also we want to add the info of the parameters used (`getJobPars()`).


{% highlight r %}
results0 = reduceResultsDataTable()
job.pars = getJobPars()
results = cbind(run.id = results0$V1, job.pars)
{% endhighlight %}



{% highlight r %}
results
{% endhighlight %}



{% highlight text %}
##      run.id job.id       problem algorithm       learner   testtype
##  1: 1852889      1 omltask_34536       mlr classif.ctree Bonferroni
##  2: 1852882      2 omltask_34536       mlr classif.ctree Univariate
##  3: 1852888      3 omltask_34536       mlr classif.ctree Bonferroni
##  4: 1852885      4 omltask_34536       mlr classif.ctree Univariate
##  5: 1852883      5  omltask_3918       mlr classif.ctree Bonferroni
##  6: 1852884      6  omltask_3918       mlr classif.ctree Univariate
##  7: 1852886      7  omltask_3918       mlr classif.ctree Bonferroni
##  8: 1852887      8  omltask_3918       mlr classif.ctree Univariate
##  9: 1852895      9  omltask_3891       mlr classif.ctree Bonferroni
## 10: 1852897     10  omltask_3891       mlr classif.ctree Univariate
## 11: 1852890     11  omltask_3891       mlr classif.ctree Bonferroni
## 12: 1852891     12  omltask_3891       mlr classif.ctree Univariate
## 13: 1852892     13  omltask_2074       mlr classif.ctree Bonferroni
## 14: 1852896     14  omltask_2074       mlr classif.ctree Univariate
## 15: 1852893     15  omltask_2074       mlr classif.ctree Bonferroni
## 16: 1852894     16  omltask_2074       mlr classif.ctree Univariate
## 17: 1852900     17  omltask_9976       mlr classif.ctree Bonferroni
## 18: 1852901     18  omltask_9976       mlr classif.ctree Univariate
## 19: 1852898     19  omltask_9976       mlr classif.ctree Bonferroni
## 20: 1852899     20  omltask_9976       mlr classif.ctree Univariate
##     stump
##  1: FALSE
##  2: FALSE
##  3:  TRUE
##  4:  TRUE
##  5: FALSE
##  6: FALSE
##  7:  TRUE
##  8:  TRUE
##  9: FALSE
## 10: FALSE
## 11:  TRUE
## 12:  TRUE
## 13: FALSE
## 14: FALSE
## 15:  TRUE
## 16:  TRUE
## 17: FALSE
## 18: FALSE
## 19:  TRUE
## 20:  TRUE
{% endhighlight %}

With the run ID information we can now grab the evaluations from OpenML and plot for example the parameter settings against the predictive accuracy.


{% highlight r %}
run.evals0 = listOMLRunEvaluations(run.id = results$run.id)
{% endhighlight %}



{% highlight text %}
## Downloading from 'http://www.openml.org/api/v1/json/evaluation/list/run/1852889,1852882,1852888,1852885,1852883,1852884,1852886,1852887,1852895,1852897,1852890,1852891,1852892,1852896,1852893,1852894,1852900,1852901,1852898,1852899' to '<mem>'.
{% endhighlight %}



{% highlight r %}
run.evals = merge(results, run.evals0, by = "run.id")

ggplot(run.evals, aes(
  x = interaction(testtype, stump), 
  y = predictive.accuracy, 
  group = data.name, 
  color = interaction(task.id, data.name))) +
  geom_point() + geom_line()
{% endhighlight %}

![plot of chunk unnamed-chunk-12](/figures/2017-03-24-Parallel_benchmarking_with_OpenML_and_mlr/unnamed-chunk-12-1.svg)

We see that the only data set where a stump is good enough is the pc1 data set.
For the madelon data set Bonferroni correction helps. 
For the others it does not seem to matter. 
You can check out the results online by going to the task websites (e.g. for task 9976 for the madelon data set go to [openml.org/t/9976](https://www.openml.org/t/9976)) or the run websites (e.g. [openml.org/r/1852889](https://www.openml.org/r/1852889)).
