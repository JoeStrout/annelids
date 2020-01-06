// Annelids artificial intelligence (AI) player.

import "listUtil"

// Which team this AI is responsible for:
team = null

// Currently acting worm
curWorm = null

// To wait (for dramatic effect, for spell to complete, etc.), set this:
waitUntil = time + 1

update = function(dt)
	if curTeam != team then
		outer.waitUntil = time + 1
		return
	end if
	if waitUntil > time then return

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

pickAction = function(dt)
	outer.curWorm = team.worms.any

	curWorm.startMoveJumpMode
	target = {"x":curWorm.x + (rnd-0.5) * 500, "y":curWorm.y + 300}
	curWorm.walkOrJumpTowards target, dt

	outer.waitUntil = time + 2
end function
