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

healthBarImages = []
loadHealthBars = function()
	p = file.loadImage("ui/HealthBars.png")
	for y in range(0, p.height-1, 5)
		healthBarImages.push p.getImage(0, y, p.width, 5)
	end for
end function
loadHealthBars

globals.Worm = new Animated
Worm.team = "brown"
Worm.walkSpeed = 100
Worm.selected = false
Worm.vx = 0
Worm.vy = 0
Worm.health = 100
Worm.localBounds = new Bounds
Worm.localBounds.width = 32
Worm.localBounds.height = 32

Worm.init = function(x, y, team="brown")
	super.init x, y
	self.team = team
	self.anims = wormAnims[team]
	self.curAnim = self.anims.idle
	self.healthBar = new Sprite
	disp.sprites.push self.healthBar
	self.updateHealthBar
end function

Worm.updateHealthBar = function()
	if self.health >= 100 then
		self.healthBar.imade = healthBarImages[-1]
	else
		self.healthBar.image = healthBarImages[round(healthBarImages.len * self.health/100)]
	end if
end function

Worm.takeDamage = function(damage, impulse=null)
	self.health = self.health - damage
	if self.health <= 0 then
		self.hide
		disp.sprites.removeVal self.healthBar
	else
		self.updateHealthBar
		if impulse != null then
			self.vx = self.vx + impulse.x
			self.vy = self.vy + impulse.y
		end if
	end if
end function

Worm.update = function(dt=0.1)
	super.update dt
	self.vy = self.vy + Projectiles.kGravity * dt
	if self.vy < -500 then self.vy = -500  // (terminal velocity)
	self.x = self.x + self.vx * dt
	nextY = self.y + self.vy * dt
	if nextY < self.y then
		groundY = DisplayUtils.dropRay(self.x, self.y, self.y - nextY + 16)
		if groundY != null then
			self.vy = 0
			nextY = groundY + 16
			self.vx = self.vx / 2
			if abs(self.vx) < 1 then self.vx = 0
		end if
	end if
	self.y = nextY
	self.healthBar.x = self.x
	self.healthBar.y = self.y + 32
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
