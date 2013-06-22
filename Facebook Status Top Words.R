username <- "cnn"

start.date <- strptime("2012-06-01 00:00:00", "%Y-%m-%d %H:%M:%S")

## convert .csv to data frame

data <- read.csv(paste(username,"-Status.csv",sep=""),header=T)
names(data) <- c("title", "message", "time", "numLikes", "numShares", "isQuestion", "type", "linkurl","posturl")
data <- data[-which(data$numLikes > (mean(data$numLikes) + 3 * sd(data$numLikes))),] # conservative outlier removal

## get vector of all words containing a capital letter

words.list <- strsplit(as.character(data$message), split="[^\\w]",perl=TRUE)
words.vector <- unlist(words.list)
words.vector.filter <- words.vector[grep("[A-Z]",words.vector)]
word.freq <- sort(table(words.vector.filter),decreasing=TRUE)

top.words <- word.freq[which(word.freq>30 & nchar(names(word.freq)) >= 2)]

## construct data frame for regression

y <- t(apply(as.array(words.list),1,function(words) {return (ifelse(names(top.words) %in% words[[1]],"Y","N")) }))
colnames(y) <- names(top.words)

data <- data.frame(numLikes=data$numLikes,time=as.numeric(strptime(data$time, "%Y-%m-%d %H:%M:%S")-start.date)/24,type=data$type,y)

reg.lm <- lm(numLikes ~ ., data=data)
sum.reg.lm <- summary(reg.lm)

## remove variables to optimize regression

step.1<-step(reg.lm,direction="backward",trace=T)
sum.step.1 <- summary(step.1)
sum.step.1.filter <- sum.step.1$coef[which(sum.step.1$coef[,4]<0.05),]
sum.step.1.filter <- sum.step.1.filter[order(-sum.step.1.filter[,1]),]

## Remove "Y" and remove non-keyword variables for display purposes

sum.step.1.filter <- sum.step.1.filter[-which(rownames(sum.step.1.filter) %in% c("(Intercept)","typephoto","typevideo","time")),]
rownames(sum.step.1.filter) <- apply(as.array((rownames(sum.step.1.filter))),1, function(x) {return(substr(x,1,nchar(x)-1))})

round(sum.step.1.filter[,c(1,4)],2) # final coefficients

# write.table(x,"clipboard",sep='\t\t\t', quote=F)  method to write table for copy-paste to Markdown