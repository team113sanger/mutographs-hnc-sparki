# Applying sparki-nf to a real dataset

We subjected 46 oropharyngeal head & neck cancer (HNC) samples from the study by [Torrens et al. 2025](https://www.nature.com/articles/s41588-025-02134-0) to analysis with [sparki-nf](https://github.com/team113sanger/sparki-nf). The parameters used by the pipeline are given in the `commands/sparki_params.json` file. The SPARKI outputs for this cohort is located at `results/sparki`.

To generate the final publication figure, we first pulled a [SPARKI](https://github.com/team113sanger/sparki) image from Quay.io and then started a container as follows:
```bash
docker pull quay.io/team113sanger/sparki:1.0.0
docker run -it -v ~/git_clones/mutographs-hnc:/opt/data/ quay.io/team113sanger/sparki:1.0.0
```

Once inside the container and in an R shell, we used the function `SPARKI::plotMinimisers_dotplot()` to generate the figure `results/final_figure_Viruses_propMinimisers_and_pvalues.pdf`
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