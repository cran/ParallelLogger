% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Logging.R
\name{registerLogger}
\alias{registerLogger}
\title{Register a logger}
\usage{
registerLogger(logger)
}
\arguments{
\item{logger}{An object of type \code{Logger} as created using the \code{\link{createLogger}}
function.}
}
\description{
Register a logger
}
\details{
Registers a logger as created using the \code{\link{createLogger}} function to the logging system.
}
\examples{
appender <- createConsoleAppender(layout = layoutTimestamp)

logger <- createLogger(name = "SIMPLE",
                       threshold = "INFO",
                       appenders = list(appender))
registerLogger(logger)                      
logTrace("This event is below the threshold (INFO)")
logInfo("Hello world")                       
unregisterLogger("SIMPLE")                     
}
