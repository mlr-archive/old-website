# mlr blog
The mlr blog is build on [Jekyll](https://github.com/jekyll/jekyll) and it's more or less a fork of [that ground structure].

## submit a post
1. Clone this repository.
2. Make Sure `./knit2md` is executable (`chmod +x knit2md`)
3. Add yourself in the authors section in `./_config.yml`
4. Add yourself in `./about.md`
5. **Your first post:** Create a `YYYY-MM-DD-Your-catchy-headline.Rmd` file in `./_source`.
6. Add header information in the Rmd File
```
---
layout: post
title: Your catchy headline!
author: theExactSameNameYouPutInTheConfig
draft: true 
---
```
7. Add your own R-Markdown content below the header information. 
8. If everything runs smooth knit file with running `./knit2md/_source/YYYY-MM-DD-Your-catchy-headline.Rmd`
9. Git add the source `.Rmd` and the generated `.md` file as well as plots, commit and push.
10. Go to `http://mlr-org.github.io/Your-catchy-headline/`. Everything looks nice? Then you can remove the `draft = true`. Next time it might not be necessary anymore because you did `jekyll serve` on your local machine. ([This is just a small hint](http://jekyllrb.com/docs/quickstart/))
11. After your post is not a draft anymore you should see it in the blog after some minutes. No? [Check here](https://github.com/mlr-org/mlr-org.github.io/settings) if something went wrong.
12. Now post the link to your awesome post on Twitter, Facebook, linkedin etc. (SEO - please?)
13. Wait for our thankfullness to arrive.

- Did I miss something?
