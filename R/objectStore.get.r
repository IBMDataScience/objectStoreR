


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

#' Fuction for getting data from objectStore
#'
#' This function pulls data from objectStore to your kernel
#' @param creds your swift credentials, see README for further info
#' @keywords swift
#' @export
#' @examples
#' #this example runs in DSX
#' creds <-list(auth_url = "https://identity.open.softlayer.com",project = "object_storage_92c67982_------",project_id = "7babac2c------------------",region = "dallas",user_id = "18aa------------------",domain_id = "2c------------------",domain_name =  "------",username = "admin_774cd5e------------------------",password = "i------------",container = "notebooks", filename = "yourfile.csv")
#' df <- objectStore.get(creds)


objectStore.get <- function(creds) {
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
          url_2 <- paste(e_2["url"], "/", creds["container"], "/", creds["filename"], sep="")
        }
      }
    }
  }
  subject_token = toString(post[["headers"]]["x-subject-token"])
  get <- httr::GET(url=url_2, httr::add_headers("X-Auth-Token"=subject_token, "accept"="application/json"))
  raw_csv <- httr::content(get, "text", "text/csv")
  return(read.csv(textConnection(raw_csv)))


}
