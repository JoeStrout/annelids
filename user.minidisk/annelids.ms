clear

import "spriteControllers"
import "listUtil"
import "MenuUtils"

MenuDisplay = MenuUtils.MenuDisplay
// Prepare a menu, but don't show it yet
menu = MenuDisplay.make(480, 320)


// Copy stuff from spriteControllers module into our global space,
// since we'll be using it a lot and it's just handy.
for kv in spriteControllers
	if kv.key[0] == "_" then continue
	globals[kv.key] = @kv.value
end for

text.row = 25
text.color = color.yellow
print "ANNELIDS"
text.color = color.gray
print "very early prototyping work"
print "click to make a crater; right-click to open radial menu"
_printMark "(press `Esc` to exit)"
text.color = color.orange

disp = display(4)  // (sprites)

getFrames = function(imagePath, width=64, height)
	if height == null then height = width
	frames = []
	p = file.loadImage(imagePath)
	if p == null then
		print "Error: unable to load image at " + imagePath
		exit
	end if
	for row in range(0, p.height / height - 1)
		for col in range(0, p.width / width - 1)
			frames.push p.getImage(width*col, height*row, width, height)
		end for
	end for
	return frames
end function

gfx.clear "#000044"

ground = [[0,200], [600,200], [700,260], [960,300], [960,0], [0,0]]
gfx.fillPoly ground, "#FFCC88"

updateables = []

UpdateableSprite = new Sprite
UpdateableSprite.normalScale = Animated.normalScale
UpdateableSprite.flippedScale = Animated.flippedScale
UpdateableSprite.init = function(x=0, y=0)
	self.x = x
	self.y = y
	self.scale = Animated.normalScale
	disp.sprites.push self
	updateables.push self
end function
UpdateableSprite.destroy = function()
	listUtil.removeVal(disp.sprites, self)
	listUtil.removeVal(updateables, self)
end function
spriteControllers.Animated.__isa = UpdateableSprite

// stationary worm
worm = new spriteControllers.Animated
worm.curAnim = spriteControllers.newAnimation(getFrames("sprites/breath.png"))
worm.init 720, 275
worm.scale = Animated.flippedScale

// moving (slithering) worm
worm = new spriteControllers.Animated
worm.curAnim = spriteControllers.newAnimation(getFrames("sprites/crawl.png"))
worm.init 120, 212
worm.speed = 100
worm.update = function(dt)
	self.x = self.x + self.speed * self.scale[0] * dt
	if worm.x > 590 then self.scale = Animated.flippedScale
	if worm.x < 40 then self.scale = Animated.normalScale
	super.update dt
end function

testBoom = function(x,y)
	innerR = 95
	outerR = 100
	glowColor = color.yellow
	skyColor = gfx.pixel(320,639)
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
	end for
end function

update = function(dt=0.1)
	for u in updateables
		u.update dt
	end for
end function

lastTime = time
lastMouseButton = mouse.button
while not key.pressed("escape")
	dt = time - lastTime
	lastTime = time
	update dt
	if mouse.button and not lastMouseButton and not menu.isVisible then
		testBoom mouse.x, mouse.y
	end if
	
	ctrl = key.pressed("left ctrl") or key.pressed("right ctrl")
	if (mouse.button(1) or (mouse.button and ctrl)) and not menu.isVisible then
		menu.show mouse.x, mouse.y
	end if
	menu.update dt

	lastMouseButton = mouse.button
	yield
end while

key.clear
text.clear
text.row = 25
_printMark "Enter `run` to run again, or `update` to continue for just one step."

