#' Fuction for setting configurations from swift
#'
#' This function allows you to set your configuration in swift from sparklyr
#' @param sc active spark context
#' @param creds your swift credentials, see README for further info
#' @keywords swift
#' @export
#' @examples
#' #this example runs in DSX
#' kernels <- sparklyr::list_spark_kernels()
#' sc <- sparklyr::spark_connect(config = kernels[1])
#' creds <-list(auth_url = "https://identity.open.softlayer.com",project = "object_storage_92c67982_------",project_id = "7babac2c------------------",region = "dallas",user_id = "18aa------------------",domain_id = "2c------------------",domain_name =  "------",username = "admin_774cd5e------------------------",password = "i------------",container = "notebooks", filename = "yourfile.csv")
#' set_swift_config(sc, creds)
#' #then you can read data in from ObjectStore into spark
#' spark_object_name = "dataFromSwift" #what you want the object called in spark
#' swift_data_object_path = "swift://sparklyrenvironment.keystone//flights3.csv"
#' sparklyr::spark_read_csv(sc, spark_object_name,swift_data_object_path)

set_swift_config = function(sc,creds){

  # get spark_context
  ctx <- spark_context(sc)

  #set the java spark context
  jsc <- invoke_static(
    sc,
    "org.apache.spark.api.java.JavaSparkContext",
    "fromSparkContext",
    ctx
  )

  #set the swift configs:
  hconf = jsc %>% invoke("hadoopConfiguration")
  hconf %>% invoke("set","fs.swift.service.keystone.auth.url", "https://identity.open.softlayer.com/v3/auth/tokens" )
  hconf %>% invoke("set","fs.swift.service.keystone.auth.endpoint.prefix", "endpoints" )
  hconf %>% invoke("set","fs.swift.service.keystone.tenant", creds$project_id )
  hconf %>% invoke("set","fs.swift.service.keystone.username", creds$user_id )
  hconf %>% invoke("set","fs.swift.service.keystone.password", creds$password )
  hconf %>% invoke("set","fs.swift.service.$name.http.port", "8080" )
  hconf %>% invoke("set","fs.swift.service.keystone.region", cred$region )
  hconf %>% invoke("set","fs.swift.service.keystone.public", "TRUE" )

}




