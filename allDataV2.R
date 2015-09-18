# using dplyr to summarize alldatav2 dataframe from John Thompson

install.packages("dplyr")
library("dplyr")
install.packages("tidyr")
library("tidyr")

# read R data object from John
allDataV2 = readRDS("MyDataFrame.RDS")

# it seems some original numbers were changed into character in the dataframe
# convert them back to numbers
allDataV2$Current.Active.SDV.Subjects = as.numeric(allDataV2$Current.Active.SDV.Subjects)

# summarize how many active subjects per monitor per TA type, removing NA
#MonSubTotal = summarise(group_by(allDataV2, Site.Monitor, TA), sum(Current.Active.SDV.Subjects, na.rm=T))
MonitorSubtotal = aggregate(allDataV2$Current.Active.SDV.Subjects, by = list(allDataV2$Site.Monitor, allDataV2$TA), FUN = sum, na.rm = T)
MonitorSubtotal = rename(MonitorSubtotal, c("Group.1" = "Monitor", "Group.2" = "TA", "x" = "Subjects"))


# Assign workload weight based on clinical trial type
# CA/CN = 10, IM = 8, CV = 6, MB = 4, AI =2
# use the "toupper" function as there is one "Ai" instead of "AI" in the dataframe
MonTAW = toupper(MonitorSubtotal$TA)

diseases = c("CA", "CN", "IM", "RA", "CV", "MB", "AI")
weights = c(10, 10, 8, 8, 6, 4, 2)

# Add a column "TAweight" to the dataframe
for (i in seq_along(diseases)) {
    MonTAW = gsub(diseases[i], weights[i], MonTAW, perl=TRUE)
  }

MonitorSubtotal$TAweight = MonTAW
MonitorSubtotal$TAweight = as.numeric(MonitorSubtotal$TAweight)

# calculate a work load for each monitor based on disease and patient numbers
MonitorWorkload = mutate(MonitorSubtotal, TAworkload = Subjects * TAweight)
saveRDS(MonitorWorkload, file = "MonitorWorkload.rds")




