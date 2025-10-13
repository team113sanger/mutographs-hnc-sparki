#!/bin/bash

OUTDIR="./data"

wget -P ${OUTDIR}/ https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/863/945/GCF_000863945.3_ViralProj15505/GCF_000863945.3_ViralProj15505_genomic.fna.gz
gunzip ${OUTDIR}/GCF_000863945.3_ViralProj15505_genomic.fna.gz
