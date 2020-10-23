#' get_max_date
#'
#' @param filepath
#' @param components
#'
#' @return
#'
#' @export
#'
get_max_date <- function(filepath, components) {
  lapply(seq_along(components), function(x) {
    read_array(filepath = filepath,
      component = components[x]) %>%
      colnames() %>%
      max()
  }) %>%
    unlist() %>%
    max()
}
