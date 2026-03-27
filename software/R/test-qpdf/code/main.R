
command.arguments <- commandArgs(trailingOnly = TRUE);
data.directory    <- normalizePath(command.arguments[1]);
code.directory    <- normalizePath(command.arguments[2]);
output.directory  <- normalizePath(command.arguments[3]);

print( data.directory );
print( code.directory );
print( output.directory );

print( format(Sys.time(),"%Y-%m-%d %T %Z") );

start.proc.time <- proc.time();

# set working directory to output directory
setwd( output.directory );

##################################################
# library(raster);
# library(rgdal);
# library(sf);
# library(spData);
# library(spDataLarge);

# source supporting R code
code.files <- c(
    # "section-02-02.R",
    # "section-02-03.R",
    # "section-02-04.R",
    # "section-02-05.R"
    );

for ( code.file in code.files ) {
    source(file.path(code.directory,code.file));
    }

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
my.seed <- 7654321;
set.seed(my.seed);

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
my.password <- "B059";

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
dir.protected.PDFs <- "/Users/kennethchu/Documents/protected-PDFs";
print( dir.exists(dir.protected.PDFs) );
print( list.files(dir.protected.PDFs) );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
DF.protected.PDFs <- read.csv(file.path(dir.protected.PDFs,"DF-curated-protected-PDFs.csv"));
print( DF.protected.PDFs );

DF.sorted.PDFs <- DF.protected.PDFs[order(DF.protected.PDFs$date),];
print( DF.sorted.PDFs );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
output.PDF <- "payment-advices.pdf"
qpdf::pdf_combine(
    input    = DF.sorted.PDFs$file.path,
    output   = output.PDF,
    password = my.password
    );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

##################################################
print( warnings() );

print( getOption('repos') );

print( .libPaths() );

print( sessionInfo() );

print( format(Sys.time(),"%Y-%m-%d %T %Z") );

stop.proc.time <- proc.time();
print( stop.proc.time - start.proc.time );
