% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/qr_js.R
\name{qr_parse_js_}
\alias{qr_parse_js_}
\title{Parse multiple QR objects into a single dataframe.}
\usage{
qr_parse_js_(lst)
}
\arguments{
\item{lst}{A list returned by \code{\link{qr_scan_js_from_corners}}, with dataframe elements \strong{chunks} and \strong{location}.}
}
\value{
If not empty, a list with two dataframe elements, \strong{values} and \strong{points}, identifying all QR codes from an image.
}
\description{
Parse multiple QR objects into a single dataframe.
}
\keyword{This}
\keyword{\code{\link{qr_scan_cpp}}.}
\keyword{\code{\link{qr_scan_js_from_corners}}}
\keyword{\code{\link{qr_scan}},}
\keyword{\code{rcpp_qr_scan_array}}
\keyword{a}
\keyword{analogous}
\keyword{by}
\keyword{called}
\keyword{combine}
\keyword{dataframe,}
\keyword{from}
\keyword{function}
\keyword{internal}
\keyword{into}
\keyword{is}
\keyword{multiple}
\keyword{objects}
\keyword{only}
\keyword{or}
\keyword{output}
\keyword{returned}
\keyword{single}
\keyword{the}
\keyword{to}
\keyword{usually}