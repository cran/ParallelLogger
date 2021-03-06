% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Cluster.R
\name{stopCluster}
\alias{stopCluster}
\title{Stop the cluster}
\usage{
stopCluster(cluster)
}
\arguments{
\item{cluster}{The cluster to stop}
}
\description{
Stop the cluster
}
\examples{
fun <- function(x) {
  return (x^2)
}

cluster <- makeCluster(numberOfThreads = 3)
clusterApply(cluster, 1:10, fun)
stopCluster(cluster)
}
