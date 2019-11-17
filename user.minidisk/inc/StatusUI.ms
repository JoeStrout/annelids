// Provides the overlays that describe the current state of the game:
// whose turn it is, how many Action Points they have, etc.
// It does all its drawing in display(2).


// Setup.
// Eventually this layer will be a pixel display, and we'll use nice chunky
// graphics for all the text drawn (not to mention the mini-map, etc.).
// But for now, we're going to cheap out and just use a text display.
display(2).mode = displayMode.text
globals.text = display(2)

text.clear

text.row = 25
text.color = color.yellow
print "ANNELIDS"
text.color = color.gray
print "very early prototyping work"
//print "click to make a crater; right-click to open radial menu"
print "use mouse to shoot, arrow keys to scroll"
_printMark "(press `Esc` to exit)"
text.color = color.orange

