% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/modelling.R
\name{crf}
\alias{crf}
\title{Linear-chain Conditional Random Field}
\usage{
crf(
  x,
  y,
  group,
  method = c("lbfgs", "l2sgd", "averaged-perceptron", "passive-aggressive", "arow"),
  options = crf_options(method)$default,
  embeddings,
  file = "annotator.crfsuite",
  trace = FALSE,
  FUN = identity,
  ...
)
}
\arguments{
\item{x}{a character matrix of data containing attributes about the label sequence \code{y} or an object which can be coerced to a character matrix.
It is important to note that an attribute which has the same value in a different column is considered the same.}

\item{y}{a character vector with the sequence of labels to model}

\item{group}{an integer or character vector of the same length as \code{y} indicating the group the sequence \code{y} belongs to (e.g. a document or sentence identifier)}

\item{method}{character string with the type of training method. Either one of:
\itemize{
 \item{lbfgs: }{L-BFGS with L1/L2 regularization}
 \item{l2sgd: }{SGD with L2-regularization}
 \item{averaged-perceptron: }{Averaged Perceptron}
 \item{passive-aggressive: }{Passive Aggressive}
 \item{arow: }{Adaptive Regularization of Weights (AROW)}
}}

\item{options}{a list of options to provide to the training algorithm. See \code{\link{crf_options}} for possible options and the example below on how to provide them.}

\item{embeddings}{a matrix with the same number of rows as \code{x} and in the same order with numeric information used in model building (experimental)}

\item{file}{a character string with the path to the file on disk where the CRF model will be stored.}

\item{trace}{a logical indicating to show the trace of the training output. Defaults to \code{FALSE}.}

\item{FUN}{a function which can be applied on raw text in order to obtain the attribute matrix used in \code{predict.crf}. Currently not used yet.}

\item{...}{arguments to FUN. Currently not used yet.}
}
\value{
an object of class crf which is a list with elements
\itemize{
 \item{method: }{The training method}
 \item{type: }{The type of graphical model which is always set crf1d: Linear-chain (first-order Markov) CRF}
 \item{labels: }{The training labels}
 \item{options: }{A data.frame with the training options provided to the algorithm}
 \item{file_model: }{The path where the CRF model is stored}
 \item{attribute_names: }{The column names of \code{x}}
 \item{log: }{The training log of the algorithm}
 \item{FUN: }{The argument passed on to FUN}
 \item{ldots: }{A list with the arguments passed on to ...}
}
}
\description{
Fits a Linear-chain (first-order Markov) CRF on the provided label sequence and saves it on disk in order to do sequence labelling.
}
\examples{
## Download modeldata (conll 2002 shared task in Dutch)
\donttest{
x         <- ner_download_modeldata("conll2002-nl")
}
# for CRAN only - word on a subset of the data
x <- ner_download_modeldata("conll2002-nl", docs = 10)
if(is.data.frame(x)){
  ##
  ## Build Named Entity Recognition model on conll2002-nl
  ##
  x$pos     <- txt_sprintf("Parts of Speech: \%s", x$pos)
  x$token   <- txt_sprintf("Token: \%s", x$token)
  crf_train <- subset(x, data == "ned.train")
  crf_test  <- subset(x, data == "testa")

  model <- crf(y = crf_train$label, 
               x = crf_train[, c("token", "pos")], 
               group = crf_train$doc_id, 
               method = "lbfgs", 
               options = list(max_iterations = 3, feature.minfreq = 5, 
                              c1 = 0, c2 = 1)) 
  model
  weights <- coefficients(model)
  head(weights$states, n = 20)
  head(weights$transitions, n = 20)
  stats   <- summary(model, "modeldetails.txt")
  stats
  plot(stats$iterations$loss)

  ## Use the CRF model to label a sequence
  scores <- predict(model, 
                    newdata = crf_test[, c("token", "pos")], 
                    group = crf_test$doc_id)
  head(scores)
  crf_test$label <- scores$label
  
  ## cleanup for CRAN
  if(file.exists(model$file_model)) file.remove(model$file_model)
  if(file.exists("modeldetails.txt")) file.remove("modeldetails.txt")
}
\donttest{
##
## More detailed example where text data was annotated with the webapp in the package
## This data is joined with a tokenised dataset to construct the training data which
## is further enriched with attributes of upos/lemma in the neighbourhood
##
\dontshow{if(require(udpipe))\{}
library(udpipe)
data(airbnb_chunks, package = "crfsuite")
udmodel       <- udpipe_download_model("dutch-lassysmall")
if(!udmodel$download_failed){
udmodel       <- udpipe_load_model(udmodel$file_model)
airbnb_tokens <- udpipe(x = unique(airbnb_chunks[, c("doc_id", "text")]), 
                        object = udmodel)
x <- merge(airbnb_chunks, airbnb_tokens)
x <- crf_cbind_attributes(x, terms = c("upos", "lemma"), by = "doc_id")
model <- crf(y = x$chunk_entity, 
             x = x[, grep("upos|lemma", colnames(x), value = TRUE)], 
             group = x$doc_id, 
             method = "lbfgs", options = list(max_iterations = 5)) 
stats <- summary(model)
stats
plot(stats$iterations$loss, type = "b", xlab = "Iteration", ylab = "Loss")
scores <- predict(model, 
                  newdata = x[, grep("upos|lemma", colnames(x))], 
                  group = x$doc_id)
head(scores)
}
\dontshow{\} # End of main if statement running only if the required packages are installed}
}
}
\references{
More details about this model is available at \url{http://www.chokkan.org/software/crfsuite/}.
}
\seealso{
\code{\link{predict.crf}}
}
