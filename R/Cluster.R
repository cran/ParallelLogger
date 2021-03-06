# @file Cluster.R
#
# Copyright 2021 Observational Health Data Sciences and Informatics
#
# This file is part of ParallelLogger
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

doSetAndromedaTempFolder <- function(andromedaTempFolder) {
  options(andromedaTempFolder = andromedaTempFolder)
  ParallelLogger::logTrace("AndromedateTempFolder set to ", andromedaTempFolder)
}

#' Create a cluster of nodes for parallel computation
#'
#' @param numberOfThreads          Number of parallel threads.
#' @param singleThreadToMain       If \code{numberOfThreads} is 1, should we fall back to running the
#'                                 process in the main thread?
#' @param setAndromedaTempFolder   When TRUE, the andromedaTempFolder option will be copied to each
#'                                 thread.
#'
#' @return
#' An object representing the cluster.
#'
#' @template ClusterExample
#'
#' @export
makeCluster <- function(numberOfThreads, singleThreadToMain = TRUE, setAndromedaTempFolder = TRUE) {
  if (numberOfThreads == 1 && singleThreadToMain) {
    cluster <- list()
    class(cluster) <- "noCluster"
    ParallelLogger::logTrace("Initiating cluster constisting only of main thread")
  } else {
    ParallelLogger::logTrace("Initiating cluster with ", numberOfThreads, " threads")
    cluster <- snow::makeCluster(numberOfThreads, type = "SOCK")
    logThreadStart <- function(loggers, threadNumber) {
      ParallelLogger::clearLoggers()
      for (logger in loggers) {
        ParallelLogger::registerLogger(logger)
      }
      options(threadNumber = threadNumber)
      ParallelLogger::logTrace("Thread ", threadNumber, " initiated")
      finalize <- function(env) {
        ParallelLogger::logTrace("Thread ", threadNumber, " terminated")
      }
      reg.finalizer(globalenv(), finalize, onexit = TRUE)
      return(NULL)
    }
    loggers <- ParallelLogger::getLoggers()
    for (i in 1:length(cluster)) {
      snow::sendCall(cluster[[i]], logThreadStart, list(loggers = loggers, threadNumber = i))
    }
    for (i in 1:length(cluster)) {
      snow::recvOneResult(cluster)
    }
    if (setAndromedaTempFolder) {
      if (!is.null(getOption("andromedaTempFolder"))) {
        for (i in 1:length(cluster)) {
          snow::sendCall(cluster[[i]],
                         doSetAndromedaTempFolder,
                         list(andromedaTempFolder = getOption("andromedaTempFolder")))
        }
        for (i in 1:length(cluster)) {
          snow::recvOneResult(cluster)
        }
      }
    }
  }
  return(cluster)
}

#' Require a package in the cluster
#'
#' @description
#' Calls the \code{require} function in each node of the cluster.
#'
#' @param cluster   The cluster object.
#' @param package   The name of the package to load in all nodes.
#'
#' @export
clusterRequire <- function(cluster, package) {
  if (class(cluster)[1] == "noCluster") {
    do.call("require", list(package = package))
  } else {
    requirePackage <- function(package) {
      do.call("require", list(package = package))
    }
    for (i in 1:length(cluster)) {
      snow::sendCall(cluster[[i]], requirePackage, list(package = package))
    }
    for (i in 1:length(cluster)) {
      snow::recvOneResult(cluster)
    }
  }
}

#' Stop the cluster
#'
#' @param cluster   The cluster to stop
#'
#' @template ClusterExample
#'
#' @export
stopCluster <- function(cluster) {
  if (class(cluster)[1] != "noCluster") {
    snow::stopCluster.default(cluster)
    ParallelLogger::logTrace("Stopping cluster")
  }
}

docall <- function(fun, args) {
  if ((is.character(fun) && length(fun) == 1) || is.name(fun))
    fun <- get(as.character(fun), envir = .GlobalEnv, mode = "function")
  do.call("fun", lapply(args, enquote))
}

functionWrapper <- function(..., fun = fun) {
  handler <- function(e) {
    ParallelLogger::logFatal(conditionMessage(e))
    stop(e)
  }
  withCallingHandlers(docall(fun, list(...)), error = handler)
}

#' Apply a function to a list using the cluster
#'
#' @details
#' The function will be executed on each element of x in the threads of the cluster. If there are more
#' elements than threads, the elements will be queued. The progress bar will show the number of
#' elements that have been completed. It can sometimes be important to realize that the context in
#' which a function is created is also transmitted to the worker node. If a function is defined inside
#' another function, and that outer function is called with a large argument, that argument will be
#' transmitted to the worker node each time the function is executed. It can therefore make sense to
#' define the function to be called at the package level rather than inside a function, to save
#' overhead.
#'
#' @param cluster       The cluster of threads to run the function.
#' @param x             The list on which the function will be applied.
#' @param fun           The function to apply. Note that the context in which the function is specifies
#'                      matters (see details).
#' @param ...           Additional parameters for the function.
#' @param stopOnError   Stop when one of the threads reports an error? If FALSE, all errors will be
#'                      reported at the end.
#' @param progressBar   Show a progress bar?
#'
#' @return
#' A list with the result of the function on each item in x.
#'
#' @template ClusterExample
#'
#' @export
clusterApply <- function(cluster, x, fun, ..., stopOnError = FALSE, progressBar = TRUE) {
  if (class(cluster)[1] == "noCluster") {
    lapply(x, fun, ...)
  } else {
    n <- length(x)
    p <- length(cluster)
    if (n > 0 && p > 0) {
      if (progressBar)
        pb <- txtProgressBar(style = 3)

      for (i in 1:min(n, p)) {
        snow::sendCall(cluster[[i]], functionWrapper, c(list(x[[i]]),
                                                        list(...),
                                                        list(fun = fun)), tag = i)
      }

      val <- vector("list", n)
      hasError <- FALSE
      formatError <- function(threadNumber, error, args) {
        sprintf("Thread %s returns error: \"%s\" when using argument(s): %s",
                threadNumber,
                gsub("\n", "\\n", gsub("\t", "\\t", error)),
                gsub("\n", "\\n", gsub("\t", "\\t", paste(args, collapse = ","))))
      }
      for (i in 1:n) {
        d <- snow::recvOneResult(cluster)
        if (inherits(d$value, "try-error")) {
          val[d$tag] <- NULL
          errorMessage <- formatError(d$node, d$value, c(list(x[[d$tag]]), list(...)))
          if (stopOnError) {
          stop(errorMessage)
          } else {
          ParallelLogger::logError(errorMessage)
          hasError <- TRUE
          }
        }
        if (progressBar)
          setTxtProgressBar(pb, i/n)
        j <- i + min(n, p)
        if (j <= n) {
          snow::sendCall(cluster[[d$node]], fun, c(list(x[[j]]), list(...)), tag = j)
        }
        val[d$tag] <- list(d$value)
      }
      if (progressBar) {
        close(pb)
      }
      if (hasError) {
        message <- paste0("Error(s) when calling function '",
                          substitute(fun, parent.frame(1)),
                          "', see earlier messages for details")
        stop(message)
      }
      return(val)
    }
  }
}
