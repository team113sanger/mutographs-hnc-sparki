# Applying sparki-nf to a real dataset

We subjected 46 oropharyngeal head & neck cancer (HNC) samples from the study by [Torrens et al. 2025](https://www.nature.com/articles/s41588-025-02134-0) to analysis with [sparki-nf](https://github.com/team113sanger/sparki-nf). The parameters used by the pipeline are given in the `commands/sparki_params.json` file and the pipeline was launched through `commands/run_sparki-nf.sh`. The SPARKI outputs for this cohort are located at `results/sparki-nf/sparki`. 

We used the [map-to-genome pipeline](https://gitlab.internal.sanger.ac.uk/team113_projects/jb62-projects/map-to-genome) to validate SPARKI hits, mapping the unmapped reads from the HNC samples against the [HPV16 genome](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000863945.3/). The parameters used by the pipeline are given in the `commands/map-to-genome_params.json` file and the pipeline was launched through `commands/run_map-to-genome.sh`. The `map-to-genome` outputs are located at `results/map-to-genome`.

To generate the final publication figures, we first pulled a [SPARKI](https://github.com/team113sanger/sparki) image from Quay.io and then started a container as follows. Note that, to run th `docker run` command as shown below, you need to be inside the `mutographs-hnc` repository directory (i.e. `pwd` should return something like `path/to/mutographs-hnc`).

```bash
docker pull quay.io/team113sanger/sparki:1.0.0
docker run -v $(pwd):/opt/data/ -it quay.io/team113sanger/sparki:1.0.0 bash
```

Once inside the container:

1. Install a few packages & `cd` into the bind mounted directory
```bash
Rscript -e "install.packages('here')"
cd /opt/data
```

2. Generate the final publication-ready minimiser dotplot

```bash
Rscript /opt/data/scripts/make_final_minimiser_plot.R
```

3. Generate the final `map-to-genome` bar plot

```bash
Rscript /opt/data/scripts/make_barplot.R
```

and in an R shell, we used the function `SPARKI::plotMinimisers_dotplot()` to generate the figure `results/final_figure_Viruses_propMinimisers_and_pvalues.pdf`
```R
library(SPARKI)
merged_reports <- readr::read_csv("/opt/data/results/sparki/final_table_with_pvalues.csv")
SPARKI::plotMinimisers_dotplot(
    merged_reports,
    domain="Viruses",
    fig_width=12.5,
    fig_height=8,
    outdir="/opt/data/results/",
    prefix="final_figure"
)
```