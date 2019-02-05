
# R script to draw gene models based on coordinates
#
# Originally by Ryohei Thomas Nakano, PhD; nakano@mpipz.mpg.de
# Last update: 05 Feb 2019

# usage:
# Rscript ./GeneDrawR.R [path_to_input] [path_to_output]

# [path_to_input]  has to be a relative or an absolute path to the input file, has to be a tab delimited file containing four columns with a header row (start, end, type, and colour; case insensitive)

# start and end columns:   Numeric values that specify gene position
# type:                    Either "gene" or "primer", case insensitive
# colour:                  Colour code as a text such as #FF0000

# [path_to_output] has to be a relative or an absolute path to the output file, which should have an appropriate extension such as pdf or png.





options(warn=-1)

# cleanup
rm(list=ls())


# dependencies
library(ggplot2, quietly=T, warn.conflicts=F)


# functions
geom_polygon_pent <- function(start, end, colour){
	if(start < end){
		shoulder <- end-200
		weight <- 1
	} else {
		shoulder <- end+200
		weight <- -1
	}
	
	geom_polygon(aes(
			 x=c(start, start, shoulder, end, shoulder),
			 y=c(1.2, 0.2, 0.2, 0.7, 1.2)*weight
			 ),
		     fill=colour, color=colour, alpha=.75, size=.5, linetype="solid")
}

geom_polygon_tri <- function(start, end, colour){
	if(start < end){
		weight <- 1
	} else {
		weight <- -1
	}
	
	geom_polygon(aes(
			 x=c(start, start, end),
			 y=c(1.2, 0.2, 0.7)*weight
			 ),
		     fill=colour, color=colour, alpha=.75, size=.5, linetype="solid")
}

geom_arrows <- function(start, end, colour){
	if(start < end){
		weight <- 1
		shoulder <- end-50
	} else {
		weight <- -1
		shoulder <- end+50
	}
	
	geom_path(aes(
		      x=c(shoulder, end, start),
		      y=c(1.5, 1.4, 1.4)*weight
		      ),
		  color=colour, size=.3, linetype="solid")
}

plot_gene <- function(start, end, type, colour){
	if(type == "primer"){
		geom_arrows(start, end, colour)
	}
	else if(type == "gene") {
		if(abs(start - end) < 300){
			geom_polygon_tri(start, end, colour)
		} else {
			geom_polygon_pent(start, end, colour)
		}
	}
}





# arguments
args <- commandArgs(trailingOnly=T)

input  <- args[1]
output <- args[2]


# import
coord <- read.table(file=input, header=T, sep="\t", comment.char="", stringsAsFactors=F)

# ensure case insensitivity
names(coord) <- tolower(names(coord))
coord$type   <- tolower(coord$type)
coord$start  <- as.numeric(coord$start)
coord$end    <- as.numeric(coord$end)

# check
idx <- setequal(names(coord), c("start", "end", "type", "colour"))
if(!idx){
	message("Error: The input file contains wrong column names.")
	q('no')
}

idx <- unique(coord$type) %in% c("primer", "gene")
if( sum(!idx) > 0 | sum(idx) == 0){
	message("Error: The input file contains invalid types.")
	q('no')
}

idx <- is.na(c(coord$start, coord$end))
if(sum(idx) > 0){
	message("Error: The input file containts non-numerical start/end positions.")
	q('no')
}


# setting parameters
x_min <- min(c(coord$start, coord$end))
x_max <- max(c(coord$start, coord$end))
x_lim <- c(x_min-500, x_max+500)


# plot
p <- ggplot() + geom_hline(yintercept=0, size=1, color="black", linetype="solid")

# plot each gene/perimer
for(i in 1:nrow(coord)){
	x <- coord[i,]
	p <- p + plot_gene(x$start, x$end, x$type, x$colour)
}

p <- p +
	xlim(x_lim) +
	ylim(c(-3, 3)) +
	labs(x="Position", y="") +
	theme_bw() +
	theme(axis.text.y=element_blank(),
	      axis.line.y=element_blank(),
	      axis.ticks.y=element_blank(),
	      axis.line.x=element_line(),
	      panel.background=element_rect(fill="transparent", colour=NA),
	      panel.grid=element_blank(),
	      panel.border=element_blank())

# export
ggsave(p, file=output, width=10, height=3, bg="transparent")





