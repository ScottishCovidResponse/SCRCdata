#' get_max_date
#'
#' @param filepath filepath
#' @param components components
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
