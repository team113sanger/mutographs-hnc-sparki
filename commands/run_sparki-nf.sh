#!/bin/bash
#BSUB -q normal
#BSUB -G team113-grp
#BSUB -R "select[mem>10GB] rusage[mem=10GB] span[hosts=1]"
#BSUB -M 10GB
#BSUB -n 1
#BSUB -o /lustre/scratch125/casm/teams/team113/users/jb62/projects/mutographs-hnc/logs/run_sparki-nf_%J.o
#BSUB -e /lustre/scratch125/casm/teams/team113/users/jb62/projects/mutographs-hnc/logs/run_sparki-nf_%J.e

module load nextflow/22.04.3
module load /software/modules/ISG/singularity/3.11.4

nextflow run "https://gitlab.internal.sanger.ac.uk/team113_projects/jb62-projects/sparki-nf" \
    -r 6846f25844cc0f4c63d0517c2ec34218d54fd09e \
    -params-file commands/sparki_params.json \
    -profile farm22
