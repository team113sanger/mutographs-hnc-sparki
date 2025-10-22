library(ggplot2)
library(ggpubr)
library(dplyr)
library(here)

sparki_res_path <- here::here("results/sparki-nf/sparki/final_table_with_pvalues.csv")
sparki_res <- read.csv(sparki_res_path)
sparki_res_hpv <- sparki_res |> 
    dplyr::filter(species == "Alphapapillomavirus_9") |>
    dplyr::select(sample, ratio_clade, padj) |>
    dplyr::mutate(
        log_padj = -log10(padj)
    )

map_to_genome_res_path <- here::here("results/map-to-genome/collated_mapping_stats.csv")
map_to_genome_res <- read.csv(map_to_genome_res_path)
map_to_genome_res <- map_to_genome_res |> 
    dplyr::mutate(
        log10all = log10(all_count + 1),
        log10mapped = log10(mapped_count + 1),
        duplicate_ratio = (duplicate_count / mapped_count)
    )

torrens_hpv_status_path <- here::here("data/torrens_et_al_hpv16_status_table.csv")
torrens_hpv_status <- read.csv(torrens_hpv_status_path)

map_to_genome_plus_sparki <- dplyr::left_join(
    map_to_genome_res, 
    sparki_res_hpv,
    by = dplyr::join_by(sample)
) |>
    dplyr::mutate(ratio_clade = coalesce(ratio_clade, 0))

map_to_genome_plus_sparki_plus_status <- dplyr::left_join(
    map_to_genome_plus_sparki, 
    torrens_hpv_status,
    by = dplyr::join_by(sample)
)

make_tile_plot <- function(
    fill_category,
    colour_type,
    colours,
    legend_title,
    limits
) {

    tile_plot <- ggplot(
        map_to_genome_plus_sparki_plus_status, 
        aes(
            x = reorder(sample, mapped_count), 
            y = 1, 
            fill = get(fill_category)
        )) +
        geom_tile() +
        theme_void() +
        theme(
            legend.justification = c("left", "top"),
            legend.text = ggplot2::element_text(size = 10),
            legend.title = ggplot2::element_text(size = 12),
            legend.box = "vertical",
            legend.direction = "vertical",
            axis.text = ggplot2::element_blank(),
            axis.ticks = ggplot2::element_blank(),
            axis.title = ggplot2::element_blank(),
            axis.line = ggplot2::element_blank(), 
            plot.margin = ggplot2::unit(c(0, 0, 0, 0), "cm")
        )
    if (colour_type == "continuous") {
        tile_plot <- tile_plot + scale_fill_distiller(
            palette = colours, 
            direction = 1, 
            name = legend_title,
            na.value = "snow3",
            limits = limits
        )
    } else if (colour_type == "discrete") {
        tile_plot <- tile_plot + scale_fill_manual(
            values = colours, 
            name = legend_title
        )
    } else {
        stop(paste0(colour_type), " is not valid!")
    }
}

plot1 <- ggplot(map_to_genome_plus_sparki_plus_status, aes(x = reorder(sample, mapped_count), y = log10mapped)) +
    geom_col(fill = "gray", color = "black") +
    ylab("# Reads mapping to HPV16\n(log10-scaled)") +
    theme_classic() +
    theme(
        axis.text.x = element_text(size = 10, angle = 90, hjust = 0.5, vjust = 0.5),
        axis.title.x = element_blank(),
        axis.title.y = element_text(size = 12)
    )

plot2 <- make_tile_plot("ratio_clade", "continuous", "Reds", "Minimiser proportion", c(0,1))
plot3 <- make_tile_plot("genome_coverage", "continuous", "Blues", "Proportion of genome covered", c(0,1))
plot4 <- make_tile_plot("duplicate_ratio", "continuous", "Greens", "# Duplicates / # All reads", c(0,1))
plot5 <- make_tile_plot(
    "log10all", 
    "continuous", 
    "Oranges", 
    expression("log"[10]~"(# All reads)"), 
    c(min(map_to_genome_plus_sparki_plus_status$log10all), max(map_to_genome_plus_sparki_plus_status$log10all))
)
plot6 <- make_tile_plot("hpv_status", "discrete", c("snow3", "purple"), "HPV status (Torrens et al.)")

legends_combined_list <- list(
    ggpubr::as_ggplot(ggpubr::get_legend(plot2)),
    ggpubr::as_ggplot(ggpubr::get_legend(plot3)),
    ggpubr::as_ggplot(ggpubr::get_legend(plot4)),
    ggpubr::as_ggplot(ggpubr::get_legend(plot5)),
    ggpubr::as_ggplot(ggpubr::get_legend(plot6)),
    NULL
)

legends_combined <- cowplot::plot_grid(
    plotlist = legends_combined_list,
    nrow = 1,
    rel_widths = c(0.35,0.5,0.4,0.3,0.2,0.5)
)

plots_plus_legend_list <- list(
    plot1,
    plot2 + ggplot2::theme(legend.position = "none", plot.margin = ggplot2::unit(c(0, 0, 0, 0), "cm")),
    plot3 + ggplot2::theme(legend.position = "none", plot.margin = ggplot2::unit(c(0, 0, 0, 0), "cm")),
    plot4 + ggplot2::theme(legend.position = "none", plot.margin = ggplot2::unit(c(0, 0, 0, 0), "cm")),   
    plot5 + ggplot2::theme(legend.position = "none", plot.margin = ggplot2::unit(c(0, 0, 0, 0), "cm")),   
    plot6 + ggplot2::theme(legend.position = "none", plot.margin = ggplot2::unit(c(0, 0, 0, 0), "cm")),
    NULL,
    legends_combined
)

png(
    here::here("results/final_figure_map_to_genome_outputs.png"), 
    width = 12, 
    height = 7, 
    units = "in", 
    res = 1200
)
cowplot::plot_grid(
    plotlist = plots_plus_legend_list,
    ncol = 1,
    rel_heights = c(0.4, 0.025, 0.025, 0.025, 0.025, 0.025, 0.02, 0.2),
    align = "v",
    axis = "lr"
)
dev.off()

pdf(
    here::here("results/final_figure_map_to_genome_outputs.pdf"), 
    width = 12, 
    height = 7
)
cowplot::plot_grid(
    plotlist = plots_plus_legend_list,
    ncol = 1,
    rel_heights = c(0.4, 0.025, 0.025, 0.025, 0.025, 0.025, 0.02, 0.2),
    align = "v",
    axis = "lr"
)
dev.off()
