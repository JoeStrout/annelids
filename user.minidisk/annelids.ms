import "spriteControllers"
for kv in spriteControllers
	if kv.key[0] == "_" then continue
	globals[kv.key] = @kv.value
end for

import "Updateables"
import "DisplayUtils"
import "listUtil"
import "MenuUtils"
import "Projectiles"
import "Reticles"
import "Worms"

MenuDisplay = MenuUtils.MenuDisplay
// Prepare a menu, but don't show it yet
menu = MenuDisplay.make(480, 320)

// stationary worm
worm = new Worm
worm.init 2600+720, 288, "blue"
worm.scale = Animated.flippedScale

reticle.init worm.x, worm.y
reticle.fire = function(dx, dy, chargeTime)
	proj = new Projectile
	proj.init self.anchorX, self.anchorY
	proj.vx = dx * 2000 * chargeTime
	proj.vy = dy * 2000 * chargeTime
end function

// moving (slithering) worm
worm2 = new Worm
worm2.init 2600+120, 350, "orange"
worm2.curAnim = worm2.anims.slither
worm2.update = function(dt)
	self.x = self.x + self.walkSpeed * self.scale[0] * dt
	if self.x > 2880 then self.scale = Animated.flippedScale
	if self.x < 2680 then self.scale = Animated.normalScale
	super.update dt
end function

// Main loop
lastTime = time
lastMouseButton = mouse.button
while not key.pressed("escape")
	dt = time - lastTime
	lastTime = time
	Updateables.update dt

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
update = @Updateables.update
