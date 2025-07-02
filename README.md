# mutographs-hnc

```bash
docker pull quay.io/team113sanger/sparki:1.0.0
docker run -it -v ~/git_clones/mutographs-hnc:/opt/data/ quay.io/team113sanger/sparki:1.0.0
```

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