library(SPARKI)
library(here)

merged_reports <- readr::read_csv(here::here("results/sparki-nf/sparki/final_table_with_pvalues.csv"))

png(
    here::here("results/final_figure_Viruses_propMinimisers_and_pvalues.png"),
    width = 12.5,
    height = 8,
    units = "in",
    res = 1200
)
SPARKI::plotMinimisers_dotplot(
    merged_reports,
    domain="Viruses",
    fig_width=12.5,
    fig_height=8,
    outdir=NA,
    prefix="",
    return_plot=FALSE
)
dev.off()

pdf(
    here::here("results/final_figure_Viruses_propMinimisers_and_pvalues.pdf"),
    width = 12.5,
    height = 8
)
SPARKI::plotMinimisers_dotplot(
    merged_reports,
    domain="Viruses",
    fig_width=12.5,
    fig_height=8,
    outdir=NA,
    prefix="",
    return_plot=FALSE
)
dev.off()
