##Scraping California Misconduct Records with rvest


#load in and install packages
library(tidyverse)
library(rvest)
library(xml2)
library(chromote)
library(tryCatchLog) #error catch - not needed
library(furrr)# parallel processing
#Check if we are allowed to scrap
library(robotstxt)
library(httr)

#check to see if scraping is allowed
paths_allowed("https://clean.latimes.com/?_gl=1*1319xyg*_gcl_au*MTAxNzM1Mzc0LjE3NjIwMjQ2NTg.")


#set the url from the LA Times for scraping
url <- "https://clean.latimes.com/"


#make the scraping function
scrape_function <- function(url_scrape) {
  Sys.sleep(sample(6:10, 1))
  
    html_scrape <- rvest::read_html_live(url_scrape)
    
    Sys.sleep(sample(3:4, 1))
    #grab the dates column
    dates <- html_scrape |> html_elements(".tracking-tight") |> 
      html_text() |> as.data.frame() |> 
      dplyr::rename(dates = 1)
    
    
    Sys.sleep(1)
    #grab use of force codes
    force <- html_scrape |> html_elements(".gap-1\\.5") |> 
      html_text() |> as.data.frame() |> 
      dplyr::rename(force = 1)
    
    Sys.sleep(1)
    #grab source departments
    departments <- html_scrape |> html_elements(".italic") |> 
      html_text() |> as.data.frame() |> 
      dplyr::rename(departments = 1)
    
    Sys.sleep(1)
    #grab case id
    numbers = html_scrape |> html_elements(".font-mono") |> 
      html_text() |> 
      as.data.frame() |> 
      dplyr::rename(numbers= 1)
    
    Sys.sleep(1)
    
    #grab officers involved
    officers_force = html_scrape |> html_elements(".min-h-28") |> 
      html_text() |> 
      as.data.frame() |> 
      rename(text = 1)
    
    #extract the officer names and case ids
    off_id <- str_extract(officers_force$text, "m-.*?Source") |> 
      as.data.frame() |> 
      rename(split =1)
    
    #separate based on case id and officer name
    off_out <- off_id |> 
      separate_wider_regex(
        cols = split,
        patterns = c(
          numbers = ".{18}",  
          officers = ".*"))
    
    
    #cbind dates, departments, force, and numbers
    df_out <- cbind(dates, departments, force, numbers)
    
    #join officers and the df_out by case id (numbers)
    df_out <- dplyr::left_join(df_out, off_out, by = "numbers")
    
    #add in the url
    df_out$url <- url_scrape
    
    #get the page number
    page_number  <- sub(".*page=", "", df_out$url[1])
    
    #set the csv name with page number and folder path
    csv_name <- paste("scraping_dfs/","page_", page_number, ".csv", sep = "")
    
    #write to csv with name name - one csv for each page to ensure scrapped data is not lost
    write.csv(df_out, file = csv_name)
  
    #Close out the browser
    html_scrape$session$close() 
    rm(html_scrape)
  
}



#set the rate delay
rate <- rate_delay(5, max_times = 3)

#make an insistent scrape function with a rate delay
insistent_scrape_function <- purrr::insistently(scrape_function,
                                                rate = rate)


#make a possibly insistent version for errors
possib_insistent_scrape <- purrr::possibly(insistent_scrape_function, 
                                           otherwise = "Error", 
                                           quiet = TRUE)


#make a list of all url page numbers to scrape
numbers_scrape_list = seq(from = 1, to = 1136, by = 1)
numbers_scrape_list <- paste0("?page=",numbers_scrape_list)
numbers_scrape_list <- paste0(url, numbers_scrape_list)



#test the function on pages 1 - 3
page_1_3  <- purrr::map(numbers_scrape_list[1:3], possib_insistent_scrape,
                             .progress = TRUE)



##set the plan for parallel processing - with 12 workers
plan(multisession, workers = 12)

#start sim time
tictoc::tic()

#apply the function to the numbers scrape list, skipping the test urls
scrape <- furrr::future_map(numbers_scrape_list[4:1136], possib_insistent_scrape,
                                 #set the seed 
                                 .options = furrr_options(seed = 09212026),
                                 #set the progress bar
                                 .progress = TRUE)


#end time
time_out <- tictoc::toc()

#calculate total sim time
sim_time <- time_out$callback_msg

#turn off the parallel process
plan(sequential)

#time in minutes
time_minutes <- 1631.73/60

#about 27 minutes to run 




