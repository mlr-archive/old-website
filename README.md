# mlr blog
[The mlr blog](https://mlr-org.github.io) is build on [Jekyll](https://github.com/jekyll/jekyll) and it's more or less a fork of [that ground structure].

## blog build status
[![Build Status](https://travis-ci.org/mlr-org/mlr-org.github.io.svg?branch=master)](https://travis-ci.org/mlr-org/mlr-org.github.io)

Note: To get a green Travis Icon we need amongst others
* All images with alt attribute
* No links on 404 pages

## submit a post
1. Clone this repository.
2. Add yourself in the authors section in `./_config.yml`
3. Add yourself in `./about.md`
4. **Your first post:** Create a `YYYY-MM-DD-Your-catchy-headline.Rmd` file in `./_source`. IMPORTANT: The filename should represent your headline as close as possible as this will later be the URL of your post!
5. Add header information in the Rmd File (see below).
6. Add your own R-Markdown content below the header information. 
7. Run *R* and call `servr::jekyll()` in the projet root **or** use the makefile and run `make` in `_source/`. 
8. Git add the source `.Rmd` and the generated `.md` file as well as plots (png + svg!), commit and push.
9. Go to `http://mlr-org.github.io/Your-catchy-headline/`. Everything looks nice? Then you can remove the `draft = true`. Next time it might not be necessary anymore because you did `jekyll serve` on your local machine. (If you don't have Jekyll: `gem install jekyll`)
10. After your post is not a draft anymore you should see it in the blog after some minutes. No? [Check here](https://github.com/mlr-org/mlr-org.github.io/settings) if something went wrong.
11. Now post the link to your awesome post on Twitter, Facebook, LinkedIn etc. (SEO - please?)
12. Wait for our thankfulness to arrive.


### How a header information should look like

```
---
layout: post
title: Your catchy headline!
author: theExactSameNameYouPutInTheConfig
draft: true 
---
This stuff will be visible on the main blog site.
<!--more-->
This stuff you will be only visible on the specific post.
However the first page in the whole post will be the thumbnail.
```

## Specials

### Picture File Formats

By default we generate svg and png of your plots. 
The svg files are for high quality display within your post and the png files are used for the preview and the social media share image!

### Specify the main image of your post

If you want to specify the image shown in the post overview and which will be seen when people share your post on FB and Twitter you can specify it in the YAML front matter as follows:

```
---
layout: post
title: Your catchy headline!
author: theExactSameNameYouPutInTheConfig
titleimage: chunkname-1
---
```

This will use the first picture that was an printed within the chunk called `chunkname`.
You always have to give the `-1` even if the chunk only outputs one image!

## Questions

If something is wrong or you have a question open an issue or ask in the [slack chanel](https://mlr-org.slack.com/messages/mlr-marketing/).
