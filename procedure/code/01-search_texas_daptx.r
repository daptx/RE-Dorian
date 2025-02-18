# search geographic twitter data for Hurricane Dorian
# by Joseph Holler, 2019,2021
# This code requires a twitter developer API token!
# See https://cran.r-project.org/web/packages/rtweet/vignettes/auth.html

# install packages for twitter querying and initialize the library
packages = c("rtweet","here","dplyr","rehydratoR")
setdiff(packages, rownames(installed.packages()))
install.packages(setdiff(packages, rownames(installed.packages())),
                 quietly=TRUE)

library(rtweet)
library(here)
library(dplyr)
library(rehydratoR)

############# SEARCH TWITTER API ############# 

# reference for search_tweets function: 
# https://rtweet.info/reference/search_tweets.html 
# don't add any spaces in between variable name and value for your search
# e.g. n=1000 is better than n = 1000
# the first parameter in quotes is the search string
# n=10000 asks for 10,000 tweets
# if you want more than 18,000 tweets, change retryonratelimit to TRUE and 
# wait 15 minutes for every batch of 18,000
# include_rts=FALSE excludes retweets.
# token refers to the twitter token you defined above for access to your twitter
# developer account
# geocode is equal to a string with three parts: longitude, latitude, and 
# distance with the units mi for miles or km for kilometers

# set up twitter API information with your own information for
# app, consumer_key, and consumer_secret
# this should launch a web browser and ask you to log in to twitter
# for authentication of access_token and access_secret
twitter_token = create_token(
  app = "ND Spatial Clustering",                     #enter your app name in quotes
  consumer_key = "m4TwybVNDwtGC0kydCik3cW44",  		      #enter your consumer key in quotes
  consumer_secret = "QPQplWWUddibK7qWwd5C6ap2PHTrHpw20VKiVEp1caMw34H9lW",         #enter your consumer secret in quotes
  access_token = "1337140853652017152-kyr1fHph9e4UEhPIRcv6V7quRGaj63",
  access_secret = "YS2gHHxp1JHiWuSeGEIuoHcX7AnX4HmVFx0EONzS1GV2C"
)

# get tweets for vaccines in texas, searched on May 10, 2021
# this code will no longer work! It is here for reference.
texas = search_tweets("vaccine OR appointment OR vaccination",
                       n=200000, include_rts=FALSE,
                       token=twitter_token, 
                       geocode="29.76,-95.37,1000mi",
                       retryonratelimit=TRUE) 

baseline = search_tweets("-vaccine OR -appointment OR -vaccination",
                      n=200000, include_rts=FALSE,
                      token=twitter_token, 
                      geocode="29.76,-95.37,1000mi",
                      retryonratelimit=TRUE) 

# write results of the original twitter search
write.table(texas$status_id,
            here("data","raw","public","texasids.txt"), 
            append=FALSE, quote=FALSE, row.names = FALSE, col.names = FALSE)

############# LOAD SEARCH TWEET RESULTS  ############# 

### REVAMP THESE INSTRUCTIONS

# load tweet status id's for Hurricane Dorian search results
texasids = 
  data.frame(read.table(here("data","raw","public","texasids.txt"), 
                        numerals = 'no.loss'))

# rehydrate dorian tweets #DOESNT WORK FOR NOW
texas_raw = rehydratoR("m4TwybVNDwtGC0kydCik3cW44", "QPQplWWUddibK7qWwd5C6ap2PHTrHpw20VKiVEp1caMw34H9lW", 
                       "1337140853652017152-kyr1fHph9e4UEhPIRcv6V7quRGaj63", 
                       "YS2gHHxp1JHiWuSeGEIuoHcX7AnX4HmVFx0EONzS1GV2C", texasids, 
                base_path = NULL, group_start = 1)

############# FILTER DORIAN FOR CREATING PRECISE GEOMETRIES ############# 

# reference for lat_lng function: https://rtweet.info/reference/lat_lng.html
# adds a lat and long field to the data frame, picked out of the fields
# that you indicate in the c() list
# sample function: lat_lng(x, coords = c("coords_coords", "bbox_coords"))

# list and count unique place types
# NA results included based on profile locations, not geotagging / geocoding.
# If you have these, it indicates that you exhausted the more precise tweets 
# in your search parameters and are including locations based on user profiles
count(texas_raw, place_type)

# convert GPS coordinates into lat and lng columns
# do not use geo_coords! Lat/Lng will be inverted
texas = lat_lng(texas, coords=c("coords_coords"))

# select any tweets with lat and lng columns (from GPS) or 
# designated place types of your choosing
texas = subset(texas, 
                place_type == 'city'| place_type == 'neighborhood'| 
                  place_type == 'poi' | !is.na(lat))

# convert bounding boxes into centroids for lat and lng columns
texas = lat_lng(texas,coords=c("bbox_coords"))

# re-check counts of place types
count(texas, place_type)


############# FILTER DORIAN FOR CREATING PRECISE GEOMETRIES ############# 

# reference for lat_lng function: https://rtweet.info/reference/lat_lng.html
# adds a lat and long field to the data frame, picked out of the fields
# that you indicate in the c() list
# sample function: lat_lng(x, coords = c("coords_coords", "bbox_coords"))

# list and count unique place types
# NA results included based on profile locations, not geotagging / geocoding.
# If you have these, it indicates that you exhausted the more precise tweets 
# in your search parameters and are including locations based on user profiles
count(baseline, place_type)

# convert GPS coordinates into lat and lng columns
# do not use geo_coords! Lat/Lng will be inverted
baseliine = lat_lng(baselnie, coords=c("coords_coords"))

# select any tweets with lat and lng columns (from GPS) or 
# designated place types of your choosing
baseline = subset(baseliine, 
               place_type == 'city'| place_type == 'neighborhood'| 
                 place_type == 'poi' | !is.na(lat))

# convert bounding boxes into centroids for lat and lng columns
baseline = lat_lng(texas,coords=c("bbox_coords"))

# re-check counts of place types
count(baseline, place_type)

############# SAVE FILTERED TWEET IDS TO DATA/DERIVED/PUBLIC ############# 

write.table(texas$status_id,
            here("data","derived","public","texasids.txt"), 
            append=FALSE, quote=FALSE, row.names = FALSE, col.names = FALSE)

write.table(baseline$status_id,
            here("data","derived","public","baselineids.txt"), 
            append=FALSE, quote=FALSE, row.names = FALSE, col.names = FALSE)

############# SAVE TWEETs TO DATA/DERIVED/PRIVATE ############# 

saveRDS(texas, here("data","derived","private","texas.RDS"))
saveRDS(baseline, here("data","derived","private","baseline.RDS"))

