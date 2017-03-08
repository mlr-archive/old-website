---
layout: post
title: "Being successful on Kaggle using mlr"
author: giuseppe
draft: true
---

People that already have participated in a Kaggle competition know how difficult 
it can be to obtain a good score on the leaderboard. 
This blog post is especially aimed at beginners and presents 10 rules that can 
help everyone, especially beginners, to achieve a good leaderboard score. 
For this purpose I have also created a [*Kernel*](https://www.kaggle.com/casalicchio/bike-sharing-demand/tuning-with-mlr) 
for the [*Kaggle bike sharing competition*](https://www.kaggle.com/casalicchio/bike-sharing-demand) 
that shows how the `mlr` package can be used to tune a xgboost model with random search in parallel (using 16 cores). The R script scores rank 90 (of 3251) on the Kaggle leaderboard.

## 10 Rules

  1. Invest your time instead of spending it
  1. Use a good software
  1. Do your research
  1. Look into the data
  1. Understand the measure
  1. Validate your model 
  1. Tune your model
  1. (Think of new features)
  1. (Remove noisy features)
  1. (Ensemble different models)

### 1. Invest your time instead of spending it

To be successful on Kaggle, you will need a good tradeoff between time and skill. 

  - How to gain skills: (see rule #2 to #4)
  - How to gain time: 
    - You will find at least 1 hour a day somehow!
    (don't watch TV series, don't drink beer, sleep less, eat faster...).
    - Be lazy and wait until someone else uploads a "beat the benchmark" script (don't stop here, extend and improve it).

### 2. Use a good software

A good software should always help you with rule #1, i.e., it should provide a 
good infrastructure to 

  - resample models,
  - optimize hyperparameters,
  - select features,
  - compare models,
  - parallelize your code ...

Examples of good software: 

  - For python: scikit-learn \
  (http://scikit-learn.org/stable/auto_examples).
  - For R: The packages `mlr` (https://mlr-org.github.io/mlr-tutorial) or `caret`.

### 3. Do your research
  
  - Read the description and try to understand the aim of the competition. 
  - Keep reading the forum and looking into scripts/kernels of others, learn from them!
  - Domain knowledge will always help you (i.e., read publications about the topic, wikipedia is also ok).
  - Use external data if it is allowed (e.g., google trends, historical weather data, ...).

### 4. Look into the data

  - Which features are numerical/categorical/ordinal or time dependent?
  - Decide how to handle missing values, it is often enough to 
    - impute missing values with the mean, median or with values that are out of
    range (for numerical features).
    - interpolate missing values if the feature is time dependent.
    - introduce a new category for the missing values (for categorical features).
  - Do exploratory data analysis (for the lazy: wait until someone else uploads an EDA kernel). 
  - Insights you learn here, will also help you later (creating new features).

### 5. Understand the measure

Use an approach that directly optimizes the measure of interest!

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

### 6. Validate your model

  - How do you set up the [*resampling procedure*](https://mlr-org.github.io/mlr-tutorial/devel/html/resample), e.g., cross-validation (CV) to measure your model performance?
  - Find out how the data was split into train and test data, your resampling procedure should have the same scheme.
  - Improvements on your local CV score should also lead to improvements on the leaderboard. 
  - If this is not the case, you can try
    - several CV folds (e.g., 3-fold, 5-fold, 8-fold)
    - repeated CV (e.g., 3 times 3-fold, 3 times 5-fold)
    - stratified CV

  Time series data, e.g., from the [*bike sharing*](https://www.kaggle.com/c/bike-sharing-demand/data) competition:
  \begin{center}
  \includegraphics[width=0.7\textwidth]{bike.png}
  \end{center}
  
### 7. Tune your model

It is often enough to focus on a single model (e.g. [*xgboost*](https://xgboost.readthedocs.io/en/latest)) and to tune its hyperparameters.

  - Aim: \newline
  Find the best hyperparameters that, for the given data set, optimize the pre-defined measure.
  - Problem: \newline
  Some models have many hyperparameters that can be tuned.
  - Possible solutions: 
    - [*Grid search or random search*](https://mlr-org.github.io/mlr-tutorial/devel/html/tune/index.html)
    - Advanced procedures such as [*irace*](https://mlr-org.github.io/mlr-tutorial/devel/html/advanced_tune/index.html) 
    or [*mbo (bayesian optimization)*](https://mlr-org.github.io/mlrMBO/articles/mlrMBO.html)

### Further optional stuff

  8. Think of new features:
    - Try to introduce new valuable information (which you think can't be found by the model you use).
    - Example: For time series, you could try
        - to add the weekday as new feature
        - to use rolling mean/median of any other numerical feature
        - to add features with a lag...
  9. Remove noisy features: [*Feature selection / filtering*](https://mlr-org.github.io/mlr-tutorial/devel/html/feature_selection/index.html)
  10. Ensemble **different** models (see, e.g. [*this guide*](http://mlwave.com/kaggle-ensembling-guide)): 
    - simple averaging
    - finding optimal weights for averaging 
    - stacking

