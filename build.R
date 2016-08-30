#build process inspired by: 
#https://github.com/yihui/knitr-jekyll
local({
  # fall back on '/' if baseurl is not specified
  baseurl = servr:::jekyll_config('.', 'baseurl', '/')
  if (baseurl == "") baseurl = "/"
  knitr::opts_knit$set(
    base.url = baseurl
  )
  # fall back on 'kramdown' if markdown engine is not specified
  markdown = servr:::jekyll_config('.', 'markdown', 'kramdown')
  # see if we need to use the Jekyll render in knitr
  if (markdown == 'kramdown') {
    knitr::render_jekyll()
  } else knitr::render_markdown()

  # input/output filenames are passed as two additional arguments to Rscript
  a = commandArgs(TRUE)
  d = gsub("_source/",replacement = '', a[1])
  # d = a[1]
  d = gsub('^_|[.][a-zA-Z]+$', '', d)
  knitr::opts_chunk$set(
    dev = c("svg","png"),
    fig.width=7, 
    fig.height=6,
    fig.path   = sprintf('figures/%s/', d),
    cache.path = sprintf('cache/%s/', d)
  )
  knitr::opts_knit$set(width = 70)
  # set seed hashed accroding to input
  seed.int = strtoi(substr(digest::digest(a[2], algo = "crc32"),0,4), base = 16L)
  set.seed(seed.int)
  knitr::knit(a[1], a[2], quiet = TRUE, encoding = 'UTF-8', envir = .GlobalEnv)
})
