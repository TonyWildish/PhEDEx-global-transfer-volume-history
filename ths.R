rm(list=ls())
library('RJSONIO')
jsonUrl <- 'https://localhost:30004/phedex/datasvc/json/tbedi/transferhistorysummary'
file <- 'ths-tbedi.json'
download.file(jsonUrl,destfile=file,method='curl',extra='--insecure')
con <- file(file)
jsonTbed <- fromJSON(con)
close(con)
unlink(file)
jsonTbed <- jsonTbed$phedex$transferhistorysummary
tbed <- matrix(nrow=length(jsonTbed),ncol=2)
for (i in 1:length(jsonTbed) ) {
  tbed[i,1] = jsonTbed[[i]]$timebin
  tbed[i,2] = jsonTbed[[i]]$sum_done_bytes
}
tbed <- data.frame(data=tbed,stringsAsFactors=FALSE)
names(tbed) <- c('timebin','TB')

plot(tbed$TB)
