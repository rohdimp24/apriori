##based on the https://www.safaribooksonline.com/library/view/r-for-data/9781784390815/ch09s08.html


load("product_by_user.RData")
summary(product_by_user)
head(product_by_user)
trans = as(product_by_user $Product, "transactions")
summary(trans)
inspect(trans[1:10])
image(trans[1:1000])
itemFrequencyPlot(trans, topN=10, type="absolute")


rules <- apriori(trans, parameter = list(supp = 0.001, conf = 0.1, target= "rules"))
inspect(rules)

#get the quality of the rules
quality(rules)


#using the eclat algo to find the frequent set
frequentsets=eclat(trans,parameter=list(support=0.01,maxlen=10))
summary(frequentsets)
inspect(frequentsets)

#this gives the various measures associated with the frequent Sets
quality(frequentsets)



####traffic dataset
install.packages("arulesSequences")
