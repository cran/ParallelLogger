## ----echo = FALSE, message = FALSE, warning = FALSE, results = "hide"---------
!is.null(knitr::opts_knit$get("out.format"))

## ----eval=FALSE---------------------------------------------------------------
#  logger <- createLogger(name = "SIMPLE",
#                         threshold = "INFO",
#                         appenders = list(createConsoleAppender(layout = layoutTimestamp)))
#  
#  registerLogger(logger)
#  
#  logTrace("This event is below the threshold (INFO)")
#  
#  logInfo("Hello world")

## ----echo=FALSE---------------------------------------------------------------
out <- "Hello world
2021-02-23 09:04:06 Hello world"
writeLines(out)

## ----eval=FALSE---------------------------------------------------------------
#  clearLoggers()
#  
#  logger <- createLogger(name = "SIMPLE",
#                         threshold = "INFO",
#                         appenders = list(createConsoleAppender(layout = layoutTimestamp)))
#  
#  registerLogger(logger)
#  
#  logInfo("Hello world")

## ----echo=FALSE---------------------------------------------------------------
writeLines("2021-02-23 09:04:06 Hello world")

## ----eval=FALSE---------------------------------------------------------------
#  addDefaultConsoleLogger()

## ----eval=FALSE---------------------------------------------------------------
#  registerLogger(createLogger(name = "DEFAULT_CONSOLE_LOGGER",
#                              threshold = "INFO",
#                              appenders = list(createConsoleAppender(layout = layoutSimple))))

## ----eval=FALSE---------------------------------------------------------------
#  logFileName <- "log.txt"
#  
#  logger <- createLogger(name = "PARALLEL",
#                         threshold = "TRACE",
#                         appenders = list(createFileAppender(layout = layoutParallel,
#                                                             fileName = logFileName)))
#  registerLogger(logger)
#  
#  logTrace("Executed this line")
#  
#  logDebug("There are ",  length(getLoggers()), " loggers")
#  
#  logInfo("Hello world")

## ----echo=FALSE---------------------------------------------------------------
writeLines("2021-02-23 09:04:06 Hello world")

## ----eval=FALSE---------------------------------------------------------------
#  writeLines(readChar(logFileName, file.info(logFileName)$size))

## ----echo=FALSE---------------------------------------------------------------
out <- "2021-02-23 09:04:06\t[Main thread]\tTRACE\tevaluate\ttiming_fn\tExecuted this line
2021-02-23 09:04:06\t[Main thread]\tDEBUG\tevaluate\ttiming_fn\tThere are 2 loggers
2021-02-23 09:04:06\t[Main thread]\tINFO\tevaluate\ttiming_fn\tHello world"
writeLines(out)

## ----eval=FALSE---------------------------------------------------------------
#  unlink(logFileName)

## ----eval=FALSE---------------------------------------------------------------
#  addDefaultFileLogger(logFileName)

## ----eval=FALSE---------------------------------------------------------------
#  registerLogger(createLogger(name = "DEFAULT_FILE_LOGGER",
#                              threshold = "TRACE",
#                              appenders = list(createFileAppender(layout = layoutParallel,
#                                                                  fileName = logFileName))))

## ----eval=FALSE---------------------------------------------------------------
#  addDefaultErrorReportLogger()

## ----eval=FALSE---------------------------------------------------------------
#  fileName <- file.path(getwd(), "errorReportR.txt")
#  
#  registerLogger(createLogger(name = "DEFAULT_ERRORREPORT_LOGGER",
#                              threshold = "FATAL",
#                              appenders = list(createFileAppender(layout = layoutErrorReport,
#                                                                  fileName = fileName,
#                                                                  overwrite = TRUE,
#                                                                  expirationTime = 60))))

## ----eval=FALSE---------------------------------------------------------------
#  mailSettings <- list(from = "someone@gmail.com",
#  to = c("someone_else@gmail.com"),
#  smtp = list(host.name = "smtp.gmail.com",
#  port = 465,
#  user.name = "someone@gmail.com",
#  passwd = "super_secret!",
#  ssl = TRUE),
#  authenticate = TRUE,
#  send = TRUE)
#  
#  logger <- createLogger(name = "EMAIL",
#  threshold = "FATAL",
#  appenders = list(createEmailAppender(layout = layoutEmail,
#  mailSettings = mailSettings)))
#  registerLogger(logger)
#  
#  logFatal("No more data to process")

## ----eval=FALSE---------------------------------------------------------------
#  addDefaultEmailLogger(mailSettings)

## ----eval=FALSE---------------------------------------------------------------
#  registerLogger(createLogger(name = "DEFAULT_EMAIL_LOGGER",
#  threshold = "FATAL",
#  appenders = list(createEmailAppender(layout = layoutEmail,
#  mailSettings = mailSettings))))

## ----eval=FALSE---------------------------------------------------------------
#  clearLoggers()
#  addDefaultFileLogger(logFileName)
#  
#  message("Hello")
#  
#  warning("Danger!")
#  
#  # This throws a warning:
#  as.numeric('a')
#  
#  # This throws an error:
#  a <- b
#  
#  writeLines(readChar(logFileName, file.info(logFileName)$size))

## ----echo=FALSE---------------------------------------------------------------
out <- "2021-02-23 09:04:09\t[Main thread]\tWARN\tevaluate\ttiming_fn\tHello
2021-02-23 09:04:09\t[Main thread]\tWARN\tevaluate\ttiming_fn\tDanger!
2021-02-23 09:04:09\t[Main thread]\tWARN\tevaluate\ttiming_fn\tWarning: NAs introduced by coercion
2021-02-23 09:04:09\t[Main thread]\tFATAL\tevaluate\ttiming_fn\tError: object a not found"
writeLines(out)

## ----eval=FALSE---------------------------------------------------------------
#  clearLoggers() # Clean up the loggers from the previous example
#  
#  addDefaultFileLogger(logFileName)
#  
#  cluster <- makeCluster(3)
#  
#  fun <- function(x) {
#    ParallelLogger::logInfo("The value of x is ", x)
#    # Do something
#    if (x == 6)
#      ParallelLogger::logDebug("X equals 6")
#    return(NULL)
#  }
#  
#  dummy <- clusterApply(cluster, 1:10, fun, progressBar = FALSE)
#  
#  stopCluster(cluster)
#  
#  writeLines(readChar(logFileName, file.info(logFileName)$size))

## ----echo=FALSE---------------------------------------------------------------
out <- "2021-02-23 09:04:09\t[Main thread]\tTRACE\tevaluate timing_fn Initiating cluster with 3 threads
2021-02-23 09:04:13\t[Thread 1]\tTRACE\t\tThread 1 initiated
2021-02-23 09:04:13\t[Thread 2]\tTRACE\t\tThread 2 initiated
2021-02-23 09:04:13\t[Thread 3]\tTRACE\t\tThread 3 initiated
2021-02-23 09:04:13\t[Thread 1]\tINFO\t\tThe value of x is 1
2021-02-23 09:04:13\t[Thread 2]\tINFO\t\tThe value of x is 2
2021-02-23 09:04:13\t[Thread 1]\tINFO\t\tThe value of x is 4
2021-02-23 09:04:13\t[Thread 2]\tINFO\t\tThe value of x is 5
2021-02-23 09:04:13\t[Thread 3]\tINFO\t\tThe value of x is 6
2021-02-23 09:04:13\t[Thread 1]\tINFO\t\tThe value of x is 7
2021-02-23 09:04:13\t[Thread 2]\tINFO\t\tThe value of x is 8
2021-02-23 09:04:13\t[Thread 1]\tINFO\t\tThe value of x is 9
2021-02-23 09:04:13\t[Thread 2]\tINFO\t\tThe value of x is 10
2021-02-23 09:04:13\t[Main thread]\tTRACE\tevaluate\ttiming_fn Stopping cluster
2021-02-23 09:04:13\t[Thread 1]\tTRACE\t\tThread 1 terminated
2021-02-23 09:04:13\t[Thread 3]\tTRACE\t\tThread 3 terminated
2021-02-23 09:04:13\t[Thread 2]\tTRACE\t\tThread 2 terminated"
writeLines(out)

## ----eval=FALSE---------------------------------------------------------------
#  subSubTask <- function() {
#    addDefaultFileLogger("subSubTaskLog.txt")
#    # do something
#  }
#  
#  subTask <- function() {
#    addDefaultFileLogger("subTaskLog.txt")
#    # do something
#    subSubTask()
#  }
#  
#  mainTask <- function() {
#    addDefaultFileLogger("mainTaskLog.txt")
#    # do something
#    subTask()
#  }

## ----eval=FALSE---------------------------------------------------------------
#  subSubTask <- function() {
#    # do something
#  }
#  
#  subTask <- function() {
#    # do something
#    subSubTask()
#  }
#  
#  mainTask <- function() {
#    addDefaultFileLogger("log.txt")
#    # do something
#    subTask()
#  }

## ----eval=FALSE---------------------------------------------------------------
#  mainTask <- function() {
#    addDefaultFileLogger("log.txt")
#    on.exit(unregisterLogger("DEFAULT_FILE_LOGGER"))
#    # do something
#  }

## ----eval=FALSE---------------------------------------------------------------
#  launchLogViewer(logFileName)

