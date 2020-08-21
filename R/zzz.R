.onAttach <- function(...){
  # Check package is up to date
  tryCatch({
    packageStartupMessage(SCRCdataAPI:::get_startup_message(
      "ScottishCovidResponse/SCRCdata", "SCRCdata"))
  }, error = function(e){
    packageStartupMessage("Could not check if updates are available, please check manually")
  })
}
