% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plate_functions.R
\name{create_rowkey_8_in_16_plain}
\alias{create_rowkey_8_in_16_plain}
\title{Create a plain 8-value, 16-row key for plates}
\usage{
create_rowkey_8_in_16_plain(...)
}
\arguments{
\item{...}{Vectors of length 8 describing well contents, e.g. sample or
probe.}
}
\value{
tibble (data frame) with 16 rows, and variables well_col, and
  supplied values.
}
\description{
Create a 16-row key with 8 values repeated over 16 plate rows. No other
information is included by default, hence "plain".
}
\details{
This helps to create plate layouts with standard designs.
}
\examples{
create_rowkey_8_in_16_plain(sample_id=c("me","you","them","him",
                                   "her","dog","cat","monkey"))
}
\seealso{
Other plate creation functions: 
\code{\link{create_blank_plate}()},
\code{\link{create_colkey_4diln_2ctrl_in_24}()},
\code{\link{create_colkey_6_in_24}()},
\code{\link{create_colkey_6diln_2ctrl_in_24}()},
\code{\link{create_rowkey_4_in_16}()},
\code{\link{display_plate}()},
\code{\link{display_plate_qpcr}()},
\code{\link{display_plate_value}()},
\code{\link{label_plate_rowcol}()},
\code{\link{make_row_names_echo1536}()},
\code{\link{make_row_names_lc1536}()}
}
\concept{plate creation functions}
