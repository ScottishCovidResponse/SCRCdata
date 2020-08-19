
key <- readLines("token.txt")

attach_issue(description = "Data dump caused a spike on the 15th of June",
             severity = 19,
             # external_object = ,
             namespace = "SCRC",
             data_product = "records/SARS-CoV-2/scotland/cases_and_management",
             component = "testing_location/date-cumulative",
             key = key)


attach_issue(description = "COVID-19 data by NHS Board contains *s which represent a count of <5 (?). These have been changed to 0 in the dataset.",
             severity = 10,
             # external_object = ,
             namespace = "SCRC",
             data_product = "records/SARS-CoV-2/scotland/cases_and_management",
             key = key)
