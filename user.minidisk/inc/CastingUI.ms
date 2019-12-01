// Provides functions for drawing the UI involved in casting spells
// (radial menu of elements, etc.)

elementsPic = file.loadImage("/usr/ui/ElementButtons.png")

elementPics = getFrames(elementsPic, 0, 0, 4) + getFrames(elementsPic, 1, 0, 4)

elementSprites = []
for p in elementPics
	spr = new Sprite
	spr.image = p
	spr.localBounds = new Bounds
	spr.localBounds.width = p.width
	spr.localBounds.height = p.height
	spr.name = Spells.elementNames[elementSprites.len]
	elementSprites.push spr
end for

isShown = false
pressed = null
caster = null

// little sprites representing the elements currently added to the spell:
selectedElementIcons = []

show = function(caster)
	if isShown then hide
	outer.isShown = true
	outer.caster = caster
	r = 80
	for i in range(0,7)
		ang = pi/2 + i*pi/4
		spr = elementSprites[i]
		disp.sprites.push spr
		spr.x = caster.x + r * cos(ang)
		spr.y = caster.y + r * sin(ang)
	end for
	// There is a bug in Mini Micro v0.8, where moving a sprite that has been
	// hidden does not update the bounds.  To work around it, we need to yield
	// a frame, and then poke the position again.  (Fixed in MiniMicro v0.9.)
	yield
	for spr in elementSprites
		spr.x = spr.x
	end for
end function

hideButtons = function()
	if not isShown then return
	for spr in elementSprites
		disp.sprites.removeVal spr
	end for
end function

hide = function()
	hideButtons
	while selectedElementIcons
		disp.sprites.removeVal selectedElementIcons.pop
	end while
	outer.isShown = false
end function

kPressedTint = "#888888"

addElement = function(elemSprite)
	element = elemSprite.name
	//print "Adding element: " + element

	// add a little icon for the new element
	icon = new Sprite
	icon.image = elemSprite.image
	icon.scale = 0.25
	icon.name = element
	disp.sprites.push icon
	selectedElementIcons.push icon

	// now arrange all the icons below our caster position
	icons = selectedElementIcons
	for i in icons.indexes
		icons[i].x = caster.x + (i-(icons.len-1)/2) * 20
		icons[i].y = caster.y - 25
	end for
	
	// decrement player's AP
	curTeam.actionPoints = curTeam.actionPoints - 1
	StatusUI.refresh
	
	// and if we've hit the limit (3 elements or out of AP), start casting!
	if icons.len > 2 or curTeam.actionPoints == 0 then startCasting
end function

startCasting = function()
	hideButtons
	elements = []
	for spr in selectedElementIcons
		elements.push spr.name
	end for
	Spells.startCasting caster, elements
	if selected then selected.deselect
end function

handleClick = function()
	if not isShown then return false
	p = DisplayUtils.screenToWorld(mouse)
	// Press the selected element button
	for spr in elementSprites
		if spr.contains(p) then
			spr.tint = kPressedTint
			outer.pressed = spr
			break
		end if
	end for
	if not pressed then
		// If we hit none of those, then cancel or start casting
		if selectedElementIcons then startCasting else hide
	end if
	return true
end function

update = function(dt)
	if pressed then
		// Update the pressed element tint while the mouse button is down;
		// add it if the mouse is released while the element is tinted.
		if mouse.button then
			if pressed.contains(DisplayUtils.screenToWorld(mouse)) then
				pressed.tint = kPressedTint
			else
				pressed.tint = color.white
			end if
		else
			// mouse released
			if pressed.tint == kPressedTint then
				addElement pressed
				pressed.tint = color.white
			end if
			outer.pressed = null
		end if
	end if
end function
