# PhEDEx global transfer volume history

- run the *update-statistics.pl* script, which will get data from the data-service and create an *All-PhEDEx-transfers.csv.new* file.
- copy or rename the *All-PhEDEx-transfers.csv.new* file to *All-PhEDEx-transfers.csv*
- start R
- source('global-transfer-rate.R')
- the updated plot will be available in *All-PhEDEx-transfers.bmp* and *All-PhEDEx-transfers.pdf*
- periodically, commit the new *All-PhEDEx-transfers.csv* file, so that the next time you clone the repository it will have less data to download

N.B. The script depends on a few R packages (e.g. RColorBrewer), so pay attention to any error messages and install what you need to get it running. There are only one or two packages, so it shouldn't take long.

To install a package in R, use the *install.packages* command. E.g. *install.packages('RColorBrewer')*
