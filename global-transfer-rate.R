# Plot the global monthly transfer rate since the dawn of time
rm(list=ls())
d <- read.csv('All-PhEDEx-transfers.csv')

# Tidy the data, hiding zeroes and normalising by month-length
for (i in 1:length(d$Month) ) {
  for ( j in names(d)[3:11] ) {
    d[i,j] <- d[i,j] / d[i,'NDays']
  }
}
for ( i in names(d)[3:11] ) { d[i] <- sapply( d[i], function(x) { return(x+0.001) } ) }

names(d)[7] <- 'DDT'

# set up the display device
for (i in dev.list()) { dev.off() }
width <- 10
height <- 5
dev.new(width=width,height=height)
par(mar=c(5,2,4,6))

colours <- RColorBrewer::brewer.pal(8,'Set2');
colours <- rev(colours);

# transpose, and barplot it!
maxY <- ceiling(max(d$Total.Data)/100) * 100
print(paste0("Max Y scale: ",maxY))
yTicks <- c(0,1,10,100,300,1000,3000,10000)
nyTicks <- sum(yTicks <= maxY)
yTicks  <- yTicks[1:nyTicks]
yLabels <- as.character(yTicks)
yLabels[nyTicks] <- paste(yLabels[nyTicks],'TB/day')

dt <- t(d[3:10])
barplot(dt,
        col=colours,
        log='y',
        ylim=range(0.3:maxY),
        axes=FALSE,
        xpd=FALSE,
        border=NA,
        space=0,
       )
axis(side=4,
     label=yLabels,
     at=yTicks,
     las=2,
     cex.axis=0.8
     )
# Add the legend and the x-axis
legend('topleft',legend=names(d)[3:10], col=colours, pch=22, pt.cex=3, cex=1.2, pt.bg=colours, bty='n')

# deduce x-axis labels
lenX <- 12
nBefore <- length(d$Month) - lenX * floor( length(d$Month) / lenX )
if ( nBefore == 0 ) { nBefore <- 12 }
xAxis <- d$Month[c(rep(FALSE,nBefore-1),TRUE,rep(c(rep(FALSE,lenX-1),TRUE),lenX))]
axis(side=1,
     label=xAxis,
     at=seq(from=nBefore, by=lenX, length.out=length(xAxis)),
     las=2,
     cex.axis=0.8
     )

# Add some decoration
# line showing 1 PB/week
lines(x=c(30,nrow(d)),y=c(1024/7,1024/7),lwd=1,lty=2)
text(x=37,y=1024/7+50,labels='1 PB/week',cex=1.)
lines(x=c(100,nrow(d)),y=c(2048/7,2048/7),lwd=1,lty=2)
text(x=107,y=2048/7+50,labels='2 PB/week',cex=1.)

# save the plot for later!
cur <- dev.cur()
scale <- 300
bmp(width=width*scale, height=height*scale, filename='All-PhEDEx-transfers.bmp', res=300)
new <- dev.cur()
dev.set(which=cur)
dev.copy(which=new)
dev.off(new)

pdf(width=width, height=height, file='All-PhEDEx-transfers.pdf')
new <- dev.cur()
dev.set(which=cur)
dev.copy(which=new)
dev.off(new)

# dev.off(cur)