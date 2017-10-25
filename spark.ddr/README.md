---
title: "spark.ddR README"
date: "2017-10-25"
---

### Some quick examples


```r
library(ddR)
```
By default, the `parallel` backend is used with all the cores present on the machine. You can switch backends or specify the number of cores to use with the `useBackend` function.

```r
ddR::useBackend('spark')
```
To switch to spark backend use `spark` as an argument to `useBackend`. Make sure you have the latest version of spark installed and environment `SPARK_HOME` set. By default spark connects to `local` instance.
