// This module adds the Worm class, which represents any worm in the game2
// and the related Team class, which represents each team of worms.

teamColors = "blue brown green orange pink".split

Team = {}
Team.color = "gray"
Team.actionPoints = 0
Team.worms = null
Team.addWorm = function(worm)
	if self.worms == null then
		self.worms = [worm]
	else
		self.worms.push worm
	end if
	worm.team = self
end function
Team.removeWorm = function(worm)
	self.worms.removeVal worm
	worm.team = null
end function

teams = []
teams.push new Team
teams[-1].color = "blue"
teams.push new Team
teams[-1].color = "orange"



wormAnims = {}  // key: team color; value: map containing animations by name
for c in teamColors
	sheet = file.loadImage("sprites/sheet-" + c + ".png")
	d = {}
	d.sheet = sheet
	d.slither = spriteControllers.newAnimation(getFrames(sheet, 0, 0, 11, 42, 42))
	d.idle = spriteControllers.newAnimation(getFrames(sheet, 1, 0, 8, 42, 42))
	d.idle.fps = 5
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

kModeIdle = "Idle"
kModeMove = "Move"

globals.Worm = new Animated
Worm.team = null
Worm.walkSpeed = 100
Worm.selected = false
Worm.vx = 0
Worm.vy = 0
Worm.health = 100
Worm.localBounds = new Bounds
Worm.localBounds.width = 32
Worm.localBounds.height = 32
Worm.mode = kModeIdle

Worm.init = function(x, y, team)
	super.init x, y
	team.addWorm self
	self.anims = {}
	for kv in wormAnims[team.color]
		if kv.value isa Animation then
			self.anims[kv.key] = kv.value.clone
		else
			self.anims[kv.key] = kv.value
		end if
	end for
	self.curAnim = self.anims.idle
	self.curAnim.fps = 4 + rnd*2
	self.healthBar = new Sprite
	disp.sprites.push self.healthBar
	self.updateHealthBar
end function

Worm.updateHealthBar = function()
	frame = round(healthBarImages.len * self.health/100)
	if frame >= healthBarImages.len then frame = -1
	self.healthBar.image = healthBarImages[frame]
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
	StatusUI.refresh
end function

Worm.startMoveJumpMode = function()
	StatusUI.drawEvent "(Move/Jump)"
	self.mode = kModeMove
end function

Worm.update = function(dt=0.1)
	super.update dt
	if self.mode == kModeMove and mouse.button then
		self.walkOrJumpTowards DisplayUtils.screenToWorld(mouse), dt
	end if
	self.vy = self.vy + Projectiles.kGravity * dt
	if self.vy < -500 then self.vy = -500  // (terminal velocity)
	if self.vx != 0 then
		hDrag = -500 * sign(self.vx) * dt
		if abs(hDrag) > abs(self.vx) then self.vx = 0 else self.vx = self.vx + hDrag
		self.x = self.x + self.vx * dt
	end if
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

Worm.walkOrJumpTowards = function(target, dt)
	tooClose = self.contains(target)
	if tooClose then return
	angle = atan(target.y - self.y, target.x - self.x) * 180/pi
	if self.vy == 0 then
		// on the ground: walk towards the target, or start a jump
		if angle > 40 and angle < 140 then
			// jump!
			radians = angle * pi/180
			self.vx = 1000 * cos(radians)
			self.vy = 1000 * sin(radians)
		else
			// walk
			self.vx = 10 * sign(target.x - self.x)
			self.x = self.x + 10 * self.vx * dt
		end if
	else
		// already in the air... add some jump influence here
		if target.y > self.y and self.vy > 0 then
			self.vy = self.vy - Projectiles.kGravity * 0.5 * dt
		end if
	end if
	// turn to face the target
	if self.vx > 0 then
		self.scale = Animated.normalScale
	else if self.vx < 0 then
		self.scale = Animated.flippedScale
	end if
end function

Worm.select = function()
	self.selected = true
	p = DisplayUtils.worldToScreen(self)
	CastingUI.show self
end function

Worm.deselect = function()
	self.selected = false
	self.mode = kModeIdle
end function

Worm.handleClick = function()
	if self.mode != kModeMove then
		self.startMoveJumpMode
	end if
	return true
end function
