// Annelids main program.

// Import the spriteControllers module, and copy all of its identifiers
// into the global space for easy access.
import "spriteControllers"
for kv in spriteControllers
	if kv.key[0] == "_" then continue
	globals[kv.key] = @kv.value
end for

// Import a bunch of other modules.
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
import "AI"

// Prepare a menu, but don't show it yet
// (Note: we're not actually using the radial menu at the moment.
// I thought we would, but we ended up doing everything via the
// casting UI instead.)
menu = MenuUtils.MenuDisplay.make(480, 320)

// desc: return a brief description of the given worm, or "null" if
//		given a null reference.  This is used for debugging.
// Parameters:
//		wormOrNull: a Worm reference (may be null)
// Returns: worm description, or "null"
desc = function(wormOrNull)
	if wormOrNull == null then return "null"
	return wormOrNull.desc
end function

// select: select the given worm, deselecting the previously-selected
//		worm (if any).
// Parameters:
//		worm: worm to select (may be null)
// Returns: null
select = function(worm)
	if selected then selected.deselect
	menu.hide
	CastingUI.hide
	if worm != null then worm.select
	globals.selected = worm
end function

// endTurn: end the current player's turn, and start the turn for the
//		next player.
// Parameters: (none)
// Returns: null
endTurn = function()
	globals.curTeam = Worms.teams[1 - Worms.teams.indexOf(curTeam)]
	curTeam.actionPoints = curTeam.actionPoints + 4
	if curTeam == AI.team then
		reticle.controlPos = AI.aiMouse
	else
		reticle.controlPos = mouse
	end if
	select null
	StatusUI.refresh
end function

// handleClick: deal with a mouse click by passing it off to each of
//		our potential handlers in turn.
// Parameters: (none)
// Returns: null
handleClick = function()
	text.column = 0
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

// Create the worms in their starting configurations.
allWorms = []	// global reference to all Worm instances
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

curTeam = Worms.teams[Worms.teams.len-1]
endTurn	// (makes sure everything is set up for team 0)

// Hook up the AI to the desired team
AI.team = Worms.teams[1]

// Main loop (repeats forever until Escape key is pressed)
lastTime = time
lastMouseButton = mouse.button
while not key.pressed("escape")
	dt = time - lastTime
	lastTime = time
	if dt > 0.02 then dt = 0.02  // step limit, prevents wonkiness on slow systems
	Updateables.update dt

	menu.update dt
	CastingUI.update dt
	AI.update dt
	
	if mouse.button and not lastMouseButton then handleClick

	lastMouseButton = mouse.button
	yield
end while

// Clean-up and exit
key.clear
text.clear
text.row = 20
text.column = 0
text.color = color.orange
text.delimiter = char(13)
_printMark "Enter `run` to run again, or `update` to continue for just one step."
update = @Updateables.update
