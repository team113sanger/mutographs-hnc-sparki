library(ggplot2)
library(ggpubr)
library(dplyr)
library(here)

sparki_res_path <- here::here("results/sparki-nf/sparki/final_table_with_pvalues.csv")
sparki_res <- read.csv(sparki_res_path)
sparki_res_hpv <- sparki_res |> 
    dplyr::filter(species == "Alphapapillomavirus_9") |>
    dplyr::select(sample, ratio_clade)

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
    legend_title
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
            legend.title = element_text(size = 8),
            legend.text = element_text(size = 7),
            legend.direction = "vertical",
            legend.justification = c("left", "top"),
            legend.box.margin = margin(0, 0, 0, 0),
            legend.margin = margin(0, 0, 0, 0),
            legend.key.height = unit(0.35, "cm"),  
            legend.key.width = unit(0.35, "cm"),
            legend.spacing = unit(0, "cm"),     
            legend.spacing.y = unit(0, "cm"),
            plot.margin = margin(0, 0, 0, 0)
        )
    if (colour_type == "continuous") {
        tile_plot <- tile_plot + scale_fill_distiller(
            palette = colours, 
            direction = 1, 
            name = legend_title
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
        axis.text.x = element_text(size = 8, angle = 90, hjust = 0.5, vjust = 0.5),
        axis.title.x = element_blank(),
        axis.title.y = element_text(size = 8)
    )

plot2 <- make_tile_plot("ratio_clade", "continuous", "Reds", "Minimiser proportion")
plot3 <- make_tile_plot("genome_coverage", "continuous", "Blues", "Proportion of genome covered")
plot4 <- make_tile_plot("duplicate_ratio", "continuous", "Greens", "# Duplicates / # All reads")
plot5 <- make_tile_plot("log10all", "continuous", "Oranges", "log10(# All reads)")
plot6 <- make_tile_plot("hpv_status", "discrete", c("gray", "purple"), "HPV status (Torrens et al.)")

plots_combined_list <- list(
    plot1,
    plot2 + theme(legend.position = "none"),
    plot3 + theme(legend.position = "none"),
    plot4 + theme(legend.position = "none"),   
    plot5 + theme(legend.position = "none"),   
    plot6 + theme(legend.position = "none")
)

legends_combined_list <- list(
    cowplot::get_legend(plot2),
    cowplot::get_legend(plot3),
    cowplot::get_legend(plot4),
    cowplot::get_legend(plot5),
    cowplot::get_legend(plot6)
)

plots_combined <- cowplot::plot_grid(
    plotlist = plots_combined_list,
    align = "v",
    axis = "lr",
    ncol = 1,
    rel_heights = c(1.8, 0.1, 0.1, 0.1, 0.1, 0.1)
)

legends_combined <- cowplot::plot_grid(
    plotlist = legends_combined_list,
    align = "h",
    axis = "tb",
    nrow = 2,
    rel_widths = c(1, 1, 1, 1, 1)
)

plots_plus_legend <- cowplot::plot_grid(
    plotlist = list(plots_combined, legends_combined),
    align = "hv",
    axis = "tblr",
    ncol = 1,
    rel_heights = c(0.85, 0.5)
)
    
ggpubr::ggexport(
    plots_plus_legend,
    filename = paste0(getwd(), "/test.png"),
    res = 300,
    width = 2200,
    height = 1800
)
