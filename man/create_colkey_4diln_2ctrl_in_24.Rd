% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plate_functions.R
\name{create_colkey_4diln_2ctrl_in_24}
\alias{create_colkey_4diln_2ctrl_in_24}
\title{Create a 4-dilution column key for primer calibration}
\usage{
create_colkey_4diln_2ctrl_in_24(
  dilution = c(5^(0:-3), 1, 1),
  dilution_nice = c("1x", "5x", "25x", "125x", "-RT", "NT"),
  prep_type = c(rep("+RT", 4), "-RT", "NT"),
  biol_rep = rep(c("A", "B"), each = 12, length.out = 24),
  tech_rep = rep(1:2, each = 6, length.out = 24)
)
}
\arguments{
\item{dilution}{Numeric vector of length 6 describing sample dilutions}

\item{dilution_nice}{Character vector of length 6 with nice labels for sample
dilutions}

\item{prep_type}{Character vector of length 6 describing type of sample (+RT,
-RT, NT)}

\item{biol_rep}{Character vector of length 6 describing biological replicates}

\item{tech_rep}{Character vector of length 6 describing technical replicates}
}
\value{
tibble (data frame) with 24 rows, and columns well_col, dilution,
  dilution_nice, prep_type, biol_rep, tech_rep.
}
\description{
Creates a 24-column key for primer calibration, with 2x biol_reps and 2x
tech_reps, and 5-fold dilution until 5^4 of +RT; then -RT (no reverse
transcriptase), NT (no template) negative controls. That is a total of 6
versions of each sample replicate.
}
\examples{
create_colkey_4diln_2ctrl_in_24()
}
\seealso{
Other plate creation functions: 
\code{\link{create_blank_plate}()},
\code{\link{create_colkey_6_in_24}()},
\code{\link{create_colkey_6diln_2ctrl_in_24}()},
\code{\link{create_rowkey_4_in_16}()},
\code{\link{create_rowkey_8_in_16_plain}()},
\code{\link{display_plate}()},
\code{\link{display_plate_qpcr}()},
\code{\link{display_plate_value}()},
\code{\link{label_plate_rowcol}()},
\code{\link{make_row_names_echo1536}()},
\code{\link{make_row_names_lc1536}()}
}
\concept{plate creation functions}
