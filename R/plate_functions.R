#' Create a blank plate template as a tibble (with helper functions for common plate sizes)
#'
#' For more help, examples and explanations, see the plate setup vignette:
#' \code{vignette("platesetup_vignette", package = "tidyqpcr")}
#'
#' @param well_row Vector of Row labels, usually LETTERS
#' @param well_col Vector of Column labels, usually numbers
#' @return tibble (data frame) with columns well_row, well_col, well. This
#'   contains all pairwise combinations of well_row and well_col, as well as
#'   individual well names. Both well_row and well_col are coerced to factors
#'   (even if well_col is supplied as numbers), to ensure order is consistent.
#'
#'   However, well is a character vector as that is the default behaviour of
#'   "unite", and display order doesn't matter.
#'
#'   Default value describes a full 384-well plate.
#'
#' @examples
#' create_blank_plate(well_row=LETTERS[1:2],well_col=1:3)
#' 
#' create_blank_plate_96well()
#' 
#' create_blank_plate_1536well()
#' 
#' # create blank 96-well plate with empty edge wells
#' 
#' create_blank_plate(well_row=LETTERS[2:7], well_col=2:11)
#' 
#' # create blank 1536-well plate with empty edge wells
#' 
#' full_plate_row_names <- make_row_names_lc1536()
#' 
#' create_blank_plate(well_row=full_plate_row_names[2:31], well_col=2:47)
#'
#' @family plate creation functions
#'
#' @export
#' @importFrom tibble tibble as_tibble
#' @importFrom forcats as_factor
#'
create_blank_plate <- function(well_row = LETTERS[1:16], well_col = 1:24) {
    tidyr::crossing(well_row = as_factor(well_row),
                    well_col = as_factor(well_col)) |>
        as_tibble() |>
        tidyr::unite("well", well_row, well_col, 
                     sep = "", remove = FALSE)
}

#' @describeIn create_blank_plate create blank 96-well plate
#' @export
#'
create_blank_plate_96well <- function() {
    create_blank_plate(well_row = LETTERS[1:8], well_col = 1:12)
}

#' Generates row names for the Roche Lightcycler (tm) 1536-well plates
#' 
#' Creates a vector containing 36 row names according to the labelling system 
#' used by the Roche Lightcycler (tm)
#' 
#' @return Vector of row names: Aa,Ab,Ac,Ad,Ba,...,Hd.
#' 
#' @family plate creation functions
#' 
#' @examples
#' make_row_names_lc1536()
#' 
#' @export
#'
make_row_names_lc1536 <- function() {
    paste0(rep(LETTERS[1:8], each = 4), letters[1:4])
}

#' Generates row names for the Labcyte Echo 1536-well plates 
#' 
#' Creates a vector containing 36 row names according to the 
#' labelling system used by the Labcyte Echo
#' 
#' @return Vector of row names: A,B,...,Z,AA,AB,...,AF.
#' 
#' @family plate creation functions
#' 
#' @examples
#' make_row_names_echo1536()
#' 
#' @export
#'
make_row_names_echo1536 <- function() {
    c(LETTERS[1:26], paste0("A", LETTERS[1:6]))
}

#' @describeIn create_blank_plate create blank 1536-well plate
#' @export
#'
create_blank_plate_1536well <- function(
    well_row = make_row_names_lc1536(),
    well_col = 1:48) {
    create_blank_plate(well_row, well_col)
}

#' Create a 6-value, 24-column key for plates
#'
#' Create a 24-column key with 6 values repeated over 24 plate columns.
#' Each of the 6 values is repeated over 3x +RT Techreps and 1x -RT.
#' 
#' This helps to create plate layouts with standard designs.
#'
#' @param ... Vectors of length 6 describing well contents,
#' e.g. sample_id or target_id
#' @return tibble (data frame) with 24 rows, and columns
#' well_col, prep_type, tech_rep, and supplied values.
#'
#' @examples
#' create_colkey_6_in_24(sample_id=LETTERS[1:6])
#' @family plate creation functions
#'
#' @export
#' @importFrom tibble tibble as_tibble
#'
create_colkey_6_in_24 <- function(...) {
    colkey <- tibble(well_col  = factor(1:24),
                     prep_type = as_factor(c(rep("+RT", 18), rep("-RT", 6))),
                     tech_rep  = as_factor(rep(c(1, 2, 3, 1), each = 6))
                     )
    if (!missing(...)) {
        pieces6 <- list(...) |> as_tibble()
        assertthat::assert_that(nrow(pieces6) == 6, 
                                msg = "Some input data is not of length 6")
        pieces24 <- dplyr::bind_rows(pieces6, pieces6, pieces6, pieces6)
        colkey <- dplyr::bind_cols(colkey, pieces24)
    }
    return(colkey)
}

#' Create a 4-dilution column key for primer calibration
#'
#' Creates a 24-column key for primer calibration, with 2x biol_reps and 2x
#' tech_reps, and 5-fold dilution until 5^4 of +RT; then -RT (no reverse
#' transcriptase), NT (no template) negative controls. That is a total of 6
#' versions of each sample replicate.
#'
#' @param dilution Numeric vector of length 6 describing sample dilutions
#' @param dilution_nice Character vector of length 6 with nice labels for sample
#'   dilutions
#' @param prep_type Character vector of length 6 describing type of sample (+RT,
#'   -RT, NT)
#' @param biol_rep Character vector of length 6 describing biological replicates
#' @param tech_rep Character vector of length 6 describing technical replicates
#' @return tibble (data frame) with 24 rows, and columns well_col, dilution,
#'   dilution_nice, prep_type, biol_rep, tech_rep.
#' @examples
#' create_colkey_4diln_2ctrl_in_24()
#' @family plate creation functions
#'
#' @export
#' @importFrom tibble tibble
#' @importFrom forcats as_factor
#'
create_colkey_4diln_2ctrl_in_24 <- function(
                     dilution      = c(5 ^ (0:-3), 1, 1),
                     dilution_nice = c("1x", "5x", "25x", "125x", "-RT", "NT"),
                     prep_type     = c(rep("+RT", 4), "-RT", "NT"),
                     biol_rep      = rep(c("A", "B"), each = 12,
                                        length.out = 24),
                     tech_rep      = rep(1:2, each = 6,
                                        length.out = 24)
                     ) {
    tibble(well_col = factor(1:24),
           dilution = rep(dilution, 4),
           dilution_nice = rep(dilution_nice, 4),
           prep_type = as_factor(rep(prep_type, 4)),
           biol_rep = as_factor(biol_rep),
           tech_rep = as_factor(tech_rep)
    )
}

#' Create a 6-dilution column key for primer calibration
#'
#' Creates a 24-column key for primer calibration, with 1x biol_reps and 3x
#' tech_reps, and 5-fold dilution until 5^6 of +RT; then -RT (no reverse
#' transcriptase), NT (no template) negative controls. That is a total of 8
#' versions of each replicate.
#'
#' @param dilution Numeric vector of length 8 describing sample dilutions
#' @param dilution_nice Character vector of length 8 with nice labels for sample
#'   dilutions
#' @param prep_type Character vector of length 8 describing type of sample (+RT,
#'   -RT, NT)
#' @param tech_rep Character vector of length 8 describing technical replicates
#' @return tibble (data frame) with 24 rows, and variables well_col, dilution,
#'   dilution_nice, prep_type, biol_rep, tech_rep.
#' @examples
#' create_colkey_6diln_2ctrl_in_24()
#' @family plate creation functions
#'
#' @export
#' @importFrom tibble tibble
#' @importFrom forcats as_factor
#'
create_colkey_6diln_2ctrl_in_24 <- function(
                     dilution = c(5 ^ (0:-5), 1, 1),
                     dilution_nice = c("1x", "5x", "25x", "125x",
                                    "625x", "3125x", "-RT", "NT"),
                     prep_type=c(rep("+RT", 6), "-RT", "NT"),
                     tech_rep = rep(1:3, each = 8, length.out = 24)
                     ) {
    tibble(well_col = factor(1:24),
           dilution = rep(dilution, 3),
           dilution_nice = rep(dilution_nice, 3),
           prep_type = as_factor(rep(prep_type, 3)),
           tech_rep = as_factor(tech_rep))
}

#' Create a 4-value, 16-row key for plates
#'
#' Create a 16-row key with 4 values repeated over 16 plate rows. Each of the 4
#' values is repeated over 3x +RT Techreps and 1x -RT.
#' 
#' This helps to create plate layouts with standard designs.
#'
#' @param ... Vectors of length 4 describing well contents, e.g. sample_id or
#'   target_id
#' @return tibble (data frame) with 16 rows, and variables well_row, prep_type,
#'   tech_rep, and supplied values.
#' @examples
#' create_rowkey_4_in_16(sample_id=c("sheep","goat","cow","chicken"))
#' @family plate creation functions
#'
#' @export
#' @importFrom tibble tibble as_tibble
#' @importFrom forcats as_factor

#'
create_rowkey_4_in_16 <- function(...) {
    rowkey <- tibble(well_row = factor(LETTERS[1:16]),
                     prep_type = as_factor(c(rep("+RT", 12), rep("-RT", 4))),
                     tech_rep = as_factor(rep(c(1, 2, 3, 1), each = 4))
    )
    if (!missing(...)) {
        pieces4 <- list(...) |> as_tibble()
        assertthat::assert_that(nrow(pieces4) == 4, 
                                msg = "Some input data is not of length 4")
        pieces16 <- dplyr::bind_rows(pieces4, pieces4, pieces4, pieces4)
        rowkey <- dplyr::bind_cols(rowkey, pieces16)
    }
    return(rowkey)
}

#' Create a plain 8-value, 16-row key for plates
#'
#' Create a 16-row key with 8 values repeated over 16 plate rows. No other
#' information is included by default, hence "plain".
#' 
#' This helps to create plate layouts with standard designs.
#'
#' @param ... Vectors of length 8 describing well contents, e.g. sample or
#'   probe.
#' @return tibble (data frame) with 16 rows, and variables well_col, and
#'   supplied values.
#' @examples
#' create_rowkey_8_in_16_plain(sample_id=c("me","you","them","him",
#'                                    "her","dog","cat","monkey"))
#' @family plate creation functions
#'
#' @export
#' @importFrom tibble tibble
#'
create_rowkey_8_in_16_plain <- function(...) {
    rowkey <- tibble(well_row = factor(LETTERS[1:16]))
    if (!missing(...)) {
        pieces8 <- list(...) |> as_tibble()
        assertthat::assert_that(nrow(pieces8) == 8, 
                                msg = "Some input data is not of length 8")
        pieces16 <- dplyr::bind_rows(pieces8, pieces8)
        rowkey <- dplyr::bind_cols(rowkey, pieces16)
    }
    return(rowkey)
}

#' Label a plate with sample and probe information
#'
#' For more help, examples and explanations, see the plate setup vignette:
#' \code{vignette("platesetup_vignette", package = "tidyqpcr")}
#' 
#' For worked examples of tidyqpcr analysis with 384-well plates, see:
#' \code{vignette("calibration_vignette", package = "tidyqpcr")}
#'
#' @param plate tibble (data frame) with variables well_row, well_col, well.
#'   This would usually be produced by create_blank_plate(). It is possible to
#'   include other information in additional variables.
#' @param rowkey tibble (data frame) describing plate rows, with variables
#'   well_row and others.
#' @param colkey tibble (data frame) describing plate columns, with variables
#'   well_col and others.
#' @param coercefactors if TRUE, coerce well_row in rowkey and well_col in
#'   colkey to factors
#'
#' @return tibble (data frame) with variables well_row, well_col, well, and
#'   others.
#'
#'   This tibble contains all combinations of well_row and well_col found in the
#'   input plate, and all information supplied in rowkey and colkey distributed
#'   across every well of the plate. Return plate is ordered by row well_row
#'   then column well_col.
#'
#'   Note this ordering may cause a problem if well_col is supplied as a
#'   character (1,10,11,...), instead of a factor or integer (1,2,3,...). For
#'   this reason, the function by default converts well_row in `rowkey`, and
#'   well_col in `colkey`, to factors, taking factor levels from `plate`, and
#'   messages the user.
#'   
#'   If `plate$well_col` or `plate$well_row` are not factors and coercefactors = TRUE 
#'   label_plate_rowcol will automatically convert them to factors, but will output a 
#'   warning telling users this may lead to unexpected behaviour. 
#'
#'   Other tidyqpcr functions require plate plans to contain variables
#'   sample_id, target_id, and prep_type, so `label_plate_rowcol` will message
#'   if any of these are missing. This is a message, not an error, because these
#'   variables can be added by users later.
#'
#' @examples
#' label_plate_rowcol(plate = create_blank_plate()) # returns blank plate
#' 
#' # label blank 96-well plate with empty edge wells
#' 
#' label_plate_rowcol(plate = create_blank_plate(well_row = LETTERS[2:7], 
#'                                               well_col = 2:11))
#' 
#' # label 96-well plate with sample id in rows
#' 
#' label_plate_rowcol(plate = create_blank_plate(well_row = LETTERS[1:8],
#'                                               well_col = 1:12),
#'                    rowkey = tibble(well_row = LETTERS[1:8],
#'                                    sample_id = paste0("S_",1:8)))
#' 
#' # label fraction of 96-well plate with target id in columns
#' 
#' label_plate_rowcol(plate = create_blank_plate(well_row = LETTERS[1:8],
#'                                               well_col = 1:4),
#'                    colkey = tibble(well_col = 1:4,
#'                                    target_id = paste0("T_",1:4)))
#' 
#' @family plate creation functions
#'
#' @export
#'
#' @importFrom forcats as_factor
#'
label_plate_rowcol <- function(plate,
                               rowkey = NULL,
                               colkey = NULL,
                               coercefactors = TRUE) {
    assertthat::assert_that(
        assertthat::has_name(plate, 
                             c("well_row","well_col")))
    
    if (!is.factor(plate$well_col) & coercefactors){
        warning("plate$well_col is not a factor. Automatically generating plate$well_col factor levels. May lead to incorrect plate plans.")
        plate <- plate |>
            dplyr::mutate(well_col = as_factor(well_col))
    }
    
    if (!is.factor(plate$well_row) & coercefactors){
        warning("plate$well_row is not a factor. Automatically generating plate$well_row factor levels. May lead to incorrect plate plans.")
        plate <- plate |>
            dplyr::mutate(well_row = as_factor(well_row))
    }
    
    if (!is.null(colkey)) {
        assertthat::assert_that(assertthat::has_name(colkey, "well_col"))
        # Note: should this if clause be a freestanding function?
        # coerce_column_to_factor(df, col, warn=FALSE)?
        if (!is.factor(colkey$well_col) & coercefactors) {
            message("coercing well_col to a factor with levels from plate$well_col")
            colkey <- dplyr::mutate(
                colkey,
                well_col = factor(well_col,
                                  levels = levels(plate$well_col))
            )
        }
        plate <- dplyr::left_join(plate, colkey, by = "well_col")
    }
    if (!is.null(rowkey)) {
        assertthat::assert_that(assertthat::has_name(rowkey, "well_row"))
        if (!is.factor(rowkey$well_row) & coercefactors) {
            message("coercing well_row to a factor with levels from plate$well_row")
            rowkey <- dplyr::mutate(
                rowkey,
                well_row = factor(well_row,
                                  levels = levels(plate$well_row))
            )
        }
        plate <- dplyr::left_join(plate, rowkey, by = "well_row")
    }
    # check that plate contains sample_id, target_id, prep_type
    if (! "sample_id" %in% names(plate)) {
        message("plate does not contain variable sample_id")
    }
    if (! "target_id" %in% names(plate)) {
        message("plate does not have variable target_id")
    }
    if (! "prep_type" %in% names(plate)) {
        message("plate does not have variable prep_type")
    }
    return(dplyr::arrange(plate, well_row, well_col))
}


#' Display an empty plate plan which can be populated with 
#' ggplot2 geom elements.
#'
#' @param plate tibble with variables well_col, well_row.
#'
#' @return ggplot object; major output is to plot it
#'
#' @examples
#' library(ggplot2)
#' 
#' # display empty plot of empty plate
#' display_plate(create_blank_plate_96well())
#' 
#' # display wells of empty plate filled by column
#' display_plate(create_blank_plate_96well()) + 
#'   geom_tile(aes(fill = well_col), colour = "black")
#' 
#' # display wells of empty 1536-well plate filled by row
#' display_plate(create_blank_plate_1536well()) + 
#'   geom_tile(aes(fill = well_row), colour = "black")
#' 
#' @family plate creation functions
#'
#' @export
#' @importFrom forcats as_factor
#'
display_plate <- function(plate) {
    assertthat::assert_that(
        assertthat::has_name(plate, 
                             c("well_row","well_col")))
    
    rowlevels <- 
        dplyr::pull(plate, well_row) |>
        as_factor() |>
        levels()

    ggplot2::ggplot(data = plate,
                    ggplot2::aes(x = as_factor(well_col),
                        y = as_factor(well_row))) +
        ggplot2::scale_x_discrete(expand = c(0, 0)) +
        ggplot2::scale_y_discrete(expand = c(0, 0),
                                  limits = rev(rowlevels)) +
        ggplot2::coord_equal() +
        ggplot2::theme_void() +
        ggplot2::theme(axis.text = ggplot2::element_text(angle = 0),
                       panel.grid.major = ggplot2::element_blank(),
                       legend.position = "none",
                       plot.margin = grid::unit(rep(0.01, 4), "npc"),
                       panel.border = ggplot2::element_blank())
}

#' Display qPCR plate plan with sample_id, target_id, prep_type per well
#'
#' @param plate tibble with variables well_col, well_row, sample_id, target_id,
#'   prep_type. Output from label_plate_rowcol.
#'
#' @return ggplot object; major output is to plot it
#'
#' @examples 
#' 
#' 
#' # create basic 6-well plate
#' basic_plate <- 
#'     label_plate_rowcol(plate = create_blank_plate(well_row = LETTERS[1:2],
#'                                                   well_col = 1:3),
#'                        rowkey = tibble(well_row = factor(LETTERS[1:2]),
#'                                        target_id = c("T_A","T_B")),
#'                        colkey = tibble(well_col = factor(1:3),
#'                                        sample_id = c("S_1","S_2", "S_3"),
#'                                        prep_type = "+RT"))
#' 
#' # display basic plate
#' display_plate_qpcr(basic_plate)
#' 
#' # create full 384 well plate
#' full_plate <- label_plate_rowcol(create_blank_plate(), 
#'                                   create_rowkey_8_in_16_plain(target_id = c("T_1", "T_2",
#'                                                                             "T_3", "T_4", 
#'                                                                             "T_5", "T_6",
#'                                                                             "T_7", "T_8")), 
#'                                   create_colkey_6diln_2ctrl_in_24() |> 
#'                                       dplyr::mutate(sample_id = paste0(dilution_nice,
#'                                                                        "_",
#'                                                                        tech_rep)))
#' 
#' # display full plate
#' display_plate_qpcr(full_plate)
#' 
#' # display basic plate, sample_id and prep_type only
#' display_plate_sample_id(basic_plate)
#' 
#'   
#' # display basic plate, target_id only
#' display_plate_target_id(basic_plate)
#' 
#' # change fill of tiles to your needs, for example
#' library(ggplot2)
#' display_plate_target_id(basic_plate) + 
#'   scale_fill_brewer(type = "qual")
#' 
#' @family plate creation functions
#'
#' @export
#' 
#'
display_plate_qpcr <- function(plate) {
    assertthat::assert_that(
        assertthat::has_name(plate, 
                             c("target_id",
                               "sample_id",
                               "prep_type")))
    
    display_plate(plate) +
        ggplot2::geom_tile(ggplot2::aes(fill = target_id), 
                           alpha = 0.3) +
        ggplot2::geom_text(ggplot2::aes(label = 
                                            paste(target_id,
                                                  sample_id,
                                                  prep_type,
                                                  sep = "\n")),
                           size = 2.5, lineheight = 1)
}


#' @describeIn display_plate_qpcr Display qPCR plate plan with sample_id and prep type only
#'
#' @export
#'
display_plate_sample_id <- function(plate) {
    assertthat::assert_that(
        assertthat::has_name(plate, 
                             c("sample_id",
                               "prep_type")))
    
    display_plate(plate) +
        ggplot2::geom_tile(ggplot2::aes(fill = sample_id), 
                           alpha = 0.3) +
        ggplot2::geom_text(ggplot2::aes(label = 
                                            paste(sample_id,
                                                  prep_type,
                                                  sep = "\n")),
                           size = 2.5, lineheight = 1) +
        ggplot2::theme(legend.position = "top")
}

#' @describeIn display_plate_qpcr Display qPCR plate plan with target_id only
#'
#' @export
#'
display_plate_target_id <- function(plate) {
    assertthat::assert_that(
        assertthat::has_name(plate, 
                             "target_id"))
    
    display_plate(plate) +
        ggplot2::geom_tile(ggplot2::aes(fill = target_id), 
                           alpha = 0.3) +
        ggplot2::geom_text(ggplot2::aes(label = target_id),
                           size = 2.5, lineheight = 1) +
        ggplot2::theme(legend.position = "top")
}

#' Display the value of each well across the plate. 
#' 
#' Plots the plate with each well coloured by its value. Example values are Cq, Delta Cq or Delta Delta Cq.
#'
#' For a specific example see the calibration vignette:
#' \code{vignette("calibration_vignette", package = "tidyqpcr")}
#'
#' @param plate tibble with variables well_col, well_row, and the variable to be plotted.
#' 
#' @param value character vector selecting the variable in plate to plot as the well value
#'
#' @return ggplot object; major output is to plot it
#'
#' @examples 
#' library(dplyr)
#' library(ggplot2)
#' 
#' # create 96 well plate with random values
#' plate_randomcq <- create_blank_plate_96well() |>
#'     mutate(cq = runif(96) * 10,
#'            deltacq = runif(96) * 2)
#' 
#' 
#' # display well Cq value across plate
#' display_plate_value(plate_randomcq)
#' 
#' # display well Delta Cq value across plate with red colour pallette
#' display_plate_value(plate_randomcq, value = "deltacq") +   # uses ggplot syntax
#'     scale_fill_gradient(high = "#FF0000") 
#'           
#' 
#' @family plate creation functions
#'
#' @export
#' @importFrom forcats as_factor
#' @importFrom rlang .data
#'
display_plate_value <- function(plate, value = "cq") {
    # check value exists in given plate
    assertthat::assert_that(value %in% names(plate), 
                            msg = paste0(value, " is not the name of a variable in the given plate"))
    
    # check each well has one value only
    unique_well_value <- plate |>
        dplyr::group_by(well) |>
        dplyr::summarise(num_well = dplyr::n()) |>
        dplyr::mutate(not_equal_one = num_well != 1)
    
    assertthat::assert_that(sum(unique_well_value$not_equal_one) == 0, 
                            msg = paste0("Wells do not have unique ", value, " value."))
    
    rowlevels <- 
        dplyr::pull(plate, well_row) |>
        as_factor() |>
        levels()
    
    display_plate(plate = plate) +
        ggplot2::geom_tile(ggplot2::aes(fill = .data[[value]])) +
        ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5),
                       panel.grid.major = ggplot2::element_blank()) +
        ggplot2::labs(title = paste0({{value}}, " values for each well across the plate"))
}
