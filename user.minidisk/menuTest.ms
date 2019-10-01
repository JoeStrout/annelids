slicePic = file.loadImage("ui/RadialSlice.png")

clear
display(1).mode = displayMode.sprite
menuLayer = display(1)
menuLayer.clear

kSlices = 8
kMaxRadius = 120
kMinRadius = 10

MenuDisplay = {}
MenuDisplay.x = 0
MenuDisplay.y = 0
MenuDisplay.slices = []
MenuDisplay.shown = false

MenuDisplay.make = function(x,y)
	menu = new MenuDisplay
	menu.x = x
	menu.y = y
	menu.slices = []
	for ang in range(0, 315, 45)
		s = new Sprite
		s.image = slicePic
		s.tint = "#AAAACC"
		s.rotation = ang
		s.scale = 1
		menu.slices.push s
	end for
	return menu
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
		s.x = x
		s.y = y
		menuLayer.sprites.push s
	end for
	self.selected = null
end function

MenuDisplay.hide = function()
	for s in self.slices
		idx = menuLayer.indexOf(s)
		if idx >= 0 then menuLayer.remove idx
	end for
end function

MenuDisplay.update = function()
	dx = mouse.x - self.x
	dy = mouse.y - self.y
	ang = atan2(dy, dx) * 180/pi
	if ang < 0 then ang = ang + 360
	r = sqrt(dx*dx + dy*dy)
	
	idx = floor((ang + 22.5) / 45)
	if idx > 7 then idx = 0
	
	over = self.slices[idx]
	if r < kMinRadius or r > kMaxRadius then over = null
	if over != self.selected then
		if self.selected != null then self.selected.tint = "#AAAACC"
		if over != null then over.tint = "#DDDDBB"
		self.selected = over
	end if
end function

menu = MenuDisplay.make(480, 320)
menu.show

wasDown = mouse.button
while not key.pressed("escape")
	menu.update
	isDown = mouse.button
	if isDown and not wasDown then
		menu.hide
		menu.show mouse.x, mouse.y
	end if
	wasDown = isDown
end while
menu.hide
key.clear
