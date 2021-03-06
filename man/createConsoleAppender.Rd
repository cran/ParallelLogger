% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Appenders.R
\name{createConsoleAppender}
\alias{createConsoleAppender}
\title{Create console appender}
\usage{
createConsoleAppender(layout = layoutSimple)
}
\arguments{
\item{layout}{The layout to be used by the appender.}
}
\description{
Create console appender
}
\details{
Creates an appender that will write to the console.
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
