---
layout: post
title: "Being successful on Kaggle using `mlr`"
author: giuseppe
draft: true
---

People that already have participated in a Kaggle competition know how difficult 
it can be to obtain a good score on the leaderboard. 
This blog post is aimed at beginners and presents 7 rules they can use to
improve their ranking. 
For this purpose I have also created a [*Kernel*](https://www.kaggle.com/casalicchio/bike-sharing-demand/tuning-with-mlr) 
for the [*Kaggle bike sharing competition*](https://www.kaggle.com/casalicchio/bike-sharing-demand) 
that shows how the `mlr` package can be used to tune a xgboost model with random search in parallel (using 16 cores). The R script scores rank 90 (of 3251) on the Kaggle leaderboard.

## 7 Rules

  1. Use a good software
  1. Zoom in on the problem to solve
  1. Validate your model 
  1. Tune your model
  1. Create and select features
  1. Ensemble different models
  1. Track your progress


### 1. Use a good software

No matter if you choose R, Python or another language to work on kaggle, chances
are, that you have to deal with quite a few packages to follow a state of the art 
machine learning workflow. To save time you should start using a 'software'
that offers a standardized and well tested interface for the important steps 
in your workflow like:

  - Benchmarking different machine learning algorithms (learners)
  - Resampling methods for model validation
  - Optimizing hyperparameters of learners
  - Creating and selecting features or dealing with missing values
  - Parallelizing the points above
  
Examples of such a good 'software' are: 

  - For python: scikit-learn (http://scikit-learn.org/stable/auto_examples).
  - For R: `mlr` (https://mlr-org.github.io/mlr-tutorial) or `caret`.


### 2. Zoom in on the problem to solve
  
To develop a good understanding of the kaggle challenge you should:

  - Understand the problem domain:
    - Read the description and try to understand the aim of the competition. 
    - Keep reading the forum and looking into scripts/kernels of others, learn from them!
    - Domain knowledge will always help you (i.e., read publications about the topic, wikipedia is also ok).
    - Use external data if it is allowed (e.g., google trends, historical weather data, ...).
    
  - Explore the dataset:
    - Which features are numerical, categorical, ordinal or time dependent?
    - Decide how to handle [*missing values*](https://mlr-org.github.io/mlr-tutorial/devel/html/impute/index.html), it is often enough to 
        - impute missing values with the mean, median or with values that are out of range (for numerical features).
        - interpolate missing values if the feature is time dependent.
        - introduce a new category for the missing values (for categorical features).
    - Do exploratory data analysis (for the lazy: wait until someone else uploads an EDA kernel). 
    - Insights you learn here, will also help you later (creating new features).
    
It is also very important to choose an approach that directly optimizes the measure of interest!
Example: 

  - The **median** minimizes the mean absolute error **(MAE)** and 
  the **mean** minimizes the mean squared error **(MSE)**. 
  - By default, many regression algorithms predict the expected **mean** but there 
  are counterparts that predict the expected **median** 
  (e.g., linear regression vs. quantile regression).
  <!-- - Some measures use a (log-)transformation of the target  -->
  <!-- (e.g. the **RMSLE**, see [*bike sharing competition*](https://www.kaggle.com/c/bike-sharing-demand/details/evaluation)). \newline -->
  <!-- $\rightarrow$ transform the target in the same way before modeling. -->
  - For strange measures: Use algorithms where you can implement your own objective 
  function, see e.g. 
      - [*tuning parameters of a custom objective*](https://www.kaggle.com/casalicchio/allstate-claims-severity/tuning-the-parameter-of-a-custom-objective-1120) or 
      - [*customize loss function, and evaluation metric*](https://github.com/tqchen/xgboost/tree/master/demo#features-walkthrough).


### 3. Validate your model

Good machine learning models not only work on the data they were trained on, but
also on test data that was not used for training the model. Everytime you use data
to make any kind of decision (like feature or model selection, hyperparameter tuning, ...),
the data becomes less valuable for the test case. So if you always use the public 
leaderboard for testing, you might overfit it and lose many ranks once the private
leaderboard is revealed.
A better approach is the use of a validation scheme on the train data: 

  - First figure out how the kaggle-data was split into train and test data. Your resampling strategy should follow the same method. So if kaggle uses, e.g. a feature for splitting the data, you should not use random samples for creating cross-validation folds.
  - Set up a [*resampling procedure*](https://mlr-org.github.io/mlr-tutorial/devel/html/resample), e.g., cross-validation (CV) to measure your model performance
  - Improvements on your local CV score should also lead to improvements on the leaderboard. 
  - If this is not the case, you can try
      - several CV folds (e.g., 3-fold, 5-fold, 8-fold)
      - repeated CV (e.g., 3 times 3-fold, 3 times 5-fold)
      - stratified CV
  - `mlr` offers nice [*visualizations to benchmark*](https://mlr-org.github.io/mlr-tutorial/devel/html/benchmark_experiments/index.html#benchmark-analysis-and-visualization) different algorithms.
  
### 4. Tune your model

It is often enough to focus on a single model (e.g. [*xgboost*](https://xgboost.readthedocs.io/en/latest)) and to tune its hyperparameters.

  - Aim: 
  Find the best hyperparameters that, for the given data set, optimize the pre-defined measure.
  - Problem: 
  Some models have many hyperparameters that can be tuned.
  - Possible solutions: 
    - [*Grid search or random search*](https://mlr-org.github.io/mlr-tutorial/devel/html/tune/index.html)
    - Advanced procedures such as [*irace*](https://mlr-org.github.io/mlr-tutorial/devel/html/advanced_tune/index.html) 
    or [*mbo (bayesian optimization)*](https://mlr-org.github.io/mlrMBO/articles/mlrMBO.html)


### 5. Create and select features:

In many kaggle competitions finding a "magic feature" can put you in the top places. 
You should therefore try to introduce new features containing valuable information 
(which can't be found by the model) or remove noisy features (which can decrease model performance):

  - Concat several columns
  - Multiply/Add several numerical columns
  - Count NAs per row
  - Create dummy features from factor columns
  -  For time series, you could try
      - to add the weekday as new feature
      - to use rolling mean or median of any other numerical feature
      - to add features with a lag...
  - Remove noisy features: [*Feature selection / filtering*](https://mlr-org.github.io/mlr-tutorial/devel/html/feature_selection/index.html)
  
  
### 6. Ensemble **different** models (see, e.g. [*this guide*](http://mlwave.com/kaggle-ensembling-guide)): 

After training many different models, you might want to ensemble them into one strong model using one of these methods:

  - simple averaging
  - finding optimal weights for averaging 
  - stacking
  
  
### 7. Track your progress

A kaggle project might get quite messy very quickly, because you might try and commit 
many different ideas. To avoid getting lost, make sure to keep track of:

  - What preprocessing steps were used to create the data
  - What model was used for what commit
  - What values were predicted in the test file
  - What local score did the model achieve 
  - What public score did the model achieve
  
If you do not want to use a tool like git, at least make sure you create subfolders
for each commit. This way you can later analyse which models you might want to ensemble
or use for your final commits for the competition.
