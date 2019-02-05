# GeneDrawR
## R script to draw gene models based on coordinates

### Originally by Ryohei Thomas Nakano, PhD; nakano@mpipz.mpg.de
### Last update: 05 Feb 2019

### usage:
```
Rscript ./gene_moleds.R [path_to_input] [path_to_output]
```
[path_to_input]  has to be a relative or an absolute path to the input file, has to be a tab delimited file containing four columns with a header row (start, end, type, and colour; case insensitive)
[path_to_output] has to be a relative or an absolute path to the output file, which should have an appropriate extension such as pdf or png.

## Input files:
start and end columns:   Numeric values that specify gene position

type:                    Either "gene" or "primer", case insensitive

colour:                  Colour code as a text such as #FF0000

[Example input file](input.txt)

[Example output file](output.pdf)


