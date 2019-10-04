clear
import "MenuUtils"

MenuDisplay = MenuUtils.MenuDisplay

menu = MenuDisplay.make(480, 320)
menu.show

wasDown = mouse.button
lastTime = time
while not key.pressed("escape")
	newTime = time
	menu.update newTime - lastTime
	isDown = mouse.button
	if isDown and not wasDown and menu.isHidden then
		menu.show mouse.x, mouse.y
	end if
	wasDown = isDown
	lastTime = newTime
	yield
end while
menu.hide
key.clear
