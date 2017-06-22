##from https://rawgit.com/mhahsler/Introduction_to_Data_Mining_R_Examples/master/chap6.html


data(Zoo, package="mlbench")
head(Zoo)
summary(Zoo)

# you caa
try(trans <- as(Zoo, "transactions"))
colnames(Zoo)[13]

legs <- Zoo[["legs"]]
summary(legs)
table(legs)


# we can simply say has legs or doesnot have legs
has_legs <- legs>0
has_legs

Zoo[["legs"]] <- has_legs

trans <- as(Zoo, "transactions")
trans

inspect(trans)

image(trans)

summary(trans)


#convert all the columns as factor variables
Zoo2 <- Zoo
for(i in 1:ncol(Zoo2)) 
  Zoo2[[i]] <- as.factor(Zoo2[[i]])


sapply(Zoo2, class)

trans2<-as(Zoo2,"transactions")
summary(trans2)
itemFrequencyPlot(trans2,topN=10)


is <- apriori(trans2, parameter=list(target="frequent", support=0.5))
is<-apriori(trans2, parameter=list(target="frequent", support=0.5,minlen=3),
               appearance = list(rhs=c("domestic=FALSE","domestic=TRUE"), default="lhs"), control = list(verbose=F))

summary(is)
inspect(is[size(is)>4])
# you can pass the set of itemsets that you think make sense for the rule generation
rulesFromFsets <- ruleInduction(is[size(is)>4],trans2,0.8)
inspect(rulesFromFsets)



