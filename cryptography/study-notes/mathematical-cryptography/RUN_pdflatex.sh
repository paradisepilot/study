#!/bin/bash

####################################################################################################
fileStem=mathematical-cryptography

pdflatex ${fileStem}
bibtex   ${fileStem}
pdflatex ${fileStem}
pdflatex ${fileStem}

####################################################################################################

