---
  title: "Statistics 424 Homework 7"
author: "Alex Seo"
date: "December 1, 2019"
output: pdf_document
header-includes:
  - \usepackage{fancyhdr}
- \pagestyle{fancy}
- \fancyhf{}
- \rhead{Seo}
- \lhead{STAT 456 Final project}
- \cfoot{\thepage}
---
  
  <!-- R chunk setup -->
  ```{r setup, include=FALSE}
# global chunk options
knitr::opts_chunk$set(echo = TRUE, comment = NA)

# load and attach add-on packages here
library(knitr)
library(qcc)
library(tidyverse)
library(leaps)
library(MVA)
library(MASS)
```

<!-- Page Break -->
  \newpage

```{r}
airbnb<-read.csv("AB_NYC_2019.csv")
head(airbnb)
summary(airbnb)

#deleting missing values
airbnb<-airbnb[-which(airbnb$review_scores_rating=='na'),]
airbnb<-airbnb[-which(airbnb$latitude=='na'),]
airbnb<-airbnb[-which(airbnb$availability_365=='na'),]
airbnb<-airbnb[-which(airbnb$reviews_per_month=='na'),]
airbnb<-airbnb[-which(airbnb$host_name=='na'),]
airbnb<-airbnb[-which(airbnb$name=='na'),]

#factor to numeric
airbnb$price<-as.numeric(as.character(airbnb$price))
airbnb$latitude<-as.numeric(as.character(airbnb$latitude))
airbnb$longitude<-as.numeric(as.character(airbnb$longitude))
airbnb$minimum_nights<-as.numeric(as.character(airbnb$minimum_nights))
airbnb$number_of_reviews<-as.numeric(as.character(airbnb$number_of_reviews))
airbnb$reviews_per_month<-as.numeric(as.character(airbnb$reviews_per_month))
airbnb$calculated_host_listings_count<-as.numeric(as.character(airbnb$calculated_host_listings_count))
airbnb$availability_365<-as.numeric(as.character(airbnb$availability_365))
airbnb$review_scores_rating<-as.numeric(as.character(airbnb$review_scores_rating))
#deleting outliers
airbnb<-airbnb[-which(airbnb$review_scores_rating>100),]
airbnb<-airbnb[-which(airbnb$price>1000),]
airbnb<-airbnb[-which(airbnb$minimum_nights>90),]
airbnb<-airbnb[-which(airbnb$reviews_per_month>15),]
airbnb<-airbnb[-which(airbnb$calculated_host_listings_count>50),]
airbnb<-airbnb[-which(airbnb$availability_365==0),]
summary(airbnb)

write.csv(airbnb,'airbnb_clean2.csv')

#new data file, delete 3 variables
airbnb<-read.csv('airbnb_clean2.csv')
airbnb<-airbnb[-which(is.na(airbnb$review_scores_rating)),]
airbnb<-airbnb[-which(airbnb$price==0),]
airbnb<-airbnb[-which(airbnb$name=='#NAME?'),]
summary(airbnb)

airbnb_num<-airbnb[,c(9:15)]

#Map of NYC
plot(airbnb$longitude,airbnb$latitude)
round(cor(airbnb_num),4)
#pairs(airbnb_num)
#Ratings by roomtype
mean(airbnb_sample3$review_scores_rating[airbnb_sample3$room_type=='Entire home/apt'])
mean(airbnb_sample3$review_scores_rating[airbnb_sample3$room_type=='Private room'])
mean(airbnb_sample3$review_scores_rating[airbnb_sample3$room_type=='Shared room'])
#Rating by neighborhood
mean(airbnb_sample3$review_scores_rating[airbnb_sample3$neighbourhood_group=='Bronx'])
mean(airbnb_sample3$review_scores_rating[airbnb_sample3$neighbourhood_group=='Brooklyn'])
mean(airbnb_sample3$review_scores_rating[airbnb_sample3$neighbourhood_group=='Manhattan'])
mean(airbnb_sample3$review_scores_rating[airbnb_sample3$neighbourhood_group=='Queens'])
mean(airbnb_sample3$review_scores_rating[airbnb_sample3$neighbourhood_group=='Staten Island'])

#Sampling 10000 based on neighbourhood group
set.seed(777)

a1<-airbnb[which(airbnb$neighbourhood_group=='Bronx'),]
a2<-airbnb[which(airbnb$neighbourhood_group=='Brooklyn'),]
a3<-airbnb[which(airbnb$neighbourhood_group=='Manhattan'),]
a4<-airbnb[which(airbnb$neighbourhood_group=='Queens'),]
a5<-airbnb[which(airbnb$neighbourhood_group=='Staten Island'),]

br_sam<-a1[sample(nrow(a1),232),]
bk_sam<-a2[sample(nrow(a2),4293),]
mh_sam<-a3[sample(nrow(a3),4228),]
qn_sam<-a4[sample(nrow(a4),1164),]
si_sam<-a5[sample(nrow(a5),83),]
airbnb_sample<-rbind(br_sam,bk_sam,mh_sam,qn_sam,si_sam)
summary(airbnb_sample)
#sampling 5000
br_sam<-a1[sample(nrow(a1),115),]
bk_sam<-a2[sample(nrow(a2),2145),]
mh_sam<-a3[sample(nrow(a3),2115),]
qn_sam<-a4[sample(nrow(a4),580),]
si_sam<-a5[sample(nrow(a5),45),]
airbnb_sample2<-rbind(br_sam,bk_sam,mh_sam,qn_sam,si_sam)
summary(airbnb_sample2)
#sampling 1000
br_sam<-a1[sample(nrow(a1),30),]
bk_sam<-a2[sample(nrow(a2),420),]
mh_sam<-a3[sample(nrow(a3),400),]
qn_sam<-a4[sample(nrow(a4),140),]
si_sam<-a5[sample(nrow(a5),10),]
airbnb_sample3<-rbind(br_sam,bk_sam,mh_sam,qn_sam,si_sam)
summary(airbnb_sample3)
#plot&cor
plot(airbnb_sample3$longitude,airbnb_sample3$latitude)

map<-data.frame(longitude = airbnb_sample3$longitude, latitude = airbnb_sample3$latitude)
ggplot(map, aes(x = longitude, y = latitude)) +
  geom_point()

panel.boxplot <- function(x, ...) {
  usr <- par("usr"); on.exit(par(usr))
  par(usr = c(usr[1:2], 0, 1.5) )
  b <- boxplot.stats(x, do.conf = FALSE)
  arrows(b$stats[1], 0.5, b$stats[5], 0.5, angle=90, length=0.1, code=3)
  rect(b$stats[2], 0.3, b$stats[4], 0.7, col="yellow", ...) 
  segments(b$stats[3], 0.3, y1=0.7, lwd=3, lend=1)
  if(n <- length(b$out))
    points(b$out, rep(0.5, n), pch=1)
  box()
} # https://rdrr.io/github/mikemeredith/MMmisc/src/R/panel_functions.R

pairs(airbnb_sample3[,c(10,13,14)],
      diag.panel = panel.boxplot,
      panel = function(x,y){
        data <- data.frame(cbind(x,y))
        par(new = TRUE)
        den <- bvbox(data, method = "Robust",col = rgb(red = 0.02, green = 0.02, blue = 0.02, alpha = 0.2))
      })


#airbnb_num2<-airbnb_sample[,c(9:15)]

airbnb_num1<-airbnb_sample3[,c(9:15)]#all numerical variables

#One hot encoding for location,roomtype variable
dumm=as.data.frame(model.matrix(~airbnb_sample3$neighbourhood_group)[,-1])
dumm2=as.data.frame(model.matrix(~airbnb_sample3$room_type)[,-1])

abs3<-cbind(airbnb_sample3,dumm,dumm2)
airbnb_num2<-abs3[,c(9,12,15:19)]#price,reviewpermonth,rating,location
airbnb_num3<-abs3[,c(9,12,15,20,21)]#price,reviewpermonth,rating,roomtype
airbnb_num<-abs3[,c(9:21)]#all

round(cor(airbnb_num2),4)
pairs(airbnb_num2)
#pca
ab.pca<-princomp(airbnb_num2,cor = T)
summary(ab.pca)
z1<-ab.pca$scores[,1]
z2<-ab.pca$scores[,2]
z<-cbind(z1,z2)
plot(z1,z2,xlab="PC1",ylab="PC2") 
e<-eigen(cor(airbnb_num2))
sum(e$values)


ab.pca$loadings
pcaplot <- data.frame(PC1 = z1, PC2 = z2)
ab.pca$scores

ggplot(pcaplot, aes(x = PC1, y = PC2)) +
  geom_point()
#screeplot for pca
eigvals<-ab.pca$sdev^2
k<-length(eigvals)
plot(1:k,eigvals,type="b",xlab="i",ylab=expression(lambda[i]))

#bivariate boxplot
x1<-airbnb_num[,c("price","availability_365")]
bvbox(x1,main="Nonrobust",xlab='price',ylab='availability',method="nonrobust")
bvbox(x1,main="Robust",xlab='price',ylab='availability',method="robust")
#star plot
stars(airbnb_sample3[1:100,c(9,11,12,15)])
#face plot
library(vegan)
faces2(airbnb_sample3[1:100,c(9,11,12,15)])
#pca biplot
biplot(ab.pca,pc.biplot = T)

ggplot2::autoplot(ab.pca,label = F, loadings.label = T)

#Canonical correlation
summary(airbnb_num)
round(cor(airbnb_num),4)

X1<-scale(airbnb_num2$price)
X2<-scale(airbnb_num2$availability_365)
Y1<-scale(airbnb_num2$reviews_per_month)
Y2<-scale(airbnb_num2$review_scores_rating)

round(cor(cbind(X1,X2,Y1,Y2)),4)

cormat<-cor(cbind(X1,X2,Y1,Y2))
r11<-cormat[1:2,1:2];r12<-cormat[1:2,3:4];r22<-cormat[3:4,3:4];r21<-t(r12)

e1<-solve(r11) %*% r12 %*% solve(r22) %*% r21
e2<-solve(r22) %*% r21 %*% solve(r11) %*% r12

(eigen1<-eigen(e1))
(ev1<-eigen1$values)
(cca1<-sqrt(ev1))

(eigen2<-eigen(e2))
(ev2<-eigen2$values)
(cca2<-sqrt(ev2))

(evec1<-eigen1$vectors)
(evec2<-eigen2$vectors)

#kmeans
set.seed(2019)
n<-dim(z)[1]; k<-6
wss<- rep(0,k); xm<-apply(z,2,mean)
for(i in 1:n){
  wss[1]<- wss[1]+sum((z[i,]-xm)^2)
}
for(i in 2:k){
  model<-kmeans(z,i)
  wss[i]<-sum(model$withinss)
}
plot(1:k,wss,type="b",xlab="Number of clusters", ylab="Within cluster sum of squares",main="Screeplot")

#Choose 4 clusters
k<-4
km4<-kmeans(z,k)
for(i in 1:k){
  print(paste("Cluster",i))
  print(which(km4$cluster==i))
}
plot(z1,z2,xlab="PC1",ylab="PC2") 
text(z1,z2,labels = km3$cluster)

df <- data.frame(PC1 = z1, PC2 = z2, cluster = factor(km4$cluster))

ggplot(df, aes(x = PC1, y = PC2, color = cluster)) +
  geom_point()

df2<-data.frame(long = airbnb_sample3$longitude, lat = airbnb_sample3$latitude, cluster = factor(km4$cluster))
ggplot(df2, aes(x = long, y = lat, color = cluster)) +
  geom_point()

#MLE Clustering
library(mclust)
mclus_default<-Mclust(z)

mclass<-mclus_default$classification
k<-mclus_default$G
for(i in 3:4){
  print(paste("Cluster",i))
  print(which(mclass == i))
}
(mclus_default$modelName)

df <- data.frame(PC1 = z1, PC2 = z2, cluster = factor(mclass))

ggplot(df, aes(x = PC1, y = PC2, color = cluster)) +
  geom_point()

df2<-data.frame(long = airbnb_sample3$longitude, lat = airbnb_sample3$latitude, cluster = factor(mclass))
ggplot(df2, aes(x = long, y = lat, color = cluster)) +
  geom_point()

airbnb_sample3[which(mclass==3 & airbnb_sample3$number_of_reviews>50 & airbnb_sample3$review_scores_rating>95 & airbnb_sample3$price<100 & airbnb_sample3$room_type=='Entire home/apt'),]
airbnb_sample3[which(airbnb_sample3$id==25309799),]



```

<!-- Page Break -->
  \newpage

## Code Appendix
```{r ref.label=knitr::all_labels(), echo = T, eval = F}
```