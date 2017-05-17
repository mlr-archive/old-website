---
layout: post
title: "shinyMlr"
author: flo
---

shinyMlr is a web application, built with the
[R-package "shiny"](https://cran.r-project.org/web/packages/shiny/index.html)
that provides a user interface for [mlr](https://github.com/mlr-org/mlr).
By wrapping the main functionalities of mlr into our app, as well as
implementing additional features for data visualisation and data preprocessing,
we built a widely usable application for your day to day
machine learning tasks, which we would like to present to you today.

<!--more-->

[Stefan](http://Coorsaa.github.io/) and [me](http://florianfendt.github.io/)
started working on this project late summer 2016 as part of a practical
course we attended for our Master's program. We enjoyed the work on this
project and will continue to maintain and extend our app in the future.
However, after almost one year of work our application got a versatile tool
and it is time to present it to a broader audience.
To introduce you to the workflow and main features of our app,
we uploaded a video series to our
[youtube channel](https://www.youtube.com/channel/UCxafH0u7ewWHEULXcEa_zkg).
The videos are little tutorials that illustrate the workflow
in form of a use case:
We used the titanic data set from the
[kaggle competition](https://www.kaggle.com/c/titanic)
as example data to show you step by step how it can be analyzed with our
application.

The first video gives a small introduction and shows you how data can be
imported:

{% include youtubeplayer.html id="VZuRSQZdayY" %}


In the next tutorial you will learn how to visualise your data and
preprocess it:

{% include youtubeplayer.html id="kKV4mg-wRts" %}

The third and fourth screencasts show you how to create your task and
how to construct and modify our built-in learning algorithms:

{% include youtubeplayer.html id="HPr-9dBbv6o" %}

{% include youtubeplayer.html id="SjeQzvEjoaQ&t=3s" %}


The fifth part of our tutorials shows you how to tune your learners to find
suitable parameter settings for your given training set:

{% include youtubeplayer.html id="gMh4ZhRQhJI" %}

The sixth video gives you detailed information on how to actually train models
on your task, predict on new data and plot model diagnostic and prediction
plots:

{% include youtubeplayer.html id="Fxbc5YmI_i8" %}


The seventh video runs a benchmark experiment, to show you how to compare
different learners in our application:

{% include youtubeplayer.html id="3Y1cfxtUCNY" %}

The last tutorial briefly demonstrates how to render an interactive report
from your analysis done with our app:

{% include youtubeplayer.html id="UxHHYem4-s8" %}

I hope you enjoyed watching the videos and learned how to make use of our
application.
If you like working with our app please leave us a star and follow us on
[github](https://github.com/mlr-org/shinyMlr)

