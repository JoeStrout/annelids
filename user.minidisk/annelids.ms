import "spriteControllers"
for kv in spriteControllers
	if kv.key[0] == "_" then continue
	globals[kv.key] = @kv.value
end for

import "Updateables"
import "DisplayUtils"
import "listUtil"
import "stringUtil"
import "MenuUtils"
import "Projectiles"
import "Reticles"
import "Worms"
import "Spells"
import "CastingUI"
import "StatusUI"

MenuDisplay = MenuUtils.MenuDisplay
// Prepare a menu, but don't show it yet
menu = MenuDisplay.make(480, 320)

allWorms = []
selected = null
for i in range(0,3)
	worm = new Worm
	worm.init 2600+720 - 50*i, 288, Worms.teams[0]
	worm.scale = Animated.flippedScale
	allWorms.push worm
end for

for i in range(0,3)
	worm = new Worm
	worm.init 2600+120 + 50*i, 370, Worms.teams[1]
	worm.scale = Animated.normalScale
	allWorms.push worm
end for

curTeam = Worms.teams[0]

select = function(worm)
	if selected then selected.deselect
	menu.hide
	CastingUI.hide
	if worm != null then worm.select
	selected = worm
end function

handleClick = function()
	// here's a quick hack to detect the "done" button since I'm out of
	// time for today:
	if mouse.x > 875 and mouse.y < 30 then
		globals.curTeam = Worms.teams[1 - Worms.teams.indexOf(curTeam)]
		StatusUI.refresh
		select null
	end if
	
	if CastingUI.isShown and CastingUI.handleClick then return
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

StatusUI.refresh

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
	CastingUI.update dt
	
	if mouse.button and not lastMouseButton then handleClick

	lastMouseButton = mouse.button
	yield
end while

key.clear
text.clear
text.row = 20
text.column = 0
text.color = color.orange
_printMark "Enter `run` to run again, or `update` to continue for just one step."
update = @Updateables.update
