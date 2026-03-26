library(ggplot2)
data = read.table('ML_recruitment_output.tab', header=TRUE, sep='\t')
head(data)
pdf("autometa_plots.pdf")
ggplot( data, aes( x = bh_tsne_x, y = bh_tsne_y, col = ML_expanded_clustering )) + 
	geom_point( aes( alpha = 0.5, size = sqrt( data$length ) / 100 )) + 
	guides( color = 'legend', size = 'none', alpha = 'none' ) + 
	theme_classic() + xlab('BH-tSNE X') + ylab('BH-tSNE Y') + 
	guides( color = guide_legend( title = 'Cluster/bin' ))


ggplot( data, aes( x = bh_tsne_x, y = bh_tsne_y, col = phylum )) + 
	geom_point( aes( alpha = 0.5, size = sqrt( data$length ) / 100 )) + 
	guides( color = 'legend', size = 'none', alpha = 'none' ) + 
	theme_classic() + xlab('BH-tSNE X') + ylab('BH-tSNE Y') + 
	guides( color = guide_legend( title = 'Phylum' ))


ggplot( data, aes( x = cov, y = gc, col = ML_expanded_clustering )) + 
	geom_point( aes( alpha = 0.5, size = sqrt( data$length ) / 100 )) + 
	guides( color = 'legend', size = 'none', alpha = 'none' ) + 
	theme_classic() + xlab('Coverage') + ylab('GC (%)') + 
	guides( color = guide_legend( title = 'Cluster/bin' )) + 
	scale_x_continuous( limits = c( 200, 250 ))
