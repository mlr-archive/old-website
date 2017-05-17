---
layout: post
title: "Parallel benchmarking with OpenML and mlr"
author: heidi
draft: true
---

{% highlight r %}
knitr::opts_chunk$set(eval = FALSE)
{% endhighlight %}


With this post I want to show you how to benchmark several learners 
(or learners with different parameter settings) using 
several data sets in a structured and parallelized fashion. For this we
want to use batchtools. 

The data that we will use here is stored on the open machine learning platform
openml.org and we can download it together with information on what to do with
it in form of a task.

If you have a small project and don't need to parallelize, you might want to
just look at the previous blogpost called [mlr loves OpenML](http://mlr-org.github.io/mlr-loves-OpenML/).

The following packages are needed for this:

{% highlight r %}
library("OpenML")
library("mlr")
library("batchtools")
{% endhighlight %}
and you need to know how many cores are available on your machine:

{% highlight r %}
(ncores <- parallel::detectCores() - 1)
{% endhighlight %}


Now we download five tasks from OpenML:

{% highlight r %}
set.seed(123)

## get useful tasks
task_infos = listOMLTasks(tag = "study_14")

## take a sample of 5 tasks from these
task_ids = sample(task_infos$task.id, size = 5)
tasks = lapply(task_ids, getOMLTask)
{% endhighlight %}

In a next step we need to create the so called registry. What this basically does is to create
a folder with a certain subfolderstructure.

{% highlight r %}
## before creating the registry, check if it already exists
## if so, delete it
unlink("parallel_benchmarking_blogpost", recursive = TRUE)

## create the experiment registry
reg = makeExperimentRegistry(file.dir = "parallel_benchmarking_blogpost",
                             packages= c("mlr", "OpenML", "party"),
                             seed = 123)
names(reg)
reg$cluster.functions

## allow for parallel computing, for other options see ?makeClusterFunctions
reg$cluster.functions = makeClusterFunctionsMulticore(ncpus = ncores)
{% endhighlight %}

Now you should have a new folder in your working directory with the name
`parallel_benchmarking_blogpost` and the following subfolders / files:
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


In the next step we get to the interesting point. We need to define...

- the **problems**, which in our case are simply the OpenML tasks we downloaded.
- the **algorithm**, which with mlr and OpenML is quite simply achieved using 
`makeLearner` and `runTaskMlr`. We do not have to save the run results (result of applying the learner
to the task), but we can directly upload it to OpenML where the results are automatically evaluated.
- the machine learning **experiment**, i.e. in our case which parameters do we want to set for which learner. 

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


## what versions of the two algorithms do we want to compute
algo.design = list(mlr = expand.grid(learner = c("classif.ctree", "classif.cforest"),
                                     teststat = c("quad", "max"),
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


<!-- There are different ways how this can be done.  -->


<!-- scope: mehere lerner, (mit manuell gesetzten params), mehrere tasks -> schönen vgl erzeugen -->
<!-- - kein: tuning, featsel, preproc -->


<!-- 1) runTaskMlr: 1 oml task, 1 mlr learner > OMLRun, upload geht -->

<!-- 2) benchmark: viele MLR learner, VIELE mlr tasks > geiler container kommt raus. -->
<!-- geht parallel. -->
<!-- problem: -->
<!-- - OML tasks gehen nicht direkt rein -->
<!-- > lösung: konvert geht -->
<!-- - Upload geht nicht (einfach) -->
<!-- > BMRResult kann man aktuell nicht konvertieren-.... doof, ist aber so -->

<!-- 3) batchmark: -->
<!-- ist 2) in "geiler", aber das upload problem ist aktuell das gleiche. -->
<!-- aber bessere OML anbindung, man kann direkt task ids eingeben, effizienter, weil batchtools andbingund -->

<!-- 4) runtaskMLR könnte man min parallel;ap oder so parallel machen. -->
<!-- (BB: find ich aber eher nicht soooo fleixbel.) -->


<!-- 5) beste optuin aktuell: -->
<!-- batchtools mit runTask  -->
