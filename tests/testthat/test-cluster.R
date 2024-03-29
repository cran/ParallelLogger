library("testthat")

test_that("Computation across 3 threads", {
  fun <- function(x) {
    return(x^2)
  }

  cluster <- makeCluster(numberOfThreads = 3)
  x <- clusterApply(cluster, 1:10, fun)
  stopCluster(cluster)

  expect_equal(length(x), 10)
  expect_equal(sum(unlist(x)), sum((1:10)^2))
})

test_that("Create a cluster of nodes for parallel computation", {
  f <- function() {
    "test"
  }
  ParallelLogger:::registerDefaultHandlers()

  summary(f())

  cluster <- ParallelLogger::makeCluster(2)
  res <- ParallelLogger::clusterApply(cluster, f(), summary)
  ParallelLogger::stopCluster(cluster)

  testthat::expect_equal(length(res), 1)
})

test_that("makeCluster", {
  cluster <- snow::makeCluster(2, type = "SOCK")
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
  testthat::expect_gt(length(cluster), expected = 1)

  for (i in 1:length(cluster)) {
    res <- snow::sendCall(cluster[[i]], logThreadStart, list(loggers = loggers, threadNumber = i))
    testthat::expect_equal(res, NULL)
  }

  ParallelLogger::clearLoggers()
})

test_that("Test require package", {
  tryCatch(
    expr = {
      package <- "test invalid pkg for failing"
      cluster <- ParallelLogger::makeCluster(1)

      res <- capture.output(capture.output(out <- ParallelLogger::clusterRequire(cluster, package), type = "message"), type = "output")

      expectLoading <- sprintf("Loading required package: %s", package)
      expectWarning <- sprintf("Warning: there is no package called ‘%s’", package)

      testthat::expect_equal(out, FALSE)
      testthat::expect_true(grepl(expectLoading, res[1]))
      testthat::expect_true(grepl(expectWarning, res[2]))
    },
    error = function(e) {
    },
    warning = function(w) {

    },
    finally = {

    }
  )
})

test_that("Check andromedaTempFolder", {
  check <- "c:\\test"
  ParallelLogger:::doSetAndromedaTempFolder(check)
  testthat::expect_true(!is.null(getOption("andromedaTempFolder")))
  testthat::expect_equal(getOption("andromedaTempFolder"), check)
})
