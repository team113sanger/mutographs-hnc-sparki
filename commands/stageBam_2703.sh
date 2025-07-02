#!/bin/bash

PROJDIR="/lustre/scratch125/casm/teams/team113/users/jb62/projects/mutographs-hnc"

module load dataImportExport

stageBam.pl --project 2703 --sample ${PROJDIR}/sample.list --logs ${PROJDIR}/logs/
