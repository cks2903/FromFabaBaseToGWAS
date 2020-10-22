library(ggplot2)
library(gplots) 
library(reshape)
library(RColorBrewer)
args=commandArgs(trailingOnly = TRUE)


GRM <- read.table(args[1],sep=",", header=TRUE)
dim(GRM)
pal <- colorRampPalette(c("black", "darkslategrey","green"))
my_palette = pal(50)
pdf("GRM.pdf", 7, 7)
heatmap.2(as.matrix(GRM),col=my_palette, distfun=function(x) dist(x,method='euclidian'), hclustfun=function(x) hclust(x,method='ward.D2'), trace='none', dendrogram='both', Rowv=TRUE, Colv=TRUE, scale='none', symkey=T, na.color='grey', density.info='histogram', cexRow=0.2, cexCol=0.2)
dev.off()


GRM=as.matrix(GRM)
GRM_normalized <- GRM/mean(diag(GRM))
pdf("GRM_normalized.pdf", 7, 7)
p_norm=heatmap.2(as.matrix(GRM_normalized),col=my_palette,distfun=function(x) dist(x,method='euclidian'), hclustfun=function(x) hclust(x,method='ward.D2'), trace='none', dendrogram='both', Rowv=TRUE, Colv=TRUE, scale='none', symkey=T, na.color='grey', density.info='histogram', cexRow=0.2, cexCol=0.2)
dev.off()


