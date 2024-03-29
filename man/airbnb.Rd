% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{airbnb}
\alias{airbnb}
\title{Dutch reviews of AirBnB customers on Brussels address locations available at www.insideairbnb.com}
\source{
\url{http://insideairbnb.com/brussels}: information of 2015-10-03
}
\description{
The data contains 500 reviews in Dutch of people who visited an AirBnB appartment in Brussels. \cr
The data frame contains the fields 
\itemize{
 \item{doc_id: }{a unique identifier of the review}
 \item{listing_id: }{the airbnb address identifier}
 \item{text: }{text with the feedback of a customer on his visit in the AirBnB appartment}
}
}
\examples{
data(airbnb)
str(airbnb)
head(airbnb)
}
\seealso{
\code{\link{airbnb_chunks}}
}
