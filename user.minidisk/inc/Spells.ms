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
	reticle.init worm.x, worm.y
	reticle.fire = function(dx, dy, chargeTime)
		CastingUI.hide
		reticle.hide
		proj = new Projectile
		proj.init self.anchorX, self.anchorY
		proj.vx = dx * 2000 * chargeTime
		proj.vy = dy * 2000 * chargeTime
	end function
end function
