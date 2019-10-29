// This module defines the global updateables list, and the UpdateableSprite
// class, which is injected into the class hierarchy between Sprite and Animated
// (from the system spriteControllers module).


// global list of anything with an .update(dt) method:
globals.updateables = []

// UpdateableSprite class
globals.UpdateableSprite = new Sprite
UpdateableSprite.normalScale = Animated.normalScale
UpdateableSprite.flippedScale = Animated.flippedScale

UpdateableSprite.init = function(x=0, y=0)
	self.x = x
	self.y = y
	self.scale = Animated.normalScale

	listUtil.removeVal disp.sprites, self	
	disp.sprites.push self

	listUtil.removeVal updateables, self
	updateables.push self
end function

UpdateableSprite.hide = function()
	listUtil.removeVal disp.sprites, self
	listUtil.removeVal updateables, self
end function

spriteControllers.Animated.__isa = UpdateableSprite

// Function to update all the updateables
update = function(dt=0.1)
	for u in updateables
		u.update dt
	end for	
end function
