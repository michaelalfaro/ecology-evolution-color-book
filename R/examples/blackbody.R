# R/examples/blackbody.R — Planck spectral radiance for three temperatures; the book's first generated figure.
source("R/theme_book.R")
register_book_fonts()

planck <- function(lambda_nm, T) {
  h <- 6.62607015e-34; c <- 2.99792458e8; k <- 1.380649e-23
  l <- lambda_nm * 1e-9
  (2 * h * c^2 / l^5) / (exp(h * c / (l * k * T)) - 1)
}
lambda <- seq(200, 2000, by = 5)
d <- do.call(rbind, lapply(c(3000, 5778, 8000), function(T)
  data.frame(lambda = lambda, T = factor(paste0(T, " K")), B = planck(lambda, T))))
d$B <- ave(d$B, d$T, FUN = function(x) x / max(x))   # each curve peaks at 1, so the Wien shift is the story

p <- ggplot(d, aes(lambda, B, colour = T)) +
  annotate("rect", xmin = 380, xmax = 700, ymin = -Inf, ymax = Inf, fill = "#F1F1EC", alpha = 0.8) +
  geom_line(linewidth = 0.7) +
  scale_colour_manual(values = c("#B3413A", "#DF5A1C", "#2457B0")) +
  labs(x = "Wavelength (nm)", y = "Spectral radiance (relative)") +
  theme_book()
save_fig(p, "blackbody", chapter = 2)
