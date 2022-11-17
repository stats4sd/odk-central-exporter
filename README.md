# Export All Data from an ODK Central Repo

This project is a script that enables you to export all available data from an ODK Central server. 


## How to use

### 1. Initial Setup
1. Clone this repo: git clone git@github.com:stats4sd/odk-central-exporter
2. Inside the new folder, copy the `.env.example` file to `.env`. Then enter the url, email and password for the ODK Central Server.


### 2. Run the Script

**In R Studio**
- Open the folder in RStudio
- Run `renv::restore()` to install the required packages
- Run the main.R script.

**Via Command Line**

```
cd odk-central-exporter
Rscript -e "renv::restore()"
Rscript main.R
```

### 3. Check your exported data

The data will be exported to the `exports` folder, inside a new date-time stamped folder. It will be in the structure:

exports
 - 2022-11-17 15-11-12
   - project_id
     - form_xml_id.zip
     - form_xml_id.zip
   - project_id
     - form_xml_id.zip
     - form_xml_id.zip

Each zip file will contain all the submissions for the form. If the form has repeat groups, there will be multiple csv files - one for the "main" submission data, and one for each of the repeat groups.  For more information on the exported data formats, see the ruODK documentation: https://docs.ropensci.org/ruODK/reference/submission_export.html

