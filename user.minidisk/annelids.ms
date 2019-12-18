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

select = function(worm)
	if selected then selected.deselect
	menu.hide
	CastingUI.hide
	if worm != null then worm.select
	selected = worm
end function

endTurn = function()
	globals.curTeam = Worms.teams[1 - Worms.teams.indexOf(curTeam)]
	curTeam.actionPoints = curTeam.actionPoints + 4
	StatusUI.refresh
	select null
end function

handleClick = function()
	if StatusUI.handleClick then return	
	if CastingUI.isShown and CastingUI.handleClick then return
	if selected then
		if selected.handleClick then return
		selected.deselect
	end if
	// Now we're going to check for worms... but only if we're not
	// out of AP; and only allow selection of current team worms.
	if curTeam.actionPoints < 1 then return
	p = DisplayUtils.screenToWorld(mouse)
	for worm in curTeam.worms
		if worm.contains(p) then
			select worm
			return
		end if
	end for
	select null
end function

// Start-of-game setup
curTeam = Worms.teams[Worms.teams.len-1]
endTurn	// (makes sure everything is set up for team 0)

// Main loop
lastTime = time
lastMouseButton = mouse.button
while not key.pressed("escape")
	dt = time - lastTime
	lastTime = time
	if dt > 0.02 then dt = 0.02  // step limit, prevents wonkiness on slow systems
	Updateables.update dt

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
text.delimiter = char(13)
_printMark "Enter `run` to run again, or `update` to continue for just one step."
update = @Updateables.update
