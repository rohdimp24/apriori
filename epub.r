library("arules")
data("Epub")
summary(Epub)

#number of data points
15729*936*0.001758755
N=15729

#based on the support number find the item frequency
sort(itemFrequency(Epub),decreasing = TRUE)[1:10]

#in order to find the actual number of occruence
N*sort(itemFrequency(Epub),decreasing = TRUE)[1:10]

#plot the items
itemFrequencyPlot(Epub,topN=10)


#this will print out all the transactionIds from the transaction
#basically when we create the transaction data structure we would identify one of the column as
#the transaction Id


create_transaction=function(){
  a_df3 <- data.frame(
    TID = c(1,1,2,2,2,3), 
    item=c("a","b","a","b","c", "b")
  )
  a_df3
  
  trans <- as(split(a_df3[,"item"], a_df3[,"TID"]), "transactions")
  trans  
}

# I guess split(a_df3[,"item"], a_df3[,"TID"]) can be used for the product transactions so that 
# we can combine the products that are part of same transactions ...in amazon_aprioriy we are
# using the dplyer package 
trans4=create_transaction()
inspect(trans4)
summary(trans4)
transactionInfo(trans4)




transactionInfo(Epub)




#create a new feature year..using the transactiuonInfo
year=strftime(as.POSIXlt(transactionInfo(Epub)[["TimeStamp"]]),"%Y")
table(year)


#get the data for the year 2003
Epub2003=Epub[year==2003]
length(Epub2003)

image(Epub2003)

Epub2004=Epub[year==2008]
length(Epub2004)

image(Epub2004)


#size function will give you the number of items in each transaction
size(Epub)

#find out the transactions that are of length > 20
transactionInfo(Epub2003[size(Epub2003)>20])



##########################

a_df3 <- data.frame(
  TID = c(1,1,2,2,2,3), 
  item=c("a","b","a","b","c", "b")
)
a_df3

# I guess split(a_df3[,"item"], a_df3[,"TID"]) can be used for the product transactions so that 
# we can combine the products that are part of same transactions ...in amazon_aprioriy we are
# using the dplyer package 
trans4 <- as(split(a_df3[,"item"], a_df3[,"TID"]), "transactions")
trans4
inspect(trans4)
summary(trans4)



#this is the amazon set.. it is based on the new transactions

mydb = dbConnect(MySQL(), user='root', password='', dbname='dvirji_mygann', host='localhost')
subcases<-dbGetQuery(mydb, "SELECT * FROM `transactionsNew`")
# items<-dbGetQuery(mydb, "SELECT Distinct(ProductId) FROM `transactions`")
# tx<-dbGetQuery(mydb, "SELECT Distinct(transactionId) FROM `transactions`")


head(subcases$productId)

amazonTrans <- as(split(subcases[,"productId"], subcases[,"transactionId"]), "transactions")

## the detach of tm is required as it also has a inspect() fucntion which is different than the arules. Other wise you get the 
# error that the inspect cannot work for the rules and association
detach(package:tm, unload=TRUE)


summary(amazonTrans)
inspect(amazonTrans[1:10])

sort(itemFrequency(amazonTrans),decreasing = TRUE)[1:10]

transactionInfo(amazonTrans[1:10])

fsets<- apriori(amazonTrans,parameter = list(support = 0.002, confidence = 0.6,target="rules"))
inspect(fsets)

rules.sorted <- sort(rules, by="lift")

subset.matrix <- is.subset(rules.sorted, rules.sorted)
subset.matrix[lower.tri(subset.matrix, diag=T)] <- NA
redundant <- colSums(subset.matrix, na.rm=T) >= 1
which(redundant)

rules.pruned <- rules.sorted[!redundant]
inspect(rules.pruned)



#####################
# this example shows two things: 
#1.) how to convert the continupus variables to discrete and then convert the dataframe into 
# transactions data frame so that we can work using the association rules
# 2.) How to work with large set of rules. We can subset the rules so that we can find out some interesting associations

data("AdultUCI")
dim(AdultUCI)
summary(AdultUCI)

head(AdultUCI)
AdultUCI[["fnlwgt"]]<-NULL
AdultUCI[["education-num"]]<-NULL


#convert the continuous variable Age to discrete 
AdultUCI[["age"]]<-ordered(cut(AdultUCI[[ "age"]], c(15,25,45,65,100)),
                           labels = c("Young", "Middle-aged", "Senior", "Old"))


AdultUCI[[ "hours-per-week"]] <- ordered(cut(AdultUCI[[ "hours-per-week"]],
                                              c(0,25,40,60,168)),
                                          labels = c("Part-time", "Full-time", "Over-time", "Workaholic"))

AdultUCI[[ "capital-gain"]] <- ordered(cut(AdultUCI[[ "capital-gain"]],
                                           c(-Inf,0,median(AdultUCI[[ "capital-gain"]][AdultUCI[[ "capital-gain"]]>0]),Inf)),
                                          labels = c("None", "Low", "High"))


AdultUCI[[ "capital-loss"]] <- ordered(cut(AdultUCI[[ "capital-loss"]],
                                           c(-Inf,0,median(AdultUCI[[ "capital-loss"]][AdultUCI[[ "capital-loss"]]>0]),Inf)),
                                            labels = c("none", "low", "high"))




#this will convert the data frame to transactions. Also the number of columns woulkd have now increased as all the 
#category values will become column
Adult <- as(AdultUCI, "transactions")
Adult

inspect(Adult[1:10])

summary(Adult)


itemFrequencyPlot(Adult,support=0.1)


rules=apriori(Adult,parameter = list(support=0.01,confidence=0.6))
summary(rules)

rulesSmallIncome=subset(rules,subset=rhs %in% "income=small" & lift>1.2)
summary(rulesSmallIncome)

rulesHighIncome=subset(rules,subset=rhs %in% "income=large" & lift>1.2)
summary(rulesHighIncome)


inspect(sort(rulesSmallIncome,by="confidence")[1:5])


#######################################
#Using sampling to derive insights in case the number of transactions is large
# a good sapling size is determined by the formula
# n =???2ln(c)/support * e^2

# where confidence= 1-c
#epsilon is the acceptable error rate

data("Adult")
Adult
supp <- 0.05
epsilon <- 0.1
c <- 0.1  #which means confidence of 0.9
n <- -2 * log(c)/ (supp * epsilon^2)

AdultSample <- sample(Adult, n, replace = TRUE)


#we can draw a overllaping plot of the sample and the populatuion
itemFrequencyPlot(AdultSample, population = Adult, support = supp, cex.names = 0.7)



######
##using rattle
suppressWarnings(suppressMessages(library(rattle)))
rattle()
