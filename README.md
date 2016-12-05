# objectStoreR
R Package to read/write files from Object Storage in Bluemix

### Decsription

This R Package wraps around the Object Storage API to make it easy to pull data into R or send data to Object Storage.  There are currently two functions supported, objectStore.get and objectStore.put.  See below how to install, use, and contribute.

### Installation

If you do not have the R Package devtools installed, execute the three lines below to install the package.  If you already have it installed, load it with library() then use install_github() to install this package:

```
install.packages('devtools')
library(devtools)
install_github('IBMDataScience/objectStoreR') #installs the package
library('objectStoreR')  #loads the package for use
```

### Credentials for API

If you are using the Bluemix Object Storage service you probably have credentials that look like this: 
```
{
  "credentials": {
    "auth_url": "https://identity.open.softlayer.com",
    "project": "object_storage_92c67982_------",
    "projectId": "7babac2c------------------",
    "region": "dallas",
    "userId": "18aa------------------",
    "username": "admin_774cd5e------------------------",
    "password": "i------------",
    "domainId": "2c------------------",
    "domainName": "------",
    "role": "admin"
  }
}
```

The problem with these credentials is that R doesn't like this format very much.  The following functions use credentials in this format:

```
creds <-list(auth_url = "https://identity.open.softlayer.com",project = "object_storage_92c67982_------",project_id = "7babac2c------------------",region = "dallas",user_id = "18aa------------------",domain_id = "2c------------------",domain_name =  "------",username = "admin_774cd5e------------------------",password = "i------------",container = "notebooks", filename = "yourfile.csv")
```

These credentials can easily be obtained when using an R Jupyter Notebook in IBM Data Science Experience. 

### Get files with objectStore.get

Set your credentials list as described in the credentials section, pay attention to container and filename as this will tell the function what file to grab.  Currently the package only supports getting CSV files.  Since all the information needed is in the credentials list, the function call just passes this list and returns a dataframe object:

```
creds <-list(auth_url = "https://identity.open.softlayer.com",project = "object_storage_92c67982_------",project_id = "7babac2c------------------",region = "dallas",user_id = "18aa------------------",domain_id = "2c------------------",domain_name =  "------",username = "admin_774cd5e------------------------",password = "i------------",container = "notebooks", filename = "yourfile.csv")

df <- objectStore.get(creds)
```

### Send files with objectStore.put

Set your credentials list as described in the credentials section.  You will still use a container to tell the function where to put the file, but the name of the file will be extracted from the file passed as the second argument to the function.  The example below shows saving a dataframe to CSV then calling the objectStore.put function passing the credentials list and the name of the file, the status of the request is returned from the function (201 = success):

```
creds <-list(auth_url = "https://identity.open.softlayer.com",project = "object_storage_92c67982_------",project_id = "7babac2c------------------",region = "dallas",user_id = "18aa------------------",domain_id = "2c------------------",domain_name =  "------",username = "admin_774cd5e------------------------",password = "i------------",container = "notebooks")

write.csv(df,'myCSVforGit.csv')
status<- objectStore.put(creds,'myCSVforGit.csv')
status
```


### Load files from objectStore directly to spark data frame with sparklyr
Set you credentials as listed above, and then after creating a spark context you can set your swift credentials and load a data set from objectStore to your spark context with the following commands:
```
#set swift configs with spark context (sc) and swift configs (creds):
set_swift_config(sc, creds)

#load a data set into the spark environment: 
spark_object_name = "dataFromSwift" #what you want the object called in spark
swift_data_object_path = "swift://sparklyrenvironment.keystone//flights3.csv"
sparklyr::spark_read_csv(sc, spark_object_name,swift_data_object_path)
