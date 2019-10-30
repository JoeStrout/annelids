// This module adds the Worm class, which represents any worm in the game.

teamColors = "blue brown green orange pink".split

wormAnims = {}  // key: team color; value: map containing animations by name
for c in teamColors
	sheet = file.loadImage("sprites/sheet-" + c + ".png")
	d = {}
	d.sheet = sheet
	d.slither = spriteControllers.newAnimation(getFrames(sheet, 0, 0, 11, 42, 42))
	d.idle = spriteControllers.newAnimation(getFrames(sheet, 1, 0, 8, 42, 42))
	d.jumpUp = spriteControllers.newAnimation(getFrames(sheet, 2, 0, 7))
	d.jumpDown = spriteControllers.newAnimation(getFrames(sheet, 2, 8, 5))
	wormAnims[c] = d
end for

globals.Worm = new Animated
Worm.team = "brown"
Worm.walkSpeed = 100
Worm.selected = false
Worm.vx = 0
Worm.vy = 0

Worm.init = function(x, y, team="brown")
	super.init x, y
	self.team = team
	self.anims = wormAnims[team]
	self.curAnim = self.anims.idle
	self.localBounds = new Bounds
	self.localBounds.width = 32
	self.localBounds.height = 32
end function

Worm.update = function(dt=0.1)
	super.update dt
	self.vy = self.vy + Projectiles.kGravity * dt
	if self.vy < -500 then self.vy = -500  // (terminal velocity)
	nextY = self.y + self.vy * dt
	if nextY < self.y then
		groundY = DisplayUtils.dropRay(self.x, self.y, self.y - nextY + 16)
		if groundY != null then
			self.vy = 0
			nextY = groundY + 16
		end if
	end if
	self.y = nextY
end function

Worm.select = function()
	self.selected = true
	p = DisplayUtils.worldToScreen(self)
	CastingUI.show self
	//menu.show p.x, p.y
end function

Worm.deselect = function()
	self.selected = false
end function

Worm.handleClick = function()
	return false
end function