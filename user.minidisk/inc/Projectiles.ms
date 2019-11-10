// This module defines the Projectile class, for anything you throw.

import "mathUtil"

kGravity = -5000

globals.Projectile = new UpdateableSprite
Projectile.image = file.loadImage("sprites/circle32.png")
Projectile.vx = 1000
Projectile.vy = 1000
Projectile.rotate = true		// whether to rotate to face direction of travel
Projectile.angleOffset = 0		// amount to add to rotation, in degrees
Projectile.normalScale = [1, 1]
Projectile.flippedScale = [-1, 1]
Projectile.boomRadius = 50
Projectile.boomDamage = 80
Projectile.boomForce = 500

rad2deg = 180/pi

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
	if self.rotate then
		if self.vx > 0 then
			self.scale = self.normalScale
			self.rotation = atan(self.vy, self.vx) * rad2deg + self.angleOffset
		else
			self.scale = self.flippedScale
			self.rotation = -atan(self.vy, -self.vx) * rad2deg - self.angleOffset
		end if
	end if
	if self.y < 0 then self.hide
end function

Projectile.explode = function()
	effectiveRadius = self.boomRadius + 20	// (accounting for worm radius and shockwave)
	for w in allWorms
		dist = mathUtil.distance(w, self)
		if dist < effectiveRadius then
			// apply damage and push at 100% at half the effective radius or less,
			// scaling to 0 at full radius.			
			if dist < effectiveRadius * 0.5 then
				scale = 1
			else
				scale = (1 - dist/effectiveRadius) * 2
			end if
			impulse = {}
			impulse.x = scale * (w.x - self.x) * self.boomForce / dist
			impulse.y = scale * (w.y - self.y) * self.boomForce / dist + 100
			w.takeDamage self.boomDamage * scale, impulse
		end if
	end for
	DisplayUtils.doBoom self.x, self.y, self.boomRadius
	self.hide
end function

