#' @import methods ddR
#' @importFrom sparklyr spark_connect spark_disconnect


setClass("spark.ddR", contains = "ddRDriver", slots = c(sc = "spark_connection"))

init_spark <- function(master = "local", config_file, ...) {
  message("Backend switched to Spark. Initializing the Spark Context")

  if(hasArg(config_file)){
    message("Applying user specified configuration file")
    spark_conf <- spark_config(file = config_file)
    sc = sparklyr::spark_connect(master, app_name = "ddR", config = spark_conf)
  }else{
    sc = sparklyr::spark_connect(master, app_name = "ddR")
  }

  # http://apache-spark-user-list.1001560.n3.nabble.com/Getting-the-number-of-slaves-td10604.html
  memory_status <- sparklyr::invoke(sc$spark_context, "getExecutorMemoryStatus")
  num_exec <- length(memory_status)

  new("spark.ddR",
      DListClass = "ParallelObj",
      DFrameClass = "ParallelObj",
      DArrayClass = "ParallelObj",
      name = "spark",
      executors = num_exec,
      sc = sc
  )
}


#' @export
setMethod("shutdown", "spark.ddR", function(x) {
  message("Stopping the Spark Context")
  sparklyr::spark_disconnect((x@sc))
})


#' @export
setGeneric("get_parts", function(x, index, ...) standardGeneric("get_parts"))

#' @export
setGeneric("do_collect", function(x, parts) standardGeneric("do_collect"))

#' @export
setGeneric("do_dmapply", function(x, parts) standardGeneric("do_collect"))

 NULL
