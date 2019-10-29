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

// Having to do this module trick is a bit lame.  Need to think about
// how to get something like this built-in -- access to the "file" scope,
// without leaking into the real global scope.
module = {}
module.isShown = false
module.pressed = null
module.caster = null
// Hmm... could we do this implicitly by just adding "module = locals"?!


// little sprites representing the elements currently added to the spell:
selectedElementIcons = []

isShown = function()
	return module.isShown
end function

show = function(caster)
	if module.isShown then hide
	r = 80
	for i in range(0,7)
		ang = pi/2 + i*pi/4
		spr = elementSprites[i]
		spr.x = caster.x + r * cos(ang)
		spr.y = caster.y + r * sin(ang)
		disp.sprites.push spr
	end for
	module.isShown = true
	module.caster = caster
end function

hideButtons = function()
	if not module.isShown then return
	for spr in elementSprites
		listUtil.removeVal disp.sprites, spr
	end for
end function

hide = function()
	hideButtons
	while selectedElementIcons
		listUtil.removeVal disp.sprites, selectedElementIcons.pop
	end while
	module.isShown = false
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
		icons[i].x = module.caster.x + (i-(icons.len-1)/2) * 20
		icons[i].y = module.caster.y - 25
	end for
	
	// and if we've hit the limit (3 elements), start casting!
	if icons.len > 2 then startCasting
end function

startCasting = function()
	hideButtons
	elements = []
	for spr in selectedElementIcons
		elements.push spr.name
	end for
	Spells.startCasting module.caster, elements
end function

handleClick = function()
	if not module.isShown then return false
	p = DisplayUtils.screenToWorld(mouse)
	// Press the selected element button
	for spr in elementSprites
		if spr.contains(p) then
			spr.tint = kPressedTint
			module.pressed = spr
			break
		end if
	end for
	if not module.pressed then
		// If we hit none of those, then cancel or start casting
		if selectedElementIcons then startCasting else hide
	end if
	return true
end function

update = function(dt)
	if module.pressed then
		// Update the pressed element tint while the mouse button is down;
		// add it if the mouse is released while the element is tinted.
		if mouse.button then
			if module.pressed.contains(DisplayUtils.screenToWorld(mouse)) then
				module.pressed.tint = kPressedTint
			else
				module.pressed.tint = color.white
			end if
		else
			// mouse released
			if module.pressed.tint == kPressedTint then
				addElement module.pressed
				module.pressed.tint = color.white
			end if
			module.pressed = null
		end if
	end if
end function
