#!/bin/bash

echo "all_count,unmapped_count,mapped_count" > results/sparki-nf/collated_mapping_stats_pre_filtering.csv
cat results/fastq/*.csv | grep -v "all_count" >> results/sparki-nf/collated_mapping_stats_pre_filtering.csv
