library(ggplot2)
library(splines)

results <- read.table('data/mercer_island_half_2014_results.txt', sep='\t', stringsAsFactors=FALSE, quote='', header=TRUE)

results$SEX <- as.factor(results$SEX)
results$AGE <- as.integer(results$AGE)
results$DIVISION <- as.factor(results$DIVISION)
results$minutes <- matrix(as.integer(unlist(strsplit(results$TIME, ':'))), ncol=3, byrow=TRUE) %*% c(60, 1, 1/60)
#results$seconds <- matrix(as.integer(unlist(strsplit(results$TIME, ':'))), ncol=3, byrow=TRUE) %*% c(3600, 60, 1)

summary(results$minutes)

p <- ggplot(results, aes(minutes))
p + geom_histogram(aes(y = ..density..), binwidth=9, colour='#999999', fill='#aaaaaa') + geom_density(colour='blue') + geom_vline(xintercept = 120, colour="dark green", linetype = "longdash")

p <- ggplot(results, aes(minutes))
p + geom_density(aes(colour=SEX, fill=SEX, alpha=0.3))

p <- ggplot(results, aes(SEX, minutes))
p + geom_boxplot(aes(colour=SEX, fill=SEX, alpha=0.3))


#p <- ggplot(results[results$SEX=='M',], aes(minutes))
#p + geom_histogram() + geom_vline(xintercept = 120, colour="dark green", linetype = "longdash")
#p <- ggplot(results[results$SEX=='F',], aes(minutes))
#p + geom_histogram() + geom_vline(xintercept = 120, colour="dark green", linetype = "longdash")


p <- ggplot(results[results$SEX=='M' & !is.na(results$AGE),], aes(DIVISION, minutes))
p <- p + geom_boxplot(aes(fill=DIVISION))
p <- p + stat_summary(fun.data = function(x) return(data.frame(y=62,label=length(x))), geom = "text")
p <- p + stat_summary(fun.data = function(x) return(data.frame(y=median(x)-3,label=round(median(x)))), geom = "text")
p <- p + annotate("text",x=2,y=67,label="#observations")
p + ggtitle(sprintf("Time to run the Mercer Island Half Marathon (%d Men)", sum(results$SEX=='M' & !is.na(results$AGE))))

p <- ggplot(results[results$SEX=='F' & !is.na(results$AGE),], aes(DIVISION, minutes))
p <- p + geom_boxplot(aes(fill=DIVISION))
p <- p + stat_summary(fun.data = function(x) return(data.frame(y=62,label=length(x))), geom = "text")
p <- p + stat_summary(fun.data = function(x) return(data.frame(y=median(x)-3,label=round(median(x)))), geom = "text")
p <- p + annotate("text",x=2,y=67,label="#observations")
p + ggtitle(sprintf("Time to run the Mercer Island Half Marathon (%d Women)", sum(results$SEX=='F' & !is.na(results$AGE))))

results$age_group <- cut(results$AGE, breaks=c(0,seq(15,70,5),99), right=FALSE)
p <- ggplot(results[!is.na(results$age_group),], aes(age_group, minutes))
p <- p + geom_boxplot(aes(fill=age_group))
# p <- p + stat_summary(fun.data = function(x) return(data.frame(y=min(x[x > quantile(x, 0.25) - IQR(x) * 1.5]) - 3,label=length(x))), geom = "text")
p <- p + stat_summary(fun.data = function(x) return(data.frame(y=62,label=length(x))), geom = "text")
p <- p + stat_summary(fun.data = function(x) return(data.frame(y=median(x)-3,label=round(median(x)))), geom = "text")
p <- p + annotate("text",x=2,y=67,label="#observations")
p <- p + xlab("age")
p + ggtitle(sprintf("Time to run the Mercer Island Half Marathon (%d Runners)", sum(!is.na(results$AGE))))


## Summarize using the function f runners of each unique age
summarize_by_age <- function(results, f) {
  as.data.frame(
    do.call(
      rbind,
      lapply(sort(unique(results$AGE)), function(age) {
        c(age=age, minutes=f(results$minutes[results$AGE==age]))
      })))
}

old.pars <- par(mfrow=c(1,3))
plot(summarize_by_age(na.omit(results), mean), main="Mean")
plot(summarize_by_age(na.omit(results), median), main="Median")
plot(summarize_by_age(na.omit(results), min), main="Min")
par(old.pars)

fastest <- summarize_by_age(na.omit(results[results$SEX=='F',]), min)
plot(fastest$age, fastest$minutes, typ='n',
     xlab='age', ylab='minutes',
     xlim=c(8,80), ylim=c(60,200),
     main='Influence of age on fastest 1/2 marathon times (Women)')

fit = smooth.spline(fastest$age, fastest$minutes, df = 5)

bootstraps <- list()
for (i in 1:1000) {
  bootstrap <- sample(1:nrow(fastest), nrow(fastest), replace=T)
  fit.boot <- smooth.spline(fastest$age[bootstrap], fastest$minutes[bootstrap], df = 5)
  predicted <- predict(fit.boot, 8:80)
  bootstraps[[i]] <- predicted$y
  lines(predicted, col = "#FFdddd10", lwd = 2)
}
points(fastest$age, fastest$minutes)
lines(fit, col = "#FF0080", lwd = 2)

SBS <- do.call(rbind, bootstraps)
se.band.upper <- predict(fit, 8:80)$y + 2*apply(SBS, 2, sd)
lines(8:80, se.band.upper, lty='dashed', col='#aaaaaa')

se.band.lower <- predict(fit, 8:80)$y - 2*apply(SBS, 2, sd)
lines(8:80, se.band.lower, lty='dashed', col='#aaaaaa')


ggplot(fastest, aes(age, minutes)) + geom_point() + geom_smooth()
p
