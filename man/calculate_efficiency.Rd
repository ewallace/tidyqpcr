% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calculate_efficiency.R
\name{calculate_efficiency}
\alias{calculate_efficiency}
\title{Calibrate primer sets / probes by calculating detection efficiency and
R squared}
\usage{
calculate_efficiency(cq_df_1, formula = cq ~ log2(dilution) + biol_rep)
}
\arguments{
\item{cq_df_1}{data frame with cq (quantification cycle) data,
1 row per well.

Must have columns cq, dilution.

Assumes data are only for 1 probe/primer set/target_id, i.e. all values in
cq_df_1 are fit with the same slope.}

\item{formula}{formula to use for log-log regression fit.

Default value assumes multiple biological replicates,
cq ~ log2(dilution) + biol_rep.

If only a single Biological Replicate, change to cq ~ log2(dilution).}
}
\value{
data frame with 1 single row, and columns:
efficiency, efficiency.sd, r.squared.
}
\description{
Note efficiency is given in ratio, not per cent; multiply by 100 for that.
}
\examples{
# create simple dilution dataset
dilution_tibble <- tibble(dilution = rep(c(1, 0.1, 0.001, 0.0001), 2),
                     cq = c(1, 3, 4, 6,
                            4, 5, 6, 7),
                     biol_rep = rep(c(1,2), each = 4),
                     target_id = "T1")
                     
# calculate primer efficiency

#----- use case 1: include difference across replicates in model
dilution_tibble |>
    calculate_efficiency()

#----- use case 2: ignore difference across replicates
dilution_tibble |>
    calculate_efficiency(formula = cq ~ log2(dilution))

}
\seealso{
calculate_efficiency_bytargetid
}
