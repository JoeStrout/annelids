// This file defines all the spell effects, including firing UI and whatever
// projectiles or other stuff happens when the spell goes off.
// It's also where we have all the logic for what different combinations
// of elements do.

// Elements:
kAir = "Air"
kLife = "Life"
kCold = "Cold"
kLiquid = "Liquid"
kGround = "Ground"
kDeath = "Death"
kHot = "Hot"
kSolid = "Solid"
elementNames = [kAir, kLife, kCold, kLiquid, kGround, kDeath, kHot, kSolid]

// Primary Effects:
kHeat = "Heat"
kChaos = "CHAOS"
kFlame = "Flame"
kLava = "Lava"
kSteam = "Steam"
kMeteor = "Meteor"
kFire = "Fire"
kExplosion = "Explosion"
kFreeze = "Freeze"
kSnow = "Snow"
kGrave = "Grave"
kSleet = "Sleet"
kIce = "Ice"
kSickness = "Sickness"
kColdAtk = "Cold Attack"
kWind = "Wind"
kRain = "Rain"
kShield = "Shield"
kLightning = "Lightning"
kPoisonGas = "Poison Gas"
kTerrain = "Terrain"
kMud = "Mud"
kStone = "Stone"
kPlants = "Plants"
kTrap = "Trap"
kFlood = "Flood"
kHeal = "Heal"
kAcidRain = "Acid Rain"
kBoulder = "Boulder"
kHand = "Hand"
kAnvil = "Anvil"
kSummon = "Summon"
kDeathTouch = "Death Touch"
kTeleport = "Teleport"

// Main-effect table: when you change this, be sure to change it both ways
// so that order of elements doesn't matter!
// Indexed in same order as elementNames:
//		kAir, kLife, kCold, kLiquid, kGround, kDeath, kHot, kSolid

effectTable = {}
effectTable[kAir] = [kWind, kTeleport, kSnow, kRain, kChaos, kPoisonGas, kFlame, kShield]
effectTable[kLife] = [kTeleport, kSummon, kSickness, kHeal, kPlants, kChaos, kFire, kHand]
effectTable[kCold] = [kSnow, kSickness, kFreeze, kSleet, kGrave, kColdAtk, kChaos, kIce]
effectTable[kLiquid] = [kRain, kHeal, kSleet, kFlood, kMud, kAcidRain, kSteam, kChaos]
effectTable[kGround] = [kChaos, kPlants, kGrave, kMud, kTerrain, kTrap, kLava, kStone]
effectTable[kDeath] = [kPoisonGas, kChaos, kColdAtk, kAcidRain, kTrap, kDeathTouch, kExplosion, kAnvil]
effectTable[kHot] = [kFlame, kFire, kChaos, kSteam, kLava, kExplosion, kHeat, kMeteor]
effectTable[kSolid] = [kShield, kHand, kIce, kChaos, kStone, kAnvil, kMeteor, kBoulder]

// Detailed effects:
detailTable = {}  // key: main effect; value: list of detail effects, in order
kSummonTornado = "Summon Tornado"
kGaia = "Gaia"
kSnowGoon = "Summon Snow Goon"
kWaterElemental = "Summon Water Elemental"
kEarthElemental = "Summon Earth Elemental"
kGrimReaper = "Summon Death"
kFireElemental = "Summon Fire Elemental"
kStatue = "Summon Statue"
detailTable[kSummon] = [kSummonTornado, kGaia, kSnowGoon, kWaterElemental, 
	kEarthElemental, kGrimReaper, kFireElemental, kStatue]

kLiftingHand = "Lifting Hand"
kInterposingHand = "Interposing Hand"
kChillingHand = "Chilling Hand"
kPushingHand = "Pushing Hand"
kHoldingHand = "Holding Hand"
kSquashingHand = "Squashing Hand"
kFlamingHand = "Flaming Hand of Fiery Doom"
kPunchingHand = "Punching Hand"
detailTable[kHand] = [kLiftingHand, kInterposingHand, kChillingHand, kPushingHand,
	kHoldingHand, kSquashingHand, kFlamingHand, kPunchingHand]

kWindTrap = "Wind Trap"
kVineTrap = "Vine Trap"
kColdTrap = "Cold Trap"
kBucketTrap = "Bucket Trap"
kPitTrap = "Pit Trap"
kDeathTrap = "Death Trap"
kMine = "Mine"
kBearTrap = "Bear Trap"
detailTable[kTrap] = [kWindTrap, kVineTrap, kColdTrap, kBucketTrap, 
	kPitTrap, kDeathTrap, kMine, kBearTrap]

kTyphoon = "Typhoon"
kFrogs = "Frogs"
kDeluge = "Deluge"
kFlood = "Flood"
kNapalm = "Napalm"
kHail = "Hail"
detailTable[kRain] = [kTyphoon, kFrogs, kSleet, kDeluge, kFlood, kLightning, kNapalm, kHail]

// mainEffect: return the primary effect of the chosen elements.  This is determined
// by the first two elements in the list.
mainEffect = function(elements)
	if elements.len == 1 then
		// If only one element, the main effect is the same as if you double it.
		// (But it's only half as strong.)
		elem2idx = elementNames.indexOf(elements[0])
	else
		elem2idx = elementNames.indexOf(elements[1])
	end if
	return effectTable[elements[0]][elem2idx]
end function

// fullEffect: return the complete, detailed effect of the chosen elements.
// This includes the main effect (determined by the first two) and the variation
// (determined by the third).
fullEffect = function(elements)
	effect = mainEffect(elements)
	if elements.len < 3 or not detailTable.hasIndex(effect) then return effect
	lastIdx = elementNames.indexOf(elements[2])
	return detailTable[effect][lastIdx]
end function

startCasting = function(worm, elements)
	effect = fullEffect(elements)
	StatusUI.drawEvent effect
	spell = new Spell
	spell.init worm, elements
	reticle.init worm.x, worm.y
	reticle.fire = function(dx, dy, chargeTime)
		CastingUI.hide
		reticle.hide
		spell.fire dx, dy, chargeTime
	end function
end function

// easeFunc: a function to map a straight/linear range to a "smoothed"
// 0-1 range (using half a sine curve).  Used by some of the spell
// effects below.
easeFunc = function(t, length=1)
	// ease from 0 to 1 as t goes from 0 to length
	x = sin(t/length * pi/2)
	return x*x
end function
 
// easeInOutFunc: another easing function; this one eases up to 1
// stays there over fullT, and then eases back down to 0 at totalT.
easeInOutFunc = function(t, totalT=1, fullT=0.5)
	t0 = (totalT - fullT)/2
	if t < t0 then return easeFunc(t, t0)
	t1 = (totalT + fullT)/2
	if t > t1 then return 1 - easeFunc(t - t1, t0)
	return 1
end function


// maps from the effect name to the Spell and Projectile subclasses
// that actually implement that effect (we'll fill these in as we go below)
effectSpells = {}		// key: effect name; value: Spell subclass
effectProjectiles = {}	// key: effect name; value: Projectile subclass

//----------------------------------------------------------------------
// Spell base class.
Spell = {}
Spell.usesReticle = true
Spell.projectileSpeed = 2000
Spell.init = function(caster, elements)
	self.caster = caster
	self.elements = elements
	self.effect = mainEffect(elements)
end function
Spell.fire = function(dx, dy, chargeTime)
	projClass = BoltProjectile
	if effectProjectiles.hasIndex(self.effect) then projClass = effectProjectiles[self.effect]
	proj = new projClass
	proj.init self.caster.x, self.caster.y
	proj.spell = self
	proj.vx = dx * self.projectileSpeed * chargeTime
	proj.vy = dy * self.projectileSpeed * chargeTime
	return proj
end function

//----------------------------------------------------------------------
// Generic bolt projectile (used for any spell that doesn't specify
// some alternative; also the base class for some spell projectiles).
BoltProjectile = new Projectile
BoltProjectile.image = file.loadImage("sprites/bolt.png")

//----------------------------------------------------------------------
// PoisonProjectile: used for the kPoisonGas effect.
// Generates a GasPuff when it hits.
PoisonProjectile = new BoltProjectile
PoisonProjectile.tint = color.green
PoisonProjectile.explode = function()
	for i in range(0,10)
		puff = new GasPuff
		puff.init self.x + (rnd-0.5)*20, self.y + (rnd-0.5)*20
	end for
	self.hide
end function
effectProjectiles[kPoisonGas] = PoisonProjectile

// GasPuff sprite (floats about and does damage to worms).
GasPuff = new UpdateableSprite
GasPuff.image = file.loadImage("sprites/poisonGas.png")
GasPuff.localBounds = new Bounds
GasPuff.localBounds.width = GasPuff.image.width * 0.8
GasPuff.localBounds.height = GasPuff.image.height * 0.8
GasPuff.instances = []
GasPuff.init = function(x,y)
	super.init x,y
	self.timeLeft = 3 + rnd
	GasPuff.instances.push self
end function
GasPuff.hide = function()
	super.hide
	GasPuff.instances.remove GasPuff.instances.indexOf(self)
end function
GasPuff.update = function(dt)
	// disappear after our time is up
	self.timeLeft = self.timeLeft - dt
	if self.timeLeft < 0 then self.hide

	// get away from other overlapping gas puffs
	myIdx = GasPuff.instances.indexOf(self)
	if myIdx < GasPuff.instances.len-1 then
		for i in range(myIdx+1, GasPuff.instances.len-1)
			other = GasPuff.instances[i]
			if other.overlaps(self) then
				self.x = self.x + 100 * dt * sign(self.x - other.x)
				other.x = other.x + 100 * dt * sign(other.x - self.x)
			end if
		end for
	end if
	
	// ooze slowly down a slope
	leftY = DisplayUtils.dropRay(self.x-5, self.y)
	if leftY == null then leftY = self.y - 100
	rightY = DisplayUtils.dropRay(self.x+5, self.y)
	if rightY == null then rightY = self.y - 100
	targY = (leftY + rightY) * 0.5 + 20
	self.y = self.y + 50 * dt * sign(targY - self.y)
	self.x = self.x + 50 * dt * sign(leftY - rightY)
end function

//----------------------------------------------------------------------
// StoneProjectile (used for kStone and kBoulder effects).
StoneProjectile = new Projectile
StoneProjectile.image = file.loadImage("sprites/rock.png")
StoneProjectile.rotate = false
effectProjectiles[kStone] = StoneProjectile
effectProjectiles[kBoulder] = StoneProjectile

//----------------------------------------------------------------------
// HandProjectile (used for kHand effect)
HandProjectile = new Projectile
HandProjectile.image = file.loadImage("sprites/fist.png")
HandProjectile.angleOffset = -45
effectProjectiles[kHand] = HandProjectile

//----------------------------------------------------------------------
// TeleportProjectile (used for kTeleport effect).
// Moves the caster instantly to wherever it hits.
TeleportProjectile = new Projectile
TeleportProjectile.sound = file.loadSound("sounds/teleport.wav")
TeleportProjectile.explode = function()
	groundY = DisplayUtils.dropRay(self.x, self.y, self.y - 2, 16) - 10
	if groundY == null then groundY = self.y
	self.spell.caster.x = self.x
	self.spell.caster.y = groundY

	self.sound.play
	self.hide
end function
effectProjectiles[kTeleport] = TeleportProjectile

//----------------------------------------------------------------------
// SnowProjectile (used for kSnow effect).
// Makes a bunch of snow appear as pixels in the gfx layer, which
// slowly filter down and accumulate on other stuff (e.g. terrain).
SnowProjectile = new Projectile
SnowProjectile.explode = function()
	self.hide
	snow = []
	toSpawn = 600
	while toSpawn > 0 or snow
		if toSpawn > 0 then
			x = round(self.x / gfx.scale + rnd * 100 - 50)
			y = round(self.y / gfx.scale + rnd * 100)
			if gfx.pixel(x,y) == skyColor then
				snow.push {"x":x, "y":y}
				toSpawn = toSpawn - 1
			end if
		end if
		if snow.len <= 0 then continue		
		for i in range(snow.len-1)
			p = snow[i]
			x = p.x + (rnd < 0.3) - (rnd < 0.3)
			y = p.y - 1
			if gfx.pixel(x,y) != skyColor then
				// Maybe hit something... try a bit to the left or right
				if gfx.pixel(x-1,y) == skyColor then
					x = x - 1
				else if gfx.pixel(x+1,y) == skyColor then
					x = x + 1
				else
					// failing that, just stick
					snow.remove i
				end if
			else
				gfx.setPixel p.x, p.y, skyColor
				gfx.setPixel x, y, color.white
				p.x = x
				p.y = y
			end if
		end for
		yield
	end while
end function
effectProjectiles[kSnow] = SnowProjectile

//----------------------------------------------------------------------
// GroundProjectile (used for kTerrain effect).
// Draws new hunks of terrain into the graphics layer where it hits.
GroundProjectile = new Projectile
GroundProjectile.sound = file.loadSound("sounds/terrain.wav")
GroundProjectile.pieces = []
for i in range(1,6)
	GroundProjectile.pieces.push file.loadImage("levels/GroundPiece" + i + ".png")
end for
GroundProjectile.explode = function()
	self.hide
	self.sound.play
	y = self.y / gfx.scale
	for i in range(2+2*rnd)
		x = self.x / gfx.scale + round(rnd*60 - 30)
		img = self.pieces.any
		gfx.drawImage img, x - img.width/2, y - img.height/2
		y = y + 5 + round(rnd*20)
	end for
end function
effectProjectiles[kTerrain] = GroundProjectile

//----------------------------------------------------------------------
// AcidRainProjectile (used for kAcidRain effect).
// Where it hits, generates AcidRainCloud sprites that in turn
// emit AcidRainDrop projectiles.  (Bloody weather.)
AcidRainProjectile = new BoltProjectile
AcidRainProjectile.tint = "#880000"
AcidRainProjectile.sound = file.loadSound("sounds/splat.wav")
AcidRainProjectile.explode = function()
	self.sound.play
	cloud = new AcidRainCloud
	cloud.init self.x, self.y
	if self.spell.elements.len > 2 then cloud.rainTime = 8
	self.hide
end function
effectProjectiles[kAcidRain] = AcidRainProjectile

AcidRainCloud = new UpdateableSprite
AcidRainCloud.image = file.loadImage("sprites/cloud1.png")
AcidRainCloud.tint = "#FFFFFFCC"
AcidRainCloud.init = function(x, y)
	super.init x, y
	self.scale = 0
	self.age = 0
	self.rainTime = 3
	self.ageAtNextDrop = 3.2
end function
AcidRainCloud.update = function(dt)
	self.age = self.age + dt
	self.scale = self.age / 3
	if self.scale > 1 then
		self.scale = 1
		self.x = self.x - 8 * dt
		if self.age > 3+self.rainTime then
			self.tint = color.rgba(255,255,255, 200 - 200*(self.age-3-self.rainTime)/2)
			if self.age > 5+self.rainTime then self.hide
		else if self.age > self.ageAtNextDrop then
			drop = new AcidRainDrop
			drop.init self.x + 120 * (rnd-0.5), self.y - 40		
			rainRate = easeInOutFunc(self.age-3, self.rainTime, self.rainTime-1)
			self.ageAtNextDrop = self.ageAtNextDrop + (1.1 - rainRate) * rnd
		end if
	else
		self.y = self.y + 65 * dt
		self.x = self.x + 15 * dt
	end if
end function

AcidRainDrop = new Projectile
AcidRainDrop.image = file.loadImage("sprites/raindrop.png")
AcidRainDrop.vx = -8*60
AcidRainDrop.vy = -2*60
AcidRainDrop.rotate = false
AcidRainDrop.boomRadius = 2
AcidRainDrop.boomDamage = 10
AcidRainDrop.boomForce = 0
