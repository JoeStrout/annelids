// This module defines the Projectile class, for anything you throw.

kGravity = -5000

globals.Projectile = new UpdateableSprite
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
	DisplayUtils.doBoom self.x, self.y
	self.hide
end function

