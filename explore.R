# waterfall preliminary analysis
library(data.table)
library(pracma)
library(matlab)
library(gplots)
library(rARPACK)
setwd("~/waterfallDMD") 

# Reading and checking data
data.sm = fread("data/waterfall_sm.csv")
# data = fread("data/waterfall.csv.gz")
dim(data.sm) # 380 x (265 x 471)
# dim(data) # 380 x (942 x 530)
n = dim(data.sm)[1]
mat.dim = c(265, 471)

# SVD of the small data
svd.sm = svd(data.sm)
u.sm = svd.sm$u
v.sm = svd.sm$v
s.sm = svd.sm$d

# plot singular values
semilogy(1:n, s.sm, main = "All Singular Values", 
         xlab = "Singular Value Index", ylab = "log(Singular Values)")
semilogy(1:50, s.sm[1:50], main = "Top Singular Values", 
         xlab = "Singular Value Index", ylab = "log(Singular Values)")
abline(v = 5.5, col = 'red')
# we will keep top 5 and reconstruct the CSV:
r = 5
data.sm.recon = u.sm[,1:r] %*% diag(s.sm)[1:r,1:r] %*% t(v.sm[,1:r])
saveRDS(data.sm.recon, "output/waterfall_265x471_rank5.rds")
write.csv(data.sm.recon, "output/waterfall_265x471_rank5.csv")

# We will also generate top 1-4 for comparison: 
data.sm.recon = (u.sm[,1] * s.sm[1]) %*% t(as.matrix(v.sm[,1]))
rds.path = paste0("output/waterfall_265x471_rank1.rds")
saveRDS(data.sm.recon, rds.path)
csv.path = paste0("output/waterfall_265x471_rank1.csv.gz")
write.csv(data.sm.recon, file = gzfile(csv.path))

for (r in 2:4){
  print(paste("saving", r))
  data.sm.recon = u.sm[,1:r] %*% diag(s.sm)[1:r,1:r] %*% t(v.sm[,1:r])
  rds.path = paste0("output/waterfall_265x471_rank", r, ".rds")
  saveRDS(data.sm.recon, rds.path)
  csv.path = paste0("output/waterfall_265x471_rank", r, ".csv.gz")
  write.csv(data.sm.recon, file = gzfile(csv.path))
}


# Calculate variance of each pixel (original matrix)
ranges = t(apply(X = data.sm, MARGIN = 2, FUN = range))
diffs = ranges[,2] - ranges[,1]
diffs.std = diffs/max(diffs)
diffs.std.mat = matrix(diffs.std, mat.dim[1], mat.dim[2], byrow = T)


# plot intensity matrix: 
heatmap.2(diffs.std.mat, Rowv = FALSE, Colv = FALSE, dendrogram = 'none', 
          margins = c(6,12), col = jet.colors(100), trace = "none", 
          labRow = FALSE, labCol = FALSE, key.title = "Color Key", 
          keysize = 0.9, key.par = list(cex=0.5), key.xlab = "value", 
          density.info = "none", main = "Variance of full matrix")

# Read data from output: 
csv.path = paste0("output/waterfall_265x471_rank5.csv.gz")
data.sm.recon = fread(csv.path)

# Calculate variance of each pixel (rank 1)
data.sm.rank1 = (u.sm[,1] * s.sm[1]) %*% t(as.matrix(v.sm[,1]))
data.sm.rank2 = u.sm[,1:2] %*% diag(s.sm)[1:2,1:2] %*% t(v.sm[,1:2])
ranges = t(apply(X = data.sm.rank2, MARGIN = 2, FUN = range))
diffs = ranges[,2] - ranges[,1]
diffs.std = diffs/max(diffs)
diffs.std.mat = matrix(diffs.std, mat.dim[1], mat.dim[2], byrow = T)


# plot intensity matrix: 
heatmap.2(diffs.std.mat, Rowv = FALSE, Colv = FALSE, dendrogram = 'none', 
          margins = c(6,12), col = jet.colors(100), trace = "none", 
          labRow = FALSE, labCol = FALSE, key.title = "Color Key", 
          keysize = 0.9, key.par = list(cex=0.5), key.xlab = "value", 
          density.info = "none", main = "Variance of rank 2 matrix")
