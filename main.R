library('ruODK')
library('dotenv')
library('dplyr')

load_dot_env()

ru_setup(
  url = Sys.getenv('ODK_URL'),
  un = Sys.getenv('ODK_USER'),
  pw = Sys.getenv('ODK_PASSWORD'),
  verbose = TRUE,
  tz = Sys.timezone(),
)

projects <- project_list()

  project_ids <- projects$id

export_path <- paste("exports", gsub(":", "-", Sys.time()), sep = "/")

dir.create(export_path)

for (project_id in project_ids) {

  ## form_list fails if a project contains no forms, so skip if this is the case
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

}
