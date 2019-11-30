// Provides the overlays that describe the current state of the game:
// whose turn it is, how many Action Points they have, etc.
// It does all its drawing in display(2).

// special characters
specialChars = {}
specialChars.leftArrow = char(8592)
specialChars.rightArrow = char(8594)
specialChars.leftButtonCap = char(57856)
specialChars.rightButtonCap = char(57857)

drawTeamInfo = function(team, column)
	text.row = 25
	c = team.color
	if c[0] != "#" then c = color[c]
	if team != curTeam then c = c[:7] + "88"
	text.color = c
	name = team.color.upper
	if team == curTeam then
		name = specialChars.rightArrow + name + specialChars.leftArrow
	else
		name = " " + name + " "
	end if
	text.column = column - 1
	print name.pad(16)
	text.row = 24
	text.column = column
	print ("Worms:" + team.worms.len + "  AP:" + team.actionPoints).pad(15)
	text.color = color.orange
end function

drawWidgets = function()
	// draw "done" button in lower-right corner
	// a bit tricky since we have to avoid text scrolling
	text.color = color[curTeam.color]
	text.inverse = true
	text.row = 0
	text.column = 62
	text.delimiter = ""
	text.print specialChars.leftButtonCap + "DONE"
	text.setCell 67,0, specialChars.rightButtonCap
	text.setCellColor 67, 0, text.backColor
	text.setCellBackColor 67, 0, text.color
	text.inverse = false
	text.row = 12
end function

handleClick = function()
	// Handle a click, if it's on any of our clickable stuff, and return true.
	// Otherwise return false.
	if mouse.x > 875 and mouse.y < 30 then	// "DONE" button
		// ToDo: we really should do proper button highlighting & tracking here.
		// But for now we'll just react to the mouse-down.
		endTurn
		return true
	end if
	return false
end function

drawEvent = function(msg)
	// draw a short event string at the bottom of the screen
	// (leaving room for the "DONE" button)
	text.color = color[curTeam.color]
	text.delimiter = ""
	text.row = 0
	text.column = 0
	text.print " "*(34-msg.len/2) + msg + " "*(25-msg.len/2)
end function

refresh = function()
	drawTeamInfo Worms.teams[0], 5
	drawTeamInfo Worms.teams[1], 35
	drawWidgets
end function


// Setup.
// Eventually this layer will be a pixel display, and we'll use nice chunky
// graphics for all the text drawn (not to mention the mini-map, etc.).
// But for now, we're going to cheap out and just use a text display.
display(2).mode = displayMode.text
globals.text = display(2)

text.clear
text.delimiter = ""
