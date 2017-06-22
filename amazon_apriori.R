##OLD CODE..is replaced by amazon_apriori_revisited

#http://www.r-bloggers.com/implementing-apriori-algorithm-in-r/
library(RMySQL)
mydb = dbConnect(MySQL(), user='root', password='', dbname='dvirji_mygann', host='localhost')
subcases<-dbGetQuery(mydb, "SELECT * FROM `transactions`")
subcases<-dbGetQuery(mydb, "SELECT * FROM `transactionsnew`")
#SELECT * FROM `transactions` group by transactionId having count(transactionId)>1
items<-dbGetQuery(mydb, "SELECT Distinct(ProductId) FROM `transactions`")
tx<-dbGetQuery(mydb, "SELECT Distinct(transactionId) FROM `transactions`")
head(subcases)
df_sorted <- subcases[order(subcases$transactionId),]
#install.packages("plyr", dependencies= TRUE)
library(plyr)

#join the products in the same transaction together
df_itemList <- ddply(subcases,c("transactionId"), 
                     function(df1)paste(df1$productId,collapse = " "))

library(arules)
#save the list to the csv
write.csv(df_itemList,"ItemList.csv", row.names = TRUE)
#read all the transactiions
txn = read.transactions(file="ItemList.csv", rm.duplicates= TRUE, format="basket",sep=",",cols=1)

#print the first 10 transactions
as(txn[1:10],"list")
#basket_rules <- apriori(txn,parameter = list(sup = 0.0001, conf = 0.5,target="rules"));

#now create a matrix which will have the values 1 for the product that 
#are included in the transactiin and 0 if they are not
library(tm)
corpus=Corpus(VectorSource(df_itemList$V1))
dtm = DocumentTermMatrix(corpus,control=list(wordLengths=c(2,Inf)))
dtm

if(sessionInfo()['basePkgs']=="tm" | sessionInfo()['otherPkgs']=="tm"){
  detach(package:tm, unload=TRUE)
}
dtm=as.matrix(dtm)
write.csv(dtm, file="forAmazon.csv")


library(arules)
dtm=read.csv("forAmazon.csv")
dtm=as.matrix(dtm)
dtm=dtm[,2:581]
dtmItemMatrix<-as(dtm,"transactions")
itemFrequencyPlot(dtmItemMatrix, support = 0.02, cex.names=0.8)
fsets<- apriori(dtmItemMatrix,parameter = list(support = 0.002, confidence = 0.6,target="frequent itemsets"))
rulesFromFsets <- ruleInduction(fsets)
inspect(rulesFromFsets)


rules <- apriori(dtmItemMatrix,parameter = list(support = 0.002, confidence = 0.6))
summary(rules)
inspect(rules[1:2])

rules.sorted <- sort(rules, by="lift")

#remove the duplicate rules
subset.matrix <- is.subset(rules.sorted, rules.sorted)
subset.matrix[lower.tri(subset.matrix, diag=T)] <- NA
redundant <- colSums(subset.matrix, na.rm=T) >= 1
which(redundant)

rules.pruned <- rules.sorted[!redundant]
inspect(rules.pruned)
