
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
