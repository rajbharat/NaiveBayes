library(VIM)
library(lattice)
library(mice)
library(ggplot2)
library(naniar)
#install.packages("naniar",dependencies=TRUE)

setwd("~/GITHUB/datascience-NUS/NaiveBayes/#temp")
#replace blank with NA
vehicle_safety = read.csv("vehicle_safety_NASS2010_2000_2012.csv", header=T, na.strings=c("","NA"))

str(vehicle_safety)
summary(vehicle_safety)

#bind_shadow(vehicle_safety)
#nabular(vehicle_safety)


#data analysis - Missing data
gg_miss_var(vehicle_safety)
gg_miss_upset(vehicle_safety)
gg_miss_fct(x = vehicle_safety, fct = OA_MAIS)+theme_classic()+labs("Missing Values by variable for the predictor")
gg_miss_which(vehicle_safety) +theme_classic()+labs("Missing Values by variable for the predictor")


#remove vaalues whose target variable values are unknown 
vehicle_safety_Clean <- vehicle_safety[!(is.na(vehicle_safety$OA_MAIS) | vehicle_safety$OA_MAIS == ""), ]
summary(vehicle_safety_Clean)

#individual variables missing plot - Top 3 missing data variables
vehicle_safety %>%
  bind_shadow() %>%
  ggplot(aes(x = OA_MAIS ,
             fill = GV_DVLONG_NA )) + 
  geom_density(alpha = 0.5)

vehicle_safety %>%
  bind_shadow() %>%
  ggplot(aes(x = OA_MAIS ,
             fill = GV_ENERGY_NA  )) + 
  geom_density(alpha = 0.5)


vehicle_safety %>%
  bind_shadow() %>%
  ggplot(aes(x = OA_MAIS ,
             fill = GV_DVLAT_NA   )) + 
  geom_density(alpha = 0.5)

gg_miss_upset(vehicle_safety,order.by = "freq")+theme_gray()
#gg_miss_case(vehicle_safety)

vehicle_safety_nummeric <- subset(vehicle_safety_Clean, select = -c(OA_MANUSE,VE_GAD1))

#continuous variables
summary(vehicle_safety_Clean)
write.csv(vehicle_safety_Clean,"vehicle_safety_nummeric.csv")


md.pattern(vehicle_safety_nummeric)


mice_plot <- aggr(vehicle_safety_nummeric, col=c('yellow','red'),
                  numbers=TRUE, sortVars=TRUE, bars=TRUE, prop = TRUE,
                  labels=names(vehicle_safety_nummeric), cex.axis=.7,
                  gap=3, ylab=c("Missing data over columns","Overall Missing Plot"))

#PMM Impute

vehicle_safety_pmm <- mice(vehicle_safety_nummeric, m=2, maxit = 100, method = 'pmm', seed = 500)
vehicle_safety_pmm$imp$GV_CURBWGT
#Final Input File
vehicle_safety_final <- complete(vehicle_safety_pmm,2)
summary(vehicle_safety_final)
write.csv(vehicle_safety_final,"vehicle_safety_final.csv")



