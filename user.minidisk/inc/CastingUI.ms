// Provides functions for drawing the UI involved in casting spells
// (radial menu of elements, etc.)

elementsPic = file.loadImage("/usr/ui/ElementButtons.png")

elementPics = getFrames(elementsPic, 0, 0, 4) + getFrames(elementsPic, 1, 0, 4)

elementSprites = []
for p in elementPics
	spr = new Sprite
	spr.image = p
	spr.localBounds = new Bounds
	spr.localBounds.width = p.width
	spr.localBounds.height = p.height
	elementSprites.push spr
end for

// Having to do this module trick is a bit lame.  Need to think about
// how to get something like this built-in -- access to the "file" scope,
// without leaking into the real global scope.
module = {}
module.isShown = false

show = function(worldPos)
	if module.isShown then hide
	r = 80
	for i in range(0,7)
		ang = pi/2 + i*pi/4
		spr = elementSprites[i]
		spr.x = worldPos.x + r * cos(ang)
		spr.y = worldPos.y + r * sin(ang)
		disp.sprites.push spr
	end for
	module.isShown = true
end function

hide = function()
	if not module.isShown then return
	for p in elementSprites
		listUtil.removeVal disp.sprites, p
	end for
	module.isShown = false
end function
