# Annelids Code Architecture Notes

## Displays

[Mini Micro](https://miniscript.org/MiniMicro) has 8 display layers.  Here's how we use them in the game:

0. (Front) SolidColorDisplay: used to fade in/out.
1. SpriteDisplay: menus (and maybe some HUD elements that work better as sprites).
2. PixelDisplay: HUD (game/turn status, mini-map)
3. SpriteDisplay: explosions, flashes, other "foreground" sprites/effects.
4. SpriteDisplay: worms, pickups, other "main layer" sprites.
5. PixelDisplay: destructible ground/terrain.
6. TileDisplay: water/lava (near bottom of level, kills worms that fall in)
7. (Back) PixelDisplay: Dark sky/rock background.
