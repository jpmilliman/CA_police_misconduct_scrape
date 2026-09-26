#cleaning the scraped dataframes

#load in packages for cleaning
library(tidyverse)
library(stringr)

#load in file paths
file_path  <- list.files(path = "scraping_dfs/",pattern = ".csv", full.names = TRUE) 

#load in and bind the csvs
scraped_dfs <- purrr::map(file_path, readr::read_csv) |> 
  purrr::list_rbind()


#extract and arrange by the page number
clean_df <- scraped_dfs |> 
 separate_wider_delim(url, "=", names = c("url", "page_number"), too_many = "merge") |> 
  mutate(url = paste(url,"=", page_number, sep =""),
         page_number = as.numeric(page_number)) |> 
  arrange(page_number)


#create the misconduct, shooting, and force variables binary variables
clean_df <- clean_df |> 
  mutate(force_bin = case_when(str_detect(force, pattern = "Force") ~ "Yes",
                               .default = "No"),
         misconduct_bin = case_when(str_detect(force, pattern = "Misconduct") ~ "Yes",
                                    .default = "No"),
         shooting_bin = case_when(str_detect(force, pattern = "Shooting") ~ "Yes",
                                  .default = "No"))



#clean the officers column
clean_df <- clean_df |> 
  #separate officers by force code
  separate_wider_delim(officers, ":", names = c("officers_force", "officers_involved"), too_many = "merge",
                       too_few = "align_end") |> 
  #remove "Source" and "used form the officers_involved and officers_force columns
  mutate(officers_involved = str_remove(officers_involved, pattern = "Source"),
         officers_force = str_remove(officers_force, pattern = "used")) |> 
  #separate by second officer code
  separate_wider_delim(officers_involved, "used", names = c("officers_involved1", "officers_involved2"), too_many = "merge",
                       too_few = "align_start") |> 
  #separate second officer code between force code and officers involved
    separate_wider_delim(officers_involved2, ":", names = c("officers_force2", "officers_involved1a"), too_many = "merge",
                       too_few = "align_start") |> 
  #rename columns to standardize names
  rename(officers_involved = officers_involved1,
         officers_involved2 = officers_involved1a)



#clean the dates column
clean_df <- clean_df |> 
  #separate officers by force code
  separate_wider_delim(dates, "–", names = c("dates_in", "dates_out"), too_many = "merge",
                       too_few = "align_start")



#Split up the source departments columns
clean_df <- clean_df |> 
  separate_wider_delim(departments, ";", names = c("source_depart1", 
                                                   "source_depart2", 
                                                   "source_depart3",
                                                   "source_depart4",
                                                   "source_depart5",
                                                   "source_depart6"), too_many = "merge",
                       too_few = "align_start")
  

#Make the county/state column
clean_df <- clean_df |> 
  separate_wider_delim(source_depart1, " in ", names = c("source_depart", "county_state"), too_many = "merge",
                       too_few = "align_start")


#clean the first county column
clean_df <- clean_df |> 
  mutate(county_state = case_when(is.na(county_state) ~ str_extract(source_depart, "^.*?(?<=County)"),
                                  .default = county_state),
         city = case_when(str_detect(source_depart, "Police") ~ str_extract(source_depart, ".*?(?=Police)"),
                          .default = NA)) |> 
  relocate(city, .after = county_state)



#grab a select group of columns
df_out <- clean_df |> 
  #select and order key columns
  dplyr::select(numbers, dates_in:source_depart6,
                force_bin:shooting_bin,
                officers_force:officers_involved2,
                url, page_number) |> 
  #rename numbers to case_id
  rename(case_id = numbers)



#write to csv
write.csv(df_out, file = "clean_data/CA_misconduct_clean.csv")








