// This file provides utility routines related to ballistics, i.e.,
// projectiles falling under gravity after being launched at some
// velocity.


// anglesToHit: return 0 or 2 possible angles at which a
// projectile could be fired with the given speed in order
// to hit a target at dx,dy relative to the launch point.
// Result is a list of [ang1, ang2] list of options, or []
// if there are no solutions (because the target is simply
// too far away to reach with the given launch speed).
// g is the acceleration (downward) due to gravity, in the
// same units as launchSpeed, dx, and dy.
// Result is in radians.
anglesToHit = function(launchSpeed, dx, dy, g=9.8)
	v2 = launchSpeed * launchSpeed
	v4 = v2 * v2
	term = v4 - g * (g * dx*dx + 2 * dy * v2)
	if term < 0 then
		// When this term is < 0, the target is too far away.
		return []
	end if
	root = sqrt(term)
	gx = g * dx
	return [atan(v2 + root, gx), atan(v2 - root, gx)]
end function

if locals == globals then
	// Run some simple unit tests.
	print "Unit testing ballistics"
	
	assert = function(condition)
		if not condition then
			print "Unit test failed."
			exit
		end if
	end function
	
	assertApprox = function(actual, expected)
		if abs(expected - actual) > 1 then
			print "Unit test failure: expected " + expected + ", but got " + actual
			exit
		end if
	end function

	// If we fire a projectile at 50 m/s to hit a target
	// that is 300m away horizontally and 200m lower,
	// we can do that at either 60.6° or -4.3°.
	angs = anglesToHit(50, 300, -200)
	assertApprox angs[0] * 180/pi, 60.6
	assertApprox angs[1] * 180/pi, -4.3
	
	// But if the target is 500m away, we can't hit it at this speed.
	angs = anglesToHit(50, 500, -200)
	assert not angs
	
	print "Ballistics unit tests passed.  Fire at will!"
end if
