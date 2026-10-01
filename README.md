# Project Description


## Introduction

This project scrapes California police misconduct and use of force data
from the Police Access Project, hosted by the [Los Angeles
Times](https://clean.latimes.com/), [Cal
Matters](https://clean.calmatters.org/),
[KQED](https://policerecords.kqed.org/), and the [San Francisco
Chronicle](https://clean.sfchronicle.com/). A history of the project and
information on how to search the dataset can be found at this
[description](https://bellingcat.gitbook.io/toolkit/more/all-tools/police-records-access-project)
posted on bellingcat’s website.

According to The Police Access Project, their project details
information from 11,352 related to police misconduct or violence, along
with 20,594 officer identifications and 1,463,515 pages of documents.
Details about the project files, folders, and the R scraping and
cleaning scripts can be found below.

This projects scrapes the 1136 web pages of case information into one
clean csv file to make it easier to track cases across departments
overtime. This project does not include any of the case information
detailed in the PDF case documents, it only scrapes the description
information available for each case hosted on the Los Angeles Times
website.

The Los Angeles Times case information was scraped on **09/21/2026** and
future updates to this dataset will not be reflected after this date.

## Project Disclaimer

I cannot verify the accuracy of information about officers and police
departments involved in the dataset and users should refer to the [About
page](https://clean.calmatters.org/about) on the Cal Matters website
that includes vital information about the project. As case information
from this project is continuously updated, users should verify
individual case information by consulting the case documents.

As many cases include multiple police departments or California
government agencies as sources, readers should not infer that the first
department or organization listed as a source for the use of force cases
is the agency that the officers involved in each case were employed by.
Any errors resulting from the scraping and cleaning process are mine
alone.

## Project Folder

CA_police_misconduct_scrape/

├── clean_data/ \# Holds the csv with the clean scraped webpages.

├── scraping_dfs/ \# Holds the raw scraped webpages, with one csv for
each page.

└── README.md \# Project overview

## Project Files

`clean_data/CA_misconduct_clean.csv` - csv file that holds the scraped
and cleaned misconduct cases.

### R Scripts

`CA_police_misconduct_scrape_final_09212026` - R script that scrapes the
case information from the Los Angeles Times and saves each scraped
webpage in the scraping_dfs folder.

`CA_police_misconduct_cleaning.R` - R script that cleans the raw scraped
webpages and formats the output into a csv in the clean_data folder.

## Variable Descriptions (clean_data/CA_misconduct_clean.csv)

| Variable Name | Variable Description |
|:---|:---|
| `case_id` | Unique case id number - starts with an ‘m’ |
| `dates_in` | The first date listed for the case. |
| `dates_out` | The last date listed for the case. |
| `source_dept` | The first department listed as a source for the case. |
| `county_state` | The county where the first source department is located or displays ‘California’ for state agencies. |
| `city` | The city where the first source department is located. |
| `source_detp2` | The second source department for the case. |
| `source_dept3` | The third source department for the case. |
| `source_dept4` | The fourth source department for the case. |
| `source_dept5` | The fifth source department for the case. |
| `source_dept6` | The sixth source department for the case. |
| `force_bin` | Details whether use of force was used: ‘Yes’ or ‘No’ |
| `misconduct_bin` | Details whether the case involved misconduct: ‘Yes’ or ‘No’ |
| `shooting_bin` | Details whether the case involved a shooting: ‘Yes’ or ‘No’ |
| `officers_force` | Details what type of force officers were involved in. |
| `officers_involved` | Includes the names of the officers involved with the ‘officers_force’ column. |
| `officers_force2` | Details what type of force officers were involved in (if multiple types). |
| `officers_involved2` | Includes the names of the offiers involved with the ‘officers_involved2’ column. |
| `url` | The url for each webpage. |
| `page_number` | The page number from the LA Times website where the case can be found. |
