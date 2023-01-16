library('ruODK')
library('dotenv')
library('dplyr')
library('httr')
load_dot_env()


ru_setup(
  url = Sys.getenv('ODK_URL'),
  un = Sys.getenv('ODK_USER'),
  pw = Sys.getenv('ODK_PASSWORD'),
  pp = Sys.getenv('ODK_ENCRYPTION_PASSPHRASE'),
  verbose = TRUE,
  tz = Sys.timezone(),
)

projects <- project_list()

  project_ids <- projects$id

export_path <- paste("exports", gsub(":", "-", Sys.time()), sep = "/")

dir.create(export_path)

for (project_id in project_ids) {



  ## form_list fails if a project contains no forms, so skip if this is the case
test <- project_detail(pid = project_id)$forms

  if(project_detail(pid = project_id)$forms == 0) next

  form_list <- form_list(pid = project_id)
  published_form_list <- form_list %>% filter(!is.na(published_at))

  project_export_path <- paste(export_path, project_id, sep = "/")
  dir.create(project_export_path)

  for(form_id in published_form_list$xml_form_id) {

    submission_export(
      local_dir = project_export_path,
      pid = project_id,
      fid = form_id,
    )
  }

  ## Get XLSX + XML form definitions as well
  for(form in form_list$xml_form_id) {
    list <- list(
      email = Sys.getenv('ODK_USER'),
      password = Sys.getenv('ODK_PASSWORD')
    )
    
    ## format as url (remove spaces)
    formUrl <- gsub(" ", "%20", form)
    
    
    ## could not find a way of doing this in ruODK, so falling back to a basic HTML API request
    authCode <- paste("Basic ", openssl::base64_encode(paste0(Sys.getenv('ODK_USER'),":",Sys.getenv('ODK_PASSWORD'))))
    
    ### get all published versions of the form
    versionPath <- paste(Sys.getenv('ODK_URL'),  "v1/projects", project_id, "forms", formUrl, "versions", sep = "/")
    

    
    versionResponse <- httr::GET(versionPath,
                          add_headers(Authorization = authCode)
                          )
    versions <- jsonlite::fromJSON(content(versionResponse, as="text"))
    
    for (version in versions$version) {
        
      
      pathXls <- paste(Sys.getenv('ODK_URL'),  "v1/projects", project_id, "forms", formUrl, "versions", paste0(version, ".xlsx"), sep = "/")
      pathXml <- paste(Sys.getenv('ODK_URL'),  "v1/projects", project_id, "forms", formUrl, "versions", paste0(version, ".xml"), sep = "/")
      
      ## need to replace "/" in version for file names
      version <-  gsub("/", "-", version)
      
      formFileXls <- paste0(project_export_path, "/", form, "-", version, ".xlsx")
      formFileXml <- paste0(project_export_path, "/", form, "-", version, ".xml")
      
      responseXls <- httr::GET(pathXls,
                write_disk(formFileXls, overwrite = TRUE),
                add_headers(Authorization = authCode)
              )
      
      
      responseXml <- httr::GET(pathXml,
                 write_disk(formFileXml, overwrite = TRUE),
                 add_headers(Authorization = authCode)
      )

      
      ## sometimes, xlsx files do not exist (requests above return 404). If this is true, an empty file will have been created. 
      # Remove these empty files for clarity.
      if(http_error(responseXls)) {
        unlink(formFileXls)
      }
      
      if(http_error(responseXml)) {
        unlink(formFileXml)
      }
  
    }
                        
  }

}
  
