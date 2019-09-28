//p = file.loadImage("sprites/crawl.png")
p = file.loadImage("sprites/breath.png")
gfx.clear "#000044"

ground = [[0,200], [600,200], [700,260], [960,300], [960,0], [0,0]]
gfx.fillPoly ground, "#FFCC88"

gfx.drawImage p, 0, 200-18
