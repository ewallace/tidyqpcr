% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/amp_melt_curve_functions.R
\name{calculate_drdt_plate}
\alias{calculate_drdt_plate}
\title{Calculate dR/dT of melt curves for of every well in a plate.}
\usage{
calculate_drdt_plate(platemelt, method = "spline", ...)
}
\arguments{
\item{platemelt}{data frame describing melt curves, including variables
well, temperature, fluor_raw (raw fluorescence value).}

\item{method}{to use for smoothing:

  "spline" default, uses smoothing spline stats::smooth.spline.

  "diff" base::diff for lagged difference}

\item{...}{other arguments to pass to smoothing method.}
}
\value{
platemelt with additional column dRdT.
}
\description{
dR/dT, the derivative of the melt curve (of fluorescence signal R vs
temperature T), has a maximum at the melting temperature Tm. A single peak in
this suggests a single-length PCR product is present in the well.
}
\details{
Note that this function does not group by plate, only by well.
The function will give strange results if you pass it data from 
more than one plate. Avoid this by analysing one plate at a time.
}
\examples{
# create simple curve
# create simple dataset of raw fluorescence with two samples
temp_tibble <- tibble(sample_id = rep(c("S1", "S2"), each = 10),
                          target_id = "T1",
                          well_row = "A",
                          well_col = rep(c(1, 2), each = 10),
                          well = rep(c("A1", "A2"), each = 10),
                          temperature = rep(56:65,2),
                          fluor_raw = c(1:10, 6:15))

# calculate drdt of all melt curves
#----- use case 1 : using splines
temp_tibble |>
    calculate_drdt_plate()

# optional arguments are passed to smooth.splines function
temp_tibble |>
    calculate_drdt_plate(spar = 0.5)

#----- use case 2 : using difference between adjacent points
temp_tibble |>
    calculate_drdt_plate(method = "diff")

}
\seealso{
Other melt_curve_functions: 
\code{\link{calculate_dydx}()}
}
\concept{melt_curve_functions}
