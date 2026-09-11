# R/theme_book.R — one look for every figure in the book.
# Fonts are registered from the vendored fonts/ directory so no system install is needed.
library(ggplot2)

# Registers a family from fonts/ unless the system or a previous call already provides it.
register_book_fonts <- function(fonts_dir = "fonts") {
  known <- c(systemfonts::system_fonts()$family, systemfonts::registry_fonts()$family)
  register <- function(name, plain, bold, italic, bolditalic) {
    if (name %in% known) return(invisible(FALSE))
    systemfonts::register_font(
      name = name,
      plain = file.path(fonts_dir, plain), bold = file.path(fonts_dir, bold),
      italic = file.path(fonts_dir, italic), bolditalic = file.path(fonts_dir, bolditalic))
    invisible(TRUE)
  }
  register("Libertinus Serif", "LibertinusSerif-Regular.otf", "LibertinusSerif-Bold.otf",
           "LibertinusSerif-Italic.otf", "LibertinusSerif-BoldItalic.otf")
  register("Source Sans 3", "SourceSans3-Regular.otf", "SourceSans3-Bold.otf",
           "SourceSans3-It.otf", "SourceSans3-BoldIt.otf")
  invisible(TRUE)
}

book_accent <- "#2457B0"
book_ink <- "#1B1F24"
book_muted <- "#5B6470"

theme_book <- function(base_size = 9) {
  theme_minimal(base_size = base_size, base_family = "Libertinus Serif") +
    theme(
      text = element_text(colour = book_ink),
      axis.title = element_text(size = base_size, colour = book_muted),
      axis.text = element_text(size = base_size - 1, colour = book_muted),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(colour = "#E4E4DF", linewidth = 0.3),
      legend.position = "bottom",
      legend.title = element_blank(),
      plot.title = element_blank(),
      plot.margin = margin(4, 8, 4, 4))
}

# save_fig: write figures/chNN/<name>.svg at print width. Default width is the text block (134 mm).
save_fig <- function(plot, name, chapter, width_mm = 134, height_mm = 80) {
  dir <- file.path("figures", sprintf("ch%02d", as.integer(chapter)))
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  path <- file.path(dir, paste0(name, ".svg"))
  svglite::svglite(path, width = width_mm / 25.4, height = height_mm / 25.4)
  print(plot)
  dev.off()
  invisible(path)
}
