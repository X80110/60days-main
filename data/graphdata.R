library(tidyverse)

df <- read.csv("~/data.csv",header=T) %>%
  rename(url_count = visit_count)
df$duration <- lubridate::hms(df$duration)



df$visit_date <- lubridate::as_datetime(df$visit_date)


domain <- function(x) strsplit(gsub("http://|https://|www\\.", "", x), "/")[[c(1, 1)]]
df$domain <-  sapply(df$url, domain)
df$from_url<-replace(df$from_url, df$from_url == "", "New tab")
df$from_domain <- sapply(df$from_url,domain)



#df$from_domain <- sapply(df$from_url, domain)
#df$parent <- sapply(df$from_url, domain, na=rm)


#install.packages("tidySEM")


  #add_count(day) %>% 
daily <- df %>% as.data.frame() %>% # filter(duration != 0) %>%
  group_by(domain, 
           from_domain,
           day=lubridate::floor_date(visit_date,"day")) %>% summarize(visits = n()) %>%
  arrange(domain,
         from_domain, 
         day)

distinct(daily)
target <- daily %>% ungroup() %>% select(target = domain, day,visits) %>% rename(label = target)
source <- daily %>% ungroup() %>% select(source = from_domain, day) %>% rename(label = source)
nodes <- full_join(source,target, by ="label") %>% distinct(label,day.x) %>% rowid_to_column("id") %>% mutate(name = paste(label,"·",day.x)) %>% select(name, id)

target <- target %>% mutate(name = paste(label,"·",day)) %>% left_join(nodes,by = "name")
source <- source %>% mutate(name = paste(label,"·",day)) %>% left_join(nodes,by = "name" )

links <- data.frame(source=source$name,target=target$name,visits=target$visits)

network  <- graph_from_data_frame(d=links,directed = TRUE)

data_json <- d3_igraph(network)
write(data_json, "/Users/xavier/Desktop/60days/datasets/data.json")



# 
# weekly <- df %>% as.data.frame() %>% # filter(duration != 0) %>%
#   group_by(visits_id,
#            domain,
#            from_visit_id,
#            from_domain,
#            week=lubridate::floor_date(visit_date,"week")) %>% summarize(visits = n()) %>% ungroup() %>%
#   select(-visits_id, -from_visit_id)

# library(tidySEM)
# library(d3r)
# library(igraph)
# 
# sources <- data.frame(daily$from_domain) %>%
#   rename(label = daily.from_domain) %>%
#   distinct(label)
# 
# target <- data.frame(daily$domain) %>%
#   rename(label = daily.domain) %>%
#   distinct(label)
# 
# nodes <- full_join(sources, target, by = "label") %>% rowid_to_column("id")
# edges <- daily %>% left_join(nodes, by = c("from_domain" = "label")) %>% 
#   rename(from = id)
# edges <- edges %>% left_join(nodes, by = c("domain" = "label")) %>% 
#   rename(to = id)
# edges <- select(edges, from, to,duration)
# 
# 
# 
#  # Save this file
# install.packages("networkD3")
#library(networkD3)
# 
# links = data.frame(source = daily$from_domain, target = daily$domain, value = daily$visits)
# nodes <- data.frame(
#   name=c(as.character(links$source), 
#          as.character(links$target)) %>% unique()
# )
# 
# links$IDsource <- match(links$source, nodes$name)-1 
# links$IDtarget <- match(links$target, nodes$name)-1
# 
# all <- daily %>% select(from_domain, domain, duration, day)




# 
# 
# hourly$country <- c(rep("Night",6),rep("Morning",6),rep("Afternoon",6),rep("Evening",6))
# dim(hourly)
# 
# write.csv(hourly, file='/Users/xavier/Downloads/childhood-mortality-master/public/data.csv')
# 
# library(lubridate)
# init <- ymd_hm("2020-11-8 0:00")
# a <-seq(init, init+days(60), by = "hour")
# b <-seq(init, init+days(60), by = "day")
# 
                    

                