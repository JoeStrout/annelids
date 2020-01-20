// This module adds the Worm class, which represents any worm in the game,
// and the related Team class, which represents each team of worms.


//----------------------------------------------------------------------
// Team class
Team = {}
Team.color = "gray"
Team.actionPoints = 0
Team.worms = null

// someTeam.addWorm: add the given worm to this team.
// Parameters:
//		worm: worm to add.
// Returns: null
Team.addWorm = function(worm)
	if self.worms == null then
		self.worms = [worm]
	else
		self.worms.push worm
	end if
	worm.team = self
end function

// someTeam.removeWorm: remove the given worm from this team.
//		(This should be called when a worm dies.)
// Parameters:
//		worm: worm to remove from the team.
// Returns: null
Team.removeWorm = function(worm)
	self.worms.removeVal worm
	worm.team = null
end function
//----------------------------------------------------------------------

// Set up the initial teams for our demo.
teams = []
teams.push new Team
teams[-1].color = "blue"
teams.push new Team
teams[-1].color = "orange"


// Prepare worm animations, carving up a sprite sheet for each color.
// (We have a separate, different-colored sprite sheet for each team.)
teamColors = "blue brown green orange pink".split
wormAnims = {}  // key: team color; value: map containing animations by name
for c in teamColors
	sheet = file.loadImage("sprites/sheet-" + c + ".png")
	d = {}
	d.sheet = sheet

	d.slither = spriteControllers.newAnimation(getFrames(sheet, 0, 0, 11, 42, 42))

	d.idle = spriteControllers.newAnimation(getFrames(sheet, 1, 0, 8, 42, 42))
	d.idle.fps = 5

	d.jumpUp = spriteControllers.newAnimation(getFrames(sheet, 2, 0, 7, 42, 42))
	d.jumpUp.loop = false
	d.jumpUp.fps = 30

	d.jumpDown = spriteControllers.newAnimation(getFrames(sheet, 2, 7, 1, 42, 42))
	d.jumpDown.loop = false

	wormAnims[c] = d
end for

// Prepare the health bar images that will be used by the health bar sprites.
healthBarImages = []
loadHealthBars = function()
	p = file.loadImage("ui/HealthBars.png")
	for y in range(0, p.height-1, 5)
		healthBarImages.push p.getImage(0, y, p.width, 5)
	end for
end function
loadHealthBars

// Constants for Worm state (mode).
kModeIdle = "Idle"
kModeMove = "Move"

//----------------------------------------------------------------------
// Worm class	(stored in the global space)
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
Worm.movementLeft = 0
Worm.grounded = false

// someWorm.init: initialize this worm.
// Parameters:
//		x: x position of the sprite, in world coordinates
//		y: y position of the sprite, in world coordinates
//		team: Team instance to which this worm should be added
// Returns: null
Worm.init = function(x, y, team)
	super.init x, y
	team.addWorm self
	self.anims = {}
	for kv in wormAnims[team.color]
		// clone any animations, so we have a unique instance with its own state
		if kv.value isa Animation then
			self.anims[kv.key] = kv.value.clone
		else
			self.anims[kv.key] = kv.value
		end if
	end for
	self.curAnim = self.anims.idle
	self.curAnim.fps = 4 + rnd*2	// make worms idle at slightly different speeds
	self.healthBar = new Sprite
	disp.sprites.push self.healthBar
	self.updateHealthBar
end function

// someWorm.desc: get a short description of this worm for debugging purposes.
// Parameters: (none)
// Returns: brief description of this worm, including color, position, and health
Worm.desc = function()
	return self.team.color + " worm at " + round(self.x) + "," + round(self.y) + " with " + self.health + " HP"
end function

// someWorm.updateHealthBar: update our health bar to reflect our current health.
// Parameters: (none)
// Returns: null
Worm.updateHealthBar = function()
	frame = round(healthBarImages.len * self.health/100)
	if frame >= healthBarImages.len then frame = -1
	self.healthBar.image = healthBarImages[frame]
end function

// someWorm.takeDamage: apply the given damage.  If out of health, die.
// Parameters:
//		damage: number of points of damage to apply (full health is 100 points)
//		impulse: optional xy map to add to worm velocity (from blast force)
// Returns: null
Worm.takeDamage = function(damage, impulse=null)
	self.health = self.health - damage
	if self.health <= 0 then
		self.hide
		self.team.removeWorm self
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

// someWorm.startMoveJumpMode: set our mode to kModeMove, enabling the player
//		to make this worm slither around or jump.
// Parameters: (none)
// Returns: null
Worm.startMoveJumpMode = function()
	self.team.actionPoints = self.team.actionPoints - 1
	Worm.movementLeft = 200
	StatusUI.refresh
	StatusUI.drawEvent "Move/Jump (100%)"
	self.mode = kModeMove
end function

// someWorm.update: do one tick's update for this worm, including updating
//	animations, and doing our simple physics behavior if in the air.
// Parameters:
//		dt: time step
// Returns: null
Worm.update = function(dt=0.1)
	// call the base class update method (updates sprite frame)
	super.update dt

	// if in move/jump mode, and mouse button is down and we haven't used up
	// all our allowed movement, then go ahead and do the walk or jump.
	if self.mode == kModeMove and mouse.button and Worm.movementLeft > 0 then
		self.walkOrJumpTowards DisplayUtils.screenToWorld(mouse), dt
		if Worm.movementLeft <= 0 then
			StatusUI.drawEvent ""
			globals.select null
		else
			StatusUI.drawEvent "Move/Jump (" + round(100*worm.movementLeft/200) + "%)"
		end if
	end if
	
	// Do our physics simulation, approximating Newton's laws.
	self.vy = self.vy + Projectiles.kGravity * dt
	if self.vy < -500 then self.vy = -500  // (terminal velocity)
	if self.vx != 0 then
		hDrag = -500 * sign(self.vx) * dt
		if abs(hDrag) > abs(self.vx) then self.vx = 0 else self.vx = self.vx + hDrag
		self.x = self.x + self.vx * dt
	end if
	nextY = self.y + self.vy * dt
	if nextY < self.y then
		// When falling down, check for hitting the ground.
		groundY = DisplayUtils.dropRay(self.x, self.y, self.y - nextY + 16)
		if groundY != null then
			self.vy = 0
			self.grounded = true
			self.curAnim = self.anims.idle
			nextY = groundY + 16
			self.vx = self.vx / 2
			if abs(self.vx) < 1 then self.vx = 0
		else
			self.curAnim = self.anims.jumpDown
		end if
	else if self.vy > 0 then
		// When flying up, check for bumping the ceiling.
		self.grounded = false
		ceilingY = DisplayUtils.castRayUp(self.x, self.y, nextY - self.y + 16)
		if ceilingY != null then
			self.vy = 0
			nextY = ceilingY - 16
		end if		
	end if
	self.y = nextY

	// Keep our health bar positioned properly over our head.
	self.healthBar.x = self.x
	self.healthBar.y = self.y + 32
end function

// someWorm.walkOrJumpTowards: do the slither/jump behavior towards the 
//		given target position.
// Parameters:
//		target: xy map we should walk or jump towards.
//		dt: time step.
// Returns: null
Worm.walkOrJumpTowards = function(target, dt)
	// if target is too close to our current position, bail out
	tooClose = self.contains(target)
	if tooClose then return
	
	// calculate the angle to the target, in degrees
	angle = atan(target.y - self.y, target.x - self.x) * 180/pi
	if self.grounded then
		// on the ground: walk towards the target, or start a jump
		if angle > 40 and angle < 140 then
			// jump!
			radians = angle * pi/180
			self.vx = 1000 * cos(radians)
			self.vy = 1000 * sin(radians)
			self.curAnim = self.anims.jumpUp
			self.curAnim.curFrame = 0
			Worm.movementLeft = Worm.movementLeft - 40
		else
			// walk
			self.vx = 10 * sign(target.x - self.x)			
			self.x = self.x + 10 * self.vx * dt
			Worm.movementLeft = Worm.movementLeft - abs(10 * self.vx * dt)
		end if
	else
		// already in the air... add some jump influence here
		// (this allows you to jump higher by holding the mouse button down
		// during the "going up" phase of your jump)
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

// someWorm.select: called when this worm has been selected.  Updates internal
//		flags and shows the Casting UI.
// Parameters: (none)
// Returns: null
Worm.select = function()
	self.selected = true
	p = DisplayUtils.worldToScreen(self)
	CastingUI.show self
end function

// someWorm.deselect: called when this worm is no longer selected.
// Parameters: (none)
// Returns: null
Worm.deselect = function()
	self.selected = false
	self.mode = kModeIdle
	if selected == self then globals.selected = null
end function

// someWorm.handleClick: assume the mouse button is down while this worm is
//		the currently selected one.  Deal with the click, and return true
//		to indicate we handled it.  (Note that if the Casting UI is up, it
//		gets a chance to handle the click before we do here.)
// Parameters: (none)
// Returns: null
Worm.handleClick = function()
	if self.mode != kModeMove and self.team.actionPoints > 0 then
		self.startMoveJumpMode
	end if
	return true
end function
//----------------------------------------------------------------------
