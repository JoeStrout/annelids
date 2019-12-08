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

effectSpells = {}		// key: effect name; value: Spell subclass
effectProjectiles = {}	// key: effect name; value: Projectile subclass

Spell = {}
Spell.usesReticle = true
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
	proj.vx = dx * 2000 * chargeTime
	proj.vy = dy * 2000 * chargeTime
	return proj
end function

BoltProjectile = new Projectile
BoltProjectile.image = file.loadImage("sprites/bolt.png")

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

StoneProjectile = new Projectile
StoneProjectile.image = file.loadImage("sprites/rock.png")
StoneProjectile.rotate = false
effectProjectiles[kStone] = StoneProjectile
effectProjectiles[kBoulder] = StoneProjectile

HandProjectile = new Projectile
HandProjectile.image = file.loadImage("sprites/fist.png")
HandProjectile.angleOffset = -45
effectProjectiles[kHand] = HandProjectile

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

