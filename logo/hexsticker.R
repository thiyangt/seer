if (!require('hexSticker')) install.packages('hexSticker')
library(hexSticker)
sticker("logo/navy.png", package="seer",
        s_x = 1, s_y = 0.75, s_width=.43,
        p_size = 31,
        h_color="mediumspringgreen", h_fill="navy", p_color = "mediumspringgreen",
        filename="logo/seer.png")
