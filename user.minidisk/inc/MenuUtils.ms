// Defines a MenuDisplay class and support code, for displaying
// and managing radial menus.

display(1).mode = displayMode.sprite
menuLayer = display(1)
menuLayer.clear

slicePic = file.loadImage("/usr/ui/RadialSlice.png")

kSlices = 8
kMaxRadius = 120
kMinRadius = 10

kStateHidden = "HIDDEN" // not shown at all
kStateIdle = "IDLE"   // open, and doing mouse-over effects as mouse moves
kStateTracking = "TRACKING" // mouse is down and we're tracking the drag
kStateAck = "ACK" // flashing/highlighting to acknowledge selection

MenuDisplay = {}
MenuDisplay.x = 0
MenuDisplay.y = 0
MenuDisplay.slices = []
MenuDisplay.shown = false
MenuDisplay.normalColor = "#AAAACC"
MenuDisplay.mouseOverColor = "#DDDDAA"
MenuDisplay.pressedColor = "#AA5522"
MenuDisplay.state = kStateHidden

MenuDisplay.isHidden = function()
	return self.state == kStateHidden
end function
MenuDisplay.isVisible = function()
	return self.state != kStateHidden
end function



MenuDisplay.enterState = function(newState)
	self.state = newState
	self.stateStartTime = time
	
	if self.state == kStateHidden then
		for s in self.slices
			idx = menuLayer.sprites.indexOf(s)
			if idx >= 0 then menuLayer.sprites.remove idx
		end for
	else if self.state == kStateTracking then
		if self.selected != null then self.selected.tint = self.pressedColor
	else if self.state == kStateIdle then
		if self.selected != null then self.selected.tint = self.normalColor
	end if
		
	text.row = 24
	//print self.state + " "*20
end function

MenuDisplay.timeInState = function()
	return time - self.stateStartTime
end function

MenuDisplay.show = function(x, y)
	if x == null then x = self.x
	if y == null then y = self.y
	if x < kMaxRadius then x = kMaxRadius
	if y < kMaxRadius then y = kMaxRadius
	if x > 960-kMaxRadius then x = 960-kMaxRadius
	if y > 640-kMaxRadius then x = 640-kMaxRadius
	self.x = x
	self.y = y
	
	for s in self.slices
		menuLayer.sprites.push s
		s.x = x
		s.y = y
		s.tint = self.normalColor
		s.scale = 1
	end for
	self.selected = null
	self.enterState kStateIdle
end function

MenuDisplay.hide = function()
	self.enterState kStateHidden
end function

MenuDisplay.selectItem = function(item)
	self.selected = item
	self.enterState kStateAck
end function

MenuDisplay.update = function(dt)
	if self.state == kStateHidden then return
	dx = mouse.x - self.x
	dy = mouse.y - self.y
	ang = atan(dy, dx) * 180/pi
	if ang < 0 then ang = ang + 360
	r = sqrt(dx*dx + dy*dy)
	
	idx = floor((ang + 22.5) / 45)
	if idx > 7 then idx = 0
	
	over = self.slices[idx]
	if r < kMinRadius or r > kMaxRadius then over = null
	
	if self.state == kStateIdle then
		// highlight whatever slice we're over
		if over != self.selected then
			if self.selected != null then self.selected.tint = self.normalColor
			if over != null then over.tint = self.mouseOverColor
			self.selected = over
		end if
		if mouse.button then self.enterState kStateTracking
	else if self.state == kStateTracking then
		// highlight whatever slice we're over, with "pressed" color
		if over != self.selected then
			if self.selected != null then self.selected.tint = self.normalColor
			if over != null then over.tint = self.pressedColor
			self.selected = over
		end if
		if not mouse.button then
			if self.selected == null then
				self.enterState kStateIdle
			else
				self.selectItem self.selected
			end if
		end if
	else if self.state == kStateAck then
		self.selected.scale = self.selected.scale + 1*dt
		t = self.timeInState / 0.25
		if t > 1 then
			self.hide
		else
			alpha = hex2((1-t) * 255)
			for s in self.slices
				s.tint = s.tint[:7] + alpha
			end for
		end if
	end if
end function

MenuDisplay.make = function(x,y)
	menu = new MenuDisplay
	menu.x = x
	menu.y = y
	menu.slices = []
	for ang in range(0, 315, 45)
		s = new Sprite
		s.image = slicePic
		s.tint = menu.normalColor
		s.rotation = ang
		s.scale = 1
		menu.slices.push s
	end for
	return menu
end function
