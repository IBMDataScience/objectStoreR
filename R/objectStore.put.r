#helper fuction for passing creds correctly:
make_json <- function(creds) {
  paste("{\"auth\": {\"identity\": {\"password\": {\"user\": {\"domain\": {\"id\": \"",
        creds["domain_id"],
        "\"}, \"password\": \"",
        creds["password"],
        "\", \"name\": \"",
        creds["username"],
        "\"}}, \"methods\": [\"password\"]}}}",
        sep="")
}

#' Fuction for saving data to ObjectStore
#'
#' This function pushes data to objectStore from your kernel
#' @param creds your swift credentials, see README for further info
#' @keywords swift
#' @export
#' @examples
#' #this example runs in DSX
#' creds <-list(auth_url = "https://identity.open.softlayer.com",project = "object_storage_92c67982_------",project_id = "7babac2c------------------",region = "dallas",user_id = "18aa------------------",domain_id = "2c------------------",domain_name =  "------",username = "admin_774cd5e------------------------",password = "i------------",container = "notebooks")

#' write.csv(df,'myCSVforGit.csv')
#' status<- objectStore.put(creds,'myCSVforGit.csv')
#' status

objectStore.put <- function(creds, out_file) {
  url_1 <- paste(creds["auth_url"], "/v3/auth/tokens", sep="")
  post <- httr::POST(url=url_1,
               body=make_json(creds),
               httr::add_headers("Content-Type"="application/json"),
               httr::verbose())
  data <- httr::content(post, useInternalNodes=T)
  for(e_1 in data[["token"]][["catalog"]]) {
    if(e_1["type"] == "object-store") {
      for(e_2 in e_1[["endpoints"]]) {
        if(e_2["interface"] == "public" && toString(e_2["region"]) == toString(creds["region"])) {
          url_2 <- paste(e_2["url"], "/", creds["container"], "/", basename(out_file), sep="")
        }
      }
    }
  }
  subject_token = toString(post[["headers"]]["x-subject-token"])
  put <- httr::PUT(url=url_2, httr::add_headers("X-Auth-Token"=subject_token, "accept"="application/json"),body = httr::upload_file(out_file))
  status <- put$status_code
  return(status)
}

