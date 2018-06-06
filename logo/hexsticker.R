if (!require('hexSticker')) install.packages('hexSticker')
library(hexSticker)
sticker("hexsticker/navy.png", package="seer",
        s_x = 1.07, s_y = 0.5, s_width=.1, s_height=.1, p_y = 1.1,
        p_size = 48,
        h_color="mediumspringgreen", h_fill="navy", p_color = "mediumspringgreen",
        filename="hexsticker/seer.png")

