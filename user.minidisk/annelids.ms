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
print "use mouse to shoot, arrow keys to scroll"
_printMark "(press `Esc` to exit)"
text.color = color.orange

disp = display(4)  // (sprites)

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

getFrames = function(imageOrPath, row, column, count, width=64, height=null)
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

getAllFrames = function(imageOrPath, width=64, height)
	if height == null then height = width
	p = resolveImage(imageOrPath)
	return getFrames(p, 0, 0, p.width / width, p.height)
end function

skyColor = "#000044FF"
gfx.clear skyColor, 1920, 320
gfx.scale = 2
gfx.drawImage file.loadImage("levels/TestLevel1.png")

scrollTo = function(x)
	if x < 0 then x = 0
	if x > 2880 then x = 2880
	gfx.scrollX = x
	disp.scrollX = x
end function

scrollTo 2600

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
chargeSound = file.loadSound("sounds/weapon-charge.wav")

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
	dx = mouse.x + disp.scrollX - self.anchorX
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
		chargeSound.play
	end if
	if self.isCharging then
		if not mouse.button then
			// Fire!
			listUtil.removeVal disp.sprites, chargeInd
			self.isCharging = false
			self.fire dx, dy, self.chargeTime
			chargeSound.stop
		else
			// keep charging
			self.chargeTime = self.chargeTime + dt
			if self.chargeTime > 1 then self.chargeTime = 1
			chargeInd.rotation = atan2(dy, dx) * 180/pi
			chargeInd.scale = self.chargeTime
			chargeInd.tint = color.rgba(255, 255-200*self.chargeTime, 0, 128)
//			chargeSound.init 0.1, 100 + 500 * self.chargeTime
//			chargeSound.play 0.02 + 0.3 * self.chargeTime
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
	// For better collision detection, we'll break this down into 5 intermediate steps:
	dt = dt / 5
	for i in range(1,5)
		self.x = self.x + self.vx * dt
		self.y = self.y + self.vy * dt
		if gfx.pixel(self.x/gfx.scale, self.y/gfx.scale) != skyColor then
			self.explode
			return
		end if
	end for	
	if self.y < 0 then self.hide
end function
Projectile.explode = function()
	doBoom self.x, self.y
	self.hide
end function

// stationary worm
wormSheet = file.loadImage("sprites/sheet-blue.png")
worm = new spriteControllers.Animated
worm.curAnim = spriteControllers.newAnimation(getFrames(wormSheet, 1, 0, 8, 42, 42))
worm.init 2600+720, 288
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
worm2.curAnim = spriteControllers.newAnimation(getFrames(wormSheet, 0, 0, 11, 42, 42))
worm2.init 2600+120, 350
worm2.speed = 100
worm2.update = function(dt)
	self.x = self.x + self.speed * self.scale[0] * dt
	if self.x > 2880 then self.scale = Animated.flippedScale
	if self.x < 2680 then self.scale = Animated.normalScale
	super.update dt
end function

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
			update dt
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

update = function(dt=0.1)
	for u in updateables
		u.update dt
	end for
	if key.pressed("left") then scrollTo disp.scrollX - 500*dt
	if key.pressed("right") then scrollTo disp.scrollX + 500*dt
	
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

