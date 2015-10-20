---
title: "ddR README"
author: "Edward Ma, Indrajit Roy"
date: "2015-10-20"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{Vignette Title}
  %\VignetteEngine{knitr::rmarkdown}
  \usepackage[utf8]{inputenc}
---

ddR is both an API and an R package that permits the declaration of 'distributed' objects (i.e., `dlist`, `dframe`, `darray`), and facilitates parallel operations on these data structures using R-style `apply` functions. It also allows different backends (that support ddR, and have ddR "drivers" written for them), to be dynamically activated in the R user's environment, to be selected for use with the API.

To learn how to use ddR, please refer to the user guide under vignettes/.

### Some quick examples

Init'ing a dlist:

```r
a <- dmapply(function(x) { x }, rep(3,5))
```

```
## Error in eval(expr, envir, enclos): could not find function "dmapply"
```

```r
collect(a)
```

```
## Error in eval(expr, envir, enclos): could not find function "collect"
```

Printing `a`:

```r
a
```

```
## Error in eval(expr, envir, enclos): object 'a' not found
```

`a` is now a distributed object in ddR. Note that we did not specify the number of partitions of the output, but by default it went to the length of the inputs (5). If we wanted to specify how the output should be partitioned, we can use the `nparts` parameter to `dmapply`:

Adding 1 to first element of `a`, 2 to the second, etc.


```r
b <- dmapply(function(x,y) { x + y }, a, 1:5,nparts=1)
```

```
## Error in eval(expr, envir, enclos): could not find function "dmapply"
```

```r
b
```

```
## Error in eval(expr, envir, enclos): object 'b' not found
```

As you can see, `b` only has one partition of 5 elements.


```r
collect(b)
```

```
## Error in eval(expr, envir, enclos): could not find function "collect"
```
Some other operations:
`

Adding `a` to `b`, then subtracting a constant value

```r
addThenSubtract <- function(x,y,z) {
  x + y - z
}
c <- dmapply(addThenSubtract,a,b,MoreArgs=list(z=5))
```

```
## Error in eval(expr, envir, enclos): could not find function "dmapply"
```

```r
collect(c)
```

```
## Error in eval(expr, envir, enclos): could not find function "collect"
```

Accessing dobjects by parts:


```r
d <- dmapply(function(x) length(x),parts(a))
```

```
## Error in eval(expr, envir, enclos): could not find function "dmapply"
```

```r
collect(d)
```

```
## Error in eval(expr, envir, enclos): could not find function "collect"
```

We partitioned `a` with 5 parts and it had 5 elements, so the length of each partition is of course 1.

However, `b` only had one partition, so that one partition should be of length 5:


```r
e <- dmapply(function(x) length(x),parts(b))
```

```
## Error in eval(expr, envir, enclos): could not find function "dmapply"
```

```r
collect(e)
```

```
## Error in eval(expr, envir, enclos): could not find function "collect"
```

Note that `parts()` and non-parts arguments can be used in any combination to dmapply. `parts(dobj)` returns a list of the partitions of that dobject, which can be passed into dmapply like any other list. `parts(dobj,index)`, where `index` is a list, vector, or scalar, returns a specific partition or range of partitions of `dobj`.

We also have support for `darrays` and `dframes`. Their APIs are a bit more complex, and this guide will be updated shortly with that content.

For a more detailed example, you may view (and run) the example scripts under /examples.

## Using the Distributed R backend

Use the Distributed R library for ddR:
```r
library(distributedR.ddR)
```

```
## Loading required package: distributedR
## Loading required package: Rcpp
## Loading required package: RInside
## Loading required package: XML
## Loading required package: ddR
## 
## Attaching package: 'ddR'
## 
## The following objects are masked from 'package:distributedR':
## 
##     darray, dframe, dlist, is.dlist
```

```r
useBackend(distributedR)
```

```
## Master address:port - 127.0.0.1:50000
```

Now you can try the different list examples which were used with the 'parallel' backend.

## How to Contribute

You can help us in different ways:

1. Reporting [issues](https://github.com/vertica/ddR/issues).
2. Contributing code and sending a [Pull Request](https://github.com/vertica/ddR/pulls).

In order to contribute the code base of this project, you must agree to the Developer Certificate of Origin (DCO) 1.1 for this project under GPLv2+:

    By making a contribution to this project, I certify that:
    
    (a) The contribution was created in whole or in part by me and I have the 
        right to submit it under the open source license indicated in the file; or
    (b) The contribution is based upon previous work that, to the best of my 
        knowledge, is covered under an appropriate open source license and I 
        have the right under that license to submit that work with modifications, 
        whether created in whole or in part by me, under the same open source 
        license (unless I am permitted to submit under a different license), 
        as indicated in the file; or
    (c) The contribution was provided directly to me by some other person who 
        certified (a), (b) or (c) and I have not modified it.
    (d) I understand and agree that this project and the contribution are public and
        that a record of the contribution (including all personal information I submit 
        with it, including my sign-off) is maintained indefinitely and may be 
        redistributed consistent with this project or the open source license(s) involved.

To indicate acceptance of the DCO you need to add a `Signed-off-by` line to every commit. E.g.:

    Signed-off-by: John Doe <john.doe@hisdomain.com>

To automatically add that line use the `-s` switch when running `git commit`:

    $ git commit -s
