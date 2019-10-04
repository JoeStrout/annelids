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
//print "click to make a crater; right-click to open radial menu"
print "use mouse to aim; hold mouse button to charge shot"
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

groundColor = "#FFCC88FF"
ground = [[0,200], [600,200], [700,260], [960,300], [960,0], [0,0]]
gfx.fillPoly ground, groundColor

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
UpdateableSprite.hide = function()
	listUtil.removeVal disp.sprites, self
	listUtil.removeVal updateables, self
end function
spriteControllers.Animated.__isa = UpdateableSprite

chargeInd = new Sprite
chargeInd.image = file.loadImage("sprites/chargeIndicator.png")
chargeSound = new Sound

reticle = new UpdateableSprite
reticle.image = file.loadImage("sprites/reticle.png")
reticle.anchorX = 0		// position of the worm (point we rotate around)
reticle.anchorY = 0
reticle.radius = 100	// distance between anchor and actual reticle
reticle.isVisible = false
reticle.isCharging = false
reticle.chargeTime = 0
reticle.update = function(dt=0.1)
	if not self.isVisible then return
	dx = mouse.x - self.anchorX
	dy = mouse.y - self.anchorY
	mouseDist = sqrt(dx*dx + dy*dy)
	dx = dx / mouseDist
	dy = dy / mouseDist
	self.x = self.anchorX + dx * self.radius
	self.y = self.anchorY + dy * self.radius
	if mouse.button and not self.isCharging then
		// start charging
		self.isCharging = true
		self.chargeTime = 0
		chargeInd.x = self.anchorX
		chargeInd.y = self.anchorY
		disp.sprites.push chargeInd
	end if
	if self.isCharging then
		if not mouse.button then
			// Fire!
			listUtil.removeVal disp.sprites, chargeInd
			self.isCharging = false
			self.fire dx, dy, self.chargeTime
		else
			// keep charging
			self.chargeTime = self.chargeTime + dt
			if self.chargeTime > 1 then self.chargeTime = 1
			chargeInd.rotation = atan2(dy, dx) * 180/pi
			chargeInd.scale = self.chargeTime
			chargeInd.tint = color.rgba(255, 255-200*self.chargeTime, 0, 128)
			chargeSound.init 0.1, 100 + 500 * self.chargeTime
			chargeSound.play 0.05 + 0.4 * self.chargeTime
		end if
	end if
end function
reticle.init = function(x, y)
	super.init x, y
	self.anchorX = x
	self.anchorY = y
	self.tint = color.red
	self.isVisible = true
	self.update
end function
reticle.hide = function()
	super.hide
	self.isVisible = false
end function

kGravity = -5000

Projectile = new UpdateableSprite
Projectile.image = file.loadImage("sprites/circle32.png")
Projectile.vx = 1000
Projectile.vy = 1000
Projectile.init = function(x=0, y=0)
	super.init x, y
	self.scale = 0.5
end function
Projectile.update = function(dt=0.1)
	self.vy = self.vy + kGravity * dt
	self.x = self.x + self.vx * dt
	self.y = self.y + self.vy * dt
	if gfx.pixel(self.x, self.y) == groundColor then
		self.explode
	else if self.y < 0 then
		self.hide
	end if
end function
Projectile.explode = function()
	doBoom self.x, self.y
	self.hide
end function

// stationary worm
worm = new spriteControllers.Animated
worm.curAnim = spriteControllers.newAnimation(getFrames("sprites/breath.png"))
worm.init 720, 275
worm.scale = Animated.flippedScale

reticle.init worm.x, worm.y
reticle.fire = function(dx, dy, chargeTime)
	proj = new Projectile
	proj.init self.anchorX, self.anchorY
	proj.vx = dx * 2000 * chargeTime
	proj.vy = dy * 2000 * chargeTime
end function

// moving (slithering) worm
worm2 = new spriteControllers.Animated
worm2.curAnim = spriteControllers.newAnimation(getFrames("sprites/crawl.png"))
worm2.init 120, 212
worm2.speed = 100
worm2.update = function(dt)
	self.x = self.x + self.speed * self.scale[0] * dt
	if self.x > 590 then self.scale = Animated.flippedScale
	if self.x < 40 then self.scale = Animated.normalScale
	super.update dt
end function

boomSnd = new Sound
boomSnd.init 1, 100, [1,0], Sound.noiseWave

doBoom = function(x,y)
	boomSnd.play
	
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

//	ctrl = key.pressed("left ctrl") or key.pressed("right ctrl")
//	if (mouse.button(1) or (mouse.button and ctrl)) and not menu.isVisible then
//		menu.show mouse.x, mouse.y
//	end if
//	menu.update dt

	lastMouseButton = mouse.button
	yield
end while

key.clear
text.clear
text.row = 25
_printMark "Enter `run` to run again, or `update` to continue for just one step."

