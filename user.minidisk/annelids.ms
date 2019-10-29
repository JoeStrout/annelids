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
import "CastingUI"

MenuDisplay = MenuUtils.MenuDisplay
// Prepare a menu, but don't show it yet
menu = MenuDisplay.make(480, 320)

allWorms = []
selected = null
for i in range(0,3)
	worm = new Worm
	worm.init 2600+720 - 50*i, 288, "blue"
	worm.scale = Animated.flippedScale
	allWorms.push worm
end for

for i in range(0,3)
	worm = new Worm
	worm.init 2600+120 + 50*i, 370, "orange"
	worm.scale = Animated.normalScale
	allWorms.push worm
end for

select = function(worm)
	if selected then selected.deselect
	menu.hide
	CastingUI.hide
	if worm != null then worm.select
	selected = worm
end function

handleClick = function()
	if selected and selected.handleClick then return
	p = DisplayUtils.screenToWorld(mouse)
	for worm in allWorms
		if worm.contains(p) then
			select worm
			return
		end if
	end for
	select null
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
	menu.update dt

	if mouse.button and not lastMouseButton then handleClick

	lastMouseButton = mouse.button
	yield
end while

key.clear
text.clear
text.row = 25
_printMark "Enter `run` to run again, or `update` to continue for just one step."
update = @Updateables.update
