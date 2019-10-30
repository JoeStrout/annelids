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

// Main-effect table: when you change this, be sure to change it both ways
// so that order of elements doesn't matter!
// Indexed in same order as elementNames:
//		kAir, kLife, kCold, kLiquid, kGround, kDeath, kHot, kSolid

effectTable = {}
effectTable[kAir] = [kWind, kLightning, kSnow, kRain, kChaos, kPoisonGas, kFlame, kShield]
effectTable[kLife] = [kLightning, kSummon, kSickness, kHeal, kPlants, kChaos, kFire, kHand]
effectTable[kCold] = [kSnow, kSickness, kFreeze, kSleet, kGrave, kColdAtk, kChaos, kIce]
effectTable[kLiquid] = [kRain, kHeal, kSleet, kFlood, kMud, kAcidRain, kSteam, kChaos]
effectTable[kGround] = [kChaos, kPlants, kGrave, kMud, kTerrain, kTrap, kLava, kStone]
effectTable[kDeath] = [kPoisonGas, kChaos, kColdAtk, kAcidRain, kTrap, kDeathTouch, kExplosion, kAnvil]
effectTable[kHot] = [kFlame, kFire, kChaos, kSteam, kLava, kExplosion, kHeat, kMeteor]
effectTable[kSolid] = [kShield, kHand, kIce, kChaos, kStone, kAnvil, kMeteor, kBoulder]

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

startCasting = function(worm, elements)
	effect = mainEffect(elements)
	text.row = 21
	print "Casting: " + elements.join("+") + " with main effect: " + effect + " "*20
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

