#!/bin/bash
#BSUB -q normal
#BSUB -G team113-grp
#BSUB -R "select[mem>10GB] rusage[mem=10GB] span[hosts=1]"
#BSUB -M 10GB
#BSUB -n 1
#BSUB -o /lustre/scratch125/casm/teams/team113/users/jb62/projects/mutographs-hnc/logs/run_map-to-genome_%J.o
#BSUB -e /lustre/scratch125/casm/teams/team113/users/jb62/projects/mutographs-hnc/logs/run_map-to-genome_%J.e

module load nextflow/22.04.3
module load /software/modules/ISG/singularity/3.11.4

PROJDIR="/lustre/scratch125/casm/teams/team113/users/jb62/projects/mutographs-hnc"

nextflow run "https://gitlab.internal.sanger.ac.uk/team113_projects/jb62-projects/map-to-genome" \
    -r "1.0.2" \
    -params-file ${PROJDIR}/commands/map-to-genome_params.json \
    -profile farm22
