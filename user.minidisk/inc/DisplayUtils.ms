// This module configures the displays and provides related utility functions,
// including functions to get frames from a sprite sheet, and explosion effects.
//
// See ArchitectureNotes.md in the repo for more info.

clear

text.row = 25
text.color = color.yellow
print "ANNELIDS"
text.color = color.gray
print "very early prototyping work"
//print "click to make a crater; right-click to open radial menu"
print "use mouse to shoot, arrow keys to scroll"
_printMark "(press `Esc` to exit)"
text.color = color.orange

globals.disp = display(4)  // (sprites)

resolveImage = function(imageOrPath)
	if imageOrPath isa string then
		imageOrPath = file.loadImage(imageOrPath)
		if imageOrPath == null then
			print "Error: unable to load image at " + imageOrPath
			exit
		end if
	end if
	return imageOrPath
end function

globals.getFrames = function(imageOrPath, row, column, count, width=64, height=null)
	if height == null then height = width
	frames = []
	p = resolveImage(imageOrPath)
	srcx = column * width
	srcy = p.height - (row+1) * height
	for i in range(column, column + count - 1)
		frames.push p.getImage(srcx, srcy, width, height)
		srcx = srcx + width
	end for
	return frames
end function

globals.getAllFrames = function(imageOrPath, width=64, height)
	if height == null then height = width
	p = resolveImage(imageOrPath)
	return getFrames(p, 0, 0, p.width / width, p.height)
end function

globals.skyColor = "#000044FF"
gfx.clear skyColor, 1920, 320
gfx.scale = 2
gfx.drawImage file.loadImage("levels/TestLevel1.png")

scrollTo = function(x)
	if x < 0 then x = 0
	if x > 2880 then x = 2880
	gfx.scrollX = x
	disp.scrollX = x
end function

screenToWorld = function(screenPos)
	return {"x": screenPos.x + gfx.scrollX, "y": screenPos.y + gfx.scrollY}
end function

worldToScreen = function(worldPos)
	return {"x": worldPos.x - gfx.scrollX, "y": worldPos.y - gfx.scrollY}
end function

// Drop a raw down from the given position, returning the Y coordinate
// of the first terrain pixel found.  If none is found within maxDist,
// then return null.
dropRay = function(worldX, worldY, maxDist=42, step=2)
	minY = worldY - maxDist
	gx = worldX / gfx.scale
	for y in range(worldY / gfx.scale, minY / gfx.scale, -step)
		c = gfx.pixel(gx, y)
		if c != skyColor then return y * gfx.scale
	end for
	return null
end function

scrollTo 2600

keyScroller = {}
keyScroller.update = function(dt=0.1)
	if key.pressed("left") then scrollTo disp.scrollX - 500*dt
	if key.pressed("right") then scrollTo disp.scrollX + 500*dt
end function
updateables.push keyScroller

boomSnd = file.loadSound("sounds/explosion.wav")
boomFrames = getAllFrames("sprites/explosion.png", 128)

// Dig a hole in the terrain.  Note that all parameters here are
// in buffer coordinates, not screen or sprite coordinates.
digTerrain = function(x, y, radius=40)
	innerR = radius
	outerR = radius + 5
	glowColor = color.yellow
	gfx.fillEllipse x-innerR, y-innerR, innerR*2, innerR*2, skyColor

	innerR2 = innerR*innerR
	outerR2 = outerR*outerR
	for cy in range(-outerR, outerR)
		cy2 = cy*cy
		if abs(cy) < innerR then x0 = sqrt(innerR2 - cy2) else x0 = 0
		x1 = sqrt(outerR2 - cy2)
		py = y+cy
		for px in range(x0, x1)
			if gfx.pixel(x+px, py) != skyColor then gfx.setPixel x+px, py, glowColor
			if gfx.pixel(x-px, py) != skyColor then gfx.setPixel x-px, py, glowColor
		end for
		dt = time - lastTime
		if dt > 0.01 then
			lastTime = time
			Updateables.update dt
		end if			
	end for
end function

Explosion = new spriteControllers.Animated
Explosion.init = function(x, y)
	self.curAnim = spriteControllers.newAnimation(boomFrames)
	self.curAnim.fps = 20
	self.curAnim.loop = false
	super.init x, y
	self.scale = 2
	self.dug = false
	boomSnd.play	
end function
Explosion.update = function(dt)
	frame = self.curAnim.curFrame
	if frame == 4 and not self.dug then
		self.dug = true
		digTerrain self.x/gfx.scale, self.y/gfx.scale
	else if frame == self.curAnim.frames.len-1 then
		self.hide
	else
		super.update dt
	end if
end function

doBoom = function(x,y)
	boom = new Explosion
	boom.init x, y
end function