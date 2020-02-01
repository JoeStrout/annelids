// Annelids artificial intelligence (AI) player.

import "listUtil"
import "Ballistics"

// randRange: return a uniformly distributed random number between the
// given minimum and maximum values (including min, but not including max).
randRange = function(min, max)
	return min + (max - min) * rnd
end function

// Which team this AI is responsible for:
team = null

// Currently acting worm
curWorm = null

// To wait (for dramatic effect, for spell to complete, etc.), set this:
waitUntil = time + 1
// and optionally follow it with whatever's in this:
afterWaitDo = null

// Update: called by the main program every tick.
update = function(dt)
	if curTeam != team then
		outer.waitUntil = time + 1
		return
	end if
	if waitUntil > time then return
	if @afterWaitDo != null then
		f = @afterWaitDo
		outer.afterWaitDo = null
		outer.waitUntil = time + 1
		f
		return
	end if
		
	if curWorm != null then
		if not curWorm.grounded then return
		curWorm.deselect
		outer.curWorm = null
	end if

	if team.actionPoints < 1 or not team.worms then
		// all done!
		endTurn
		return
	end if
	pickAction dt
end function

// pickAction: called by update when it's time to pick a new action.
pickAction = function(dt)
	outer.curWorm = team.worms.any

	// moveAtRandom
	startSpell
end function

// Walk/jump towards a random nearby point.
moveAtRandom = function()
	curWorm.startMoveJumpMode
	target = {"x":curWorm.x + (rnd-0.5) * 500, "y":curWorm.y + 300}
	curWorm.walkOrJumpTowards target, dt

	outer.waitUntil = time + 2
end function

aiMouse = {"x": 0, "y": 0, "button": false}

// Shoot a spell at a random enemy worm.
// (or for now, just fire in any random direction)
startSpell = function()
	enemyTeam = Worms.teams[1 - Worms.teams.indexOf(curTeam)]
	if not enemyTeam.worms then return
	target = enemyTeam.worms.any
	
	angles = Ballistics.anglesToHit(Spells.Spell.projectileSpeed,
		target.x - curWorm.x, target.y - curWorm.y, abs(Projectiles.kGravity))
	if not angles then
		// fire at random!
		aiMouse.x = curWorm.x - disp.scrollX + randRange(-100, 100)
		aiMouse.y = curWorm.y + randRange(10,100)
		outer.waitUntil = time + randRange(0.1, 1)
	else
		// fire at target using either of the possible angles
		// (but favoring the latter one, which is usually shallower)
		angles.push angles[-1]
		ang = angles.any
		aiMouse.x = curWorm.x - disp.scrollX + 20 * cos(ang)
		aiMouse.y = curWorm.y + 20 * sin(ang)
		outer.waitUntil = time + 1
	end if
	aiMouse.button = true
	CastingUI.caster = curWorm
	CastingUI.addElement CastingUI.elementSprites.any
	CastingUI.startCasting
	outer.afterWaitDo = @continueSpell
end function

continueSpell = function()
	aiMouse.button = false
	outer.waitUntil = time + 2
end function
