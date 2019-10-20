// This module creates the targeting reticle that appears when you are preparing
// to shoot (including the charge-up indicator when you are actually shooting).

chargeInd = new Sprite
chargeInd.image = file.loadImage("sprites/chargeIndicator.png")
chargeSound = file.loadSound("sounds/weapon-charge.wav")

globals.reticle = new UpdateableSprite
reticle.image = file.loadImage("sprites/reticle.png")
reticle.anchorX = 0		// position of the worm (point we rotate around)
reticle.anchorY = 0
reticle.radius = 100	// distance between anchor and actual reticle
reticle.isVisible = false
reticle.isCharging = false
reticle.chargeTime = 0

reticle.init = function(x, y)
	super.init x, y
	self.anchorX = x
	self.anchorY = y
	self.tint = color.red
	self.isVisible = true
	self.update
end function

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
			chargeInd.rotation = atan(dy, dx) * 180/pi
			chargeInd.scale = self.chargeTime
			chargeInd.tint = color.rgba(255, 255-200*self.chargeTime, 0, 128)
		end if
	end if
end function

reticle.fire = function(dx, dy, chargeTime)
	// caller should override or replace this!
end function

reticle.hide = function()
	super.hide
	self.isVisible = false
end function
