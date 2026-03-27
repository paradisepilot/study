
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
dir.protected.PDFs <- "/Users/kennethchu/Documents/Finances/Taxes/zzz-MeeMee/hktreasury-payment-advice";
print( dir.exists(dir.protected.PDFs) );
print( list.files(dir.protected.PDFs) );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# protected.PDFs <- base::list.files(
#     path       = dir.protected.PDFs,
#     pattern    = "\\.pdf$",
#     full.names = TRUE
#     );

# my.file.info <- base::file.info(
#     protected.PDFs,
#     extra_cols = FALSE
#     );

# sorted.protected.PDFs <- protected.PDFs[order(my.file.info$mtime, decreasing = TRUE)];

# DF.sorted.protected.PDFs <- data.frame(
#     file.index = seq(1L,length(sorted.protected.PDFs)),
#     file.path  = sorted.protected.PDFs
#     );
# write.csv(
#     file      = "DF-sorted-protected-PDFs.csv",
#     x         = DF.sorted.protected.PDFs,
#     row.names = FALSE
#     );

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
