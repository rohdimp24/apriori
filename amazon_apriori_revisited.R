#######
# Script to find the association rules in the Amazon transactions available from Mygann
#
########

#connect to the DB and fetch all the records. 
library(RMySQL)
mydb = dbConnect(MySQL(), user='root', password='root', dbname='apriori', host='127.0.0.1',port=3306)
subcases<-dbGetQuery(mydb, "SELECT Id,transactionId,AmazonId,SellingDate FROM `amazonTransactions`")

#extract the year in case the analysis has to be done on the transactions occuring for a particular year
subcases$year=strftime(as.POSIXlt(subcases$SellingDate),"%Y")
table(subcases$year)
head(subcases)

#all the trx that occured in year 2017
amazon2017=subset(subcases,subcases$year==2017)

##Note: in case we want to consider the trx of a particular time period say 2017 then to create the amazonTransMaster we will
# use amazon2017 instead of subcases

#These are still not in the form of the transacations in a sense that lot of products that belon to the 
#same transactions are listed in the separate rows. We need to merge them
amazonTransMaster <- as(split(subcases[,"AmazonId"], subcases[,"transactionId"]), "transactions")
summary(amazonTransMaster)

#get the highest support items
itemFrequencyPlot(amazonTransMaster,topN=10)

#list the top 10 items in the decreasing level of the support i.e. how many times does an item occurs in the transactions
nrow(amazonTransMaster)*sort(itemFrequency(amazonTransMaster),decreasing = TRUE)[1:10]


# We want to analyze only those transactions that have ateast two products bought together. If we  take the 
# trx that have only a single product then we will have lot of transactions and the prob will go down as support is 
# total occurence/ total trxs
amazonTrans=amazonTransMaster[size(amazonTransMaster)>1]
summary(amazonTransMaster)

## the detach of tm is required as it also has a inspect() fucntion which is different than the arules. Other wise you get the 
# error that the inspect cannot work for the rules and association
detach(package:tm, unload=TRUE)

inspect(amazonTrans[1:10])

sort(itemFrequency(amazonTrans),decreasing = TRUE)[1:10]

#just the transaction ids
transactionInfo(amazonTrans[1:10])


#now find out the rules. We are looking for high confidence rules
rules<- apriori(amazonTrans,parameter = list(support = 0.001, confidence = 0.8,target="rules"))
inspect(rules)

#sorting the rules by lift
rules.sorted <- sort(rules, by="lift")
inspect(rules.sorted)


##Pruning the rules
#The rules are pruned if they follow the following 
#{a, b}-->{d} ..sub rule 
#{a,b,c}-->{d} ..superrule
#You can remove the superrule (containing more variables) if superrule has a lower or same lift as the sub rule
#note: this particular pruning code is working on windows but not on mac..I guess some version of library issue
subset.matrix <- is.subset(rules.sorted, rules.sorted)
subset.matrix[lower.tri(subset.matrix, diag=T)] <- NA
redundant <- colSums(subset.matrix, na.rm=T) >= 1
which(redundant)

rules.pruned <- rules.sorted[!redundant]
inspect(rules.pruned)

#we want to add another quality measure that is the total number of occurence instead of just showing the support
totalOccurence=nrow(amazonTrans)*quality(rules.pruned)$support
quality(rules.pruned)<-cbind(quality(rules.pruned),totalOccurence)
inspect(rules.pruned)
