# waterfall preliminary analysis
library(data.table)
library(pracma)
setwd("~/waterfallDMD") 

# Reading and checking data
data.sm = fread("data/waterfall_sm.csv.gz")
# data = fread("data/waterfall.csv.gz")
dim(data.sm) # 380 x (265 x 471)
# dim(data) # 380 x (942 x 530)
n = dim(data.sm)[1]

# SVD of the small data
svd.sm = svd(data.sm)
u.sm = svd.sm$u
v.sm = svd.sm$v
s.sm = svd.sm$d

# plot singular values
semilogy(1:n, s.sm, main = "All Singular Values", 
         xlab = "Singular Value Index", ylab = "log(Singular Values)")
semilogy(1:40, s.sm[1:40], main = "Top Singular Values", 
         xlab = "Singular Value Index", ylab = "log(Singular Values)")

# we will keep top 5 and reconstruct the CSV:
r = 5
data.sm.recon = u.sm[,1:r] %*% diag(s.sm)[1:r,1:r] %*% t(v.sm[,1:r])
saveRDS(data.sm.recon, "output/waterfall_265x471_rank5.rds")
write.csv(data.sm.recon, "output/waterfall_265x471_rank5.csv")

