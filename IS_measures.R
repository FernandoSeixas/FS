#mean
mymean = sum(as.numeric(a[,1]*a[,2]))/sum(a[,2])

#median
half = sum(a[,2])/2
count = 0
for (i in 1:length(a[,2])) {
  count = count + a[i,2] 
  if (count < half) {next}
  if (count > half) {mymedian = (a[i,1]); break}
}

#standard deviation
mystdeviation = sqrt(sum((((a[,1]-mymean)^2)*a[,2]))/sum(a[,2]))

mymean
mymedian
mystdeviation