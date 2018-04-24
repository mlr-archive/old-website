---
layout: post
title: "Paper published: mlr - Machine Learning in R"
author: jakob
---

We are happy to announce that we can finally answer the question on how to cite *mlr* properly in publications.

Our paper on *mlr* has been published in the open-access Journal of Machine Learning Research (JMLR) and can be downloaded on the [journal home page](http://www.jmlr.org/papers/v17/15-066.html).

<!--more-->

[![preview paper](/images/2016-10-20-Paper-published-mlr-Machine-Learning-in-R/paper-first-page.png)](http://www.jmlr.org/papers/v17/15-066.html)

The paper gives a brief overview of the features of *mlr* and also includes a comparison with similar toolkits.
For an in-depth understanding we still recommend our excellent [online mlr tutorial](https://mlr-org.github.io/mlr/) which is now also available as a [PDF](https://arxiv.org/abs/1609.06146) on arxiv.org or as [zipped HTML files](https://mlr-org.github.io/mlr/devel/mlr_tutorial.zip) for offline reading.

Once *mlr 2.10* hits CRAN you can retrieve the citation information from within R:

{% highlight r %}
citation("mlr")
{% endhighlight %}

{% highlight text %}
## 
##  Bischl B, Lang M, Kotthoff L, Schiffner J, Richter J, Studerus
##  E, Casalicchio G and Jones Z (2016). "mlr: Machine Learning in
##  R." _Journal of Machine Learning Research_, *17*(170), pp.
##  1-5. <URL: http://jmlr.org/papers/v17/15-066.html>.
##  
##  A BibTeX entry for LaTeX users is
##  
##    @Article{mlr,
##      title = {% raw %}{{{% endraw %}mlr}: Machine Learning in R},
##      author = {Bernd Bischl and Michel Lang and Lars Kotthoff and Julia Schiffner and Jakob Richter and Erich Studerus and Giuseppe Casalicchio and Zachary M. Jones},
##      journal = {Journal of Machine Learning Research},
##      year = {2016},
##      volume = {17},
##      number = {170},
##      pages = {1-5},
##      url = {http://jmlr.org/papers/v17/15-066.html},
##    }
## 
{% endhighlight %}

