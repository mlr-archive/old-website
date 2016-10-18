---
layout: post
title: "Paper is out; mlr: Machine Learning in R"
author: jakob
---

We are happy to announce that our paper is out and finally we can answer your question on how to cite *mlr* in your publication.

The paper is published in the Journal of Machine Learning Research (JMLR) and is open access. 
You can find the abstract, the bib-file and the PDF following this [link](http://www.jmlr.org/papers/v17/15-066.html).

<!--more-->

It offers a brief overview of the features of *mlr* and a short comparision to similar toolkits.
For an in-depth understanding we still recommend our [excellent mlr tutorial](https://mlr-org.github.io/mlr-tutorial/) which is also available as a [PDF on arxiv.org](https://arxiv.org/abs/1609.06146) - but due to technical limitations missing parts of the appendix. 

For offline enjoyment you can always download the [latest version of the tutorial zipped](https://mlr-org.github.io/mlr-tutorial/devel/mlr_tutorial.zip).

Once *mlr 2.10* is on cran you will find citation information calling:

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

