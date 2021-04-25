local pos = require("position")

hs.hotkey.alertDuration = 0
hs.hints.showTitleThresh = 0
hs.window.animationDuration = 0

hs.hotkey.bind({"shift", "alt"}, "n", pos.nextScreen)
hs.hotkey.bind({"shift", "alt"}, "p", pos.previousScreen)
hs.hotkey.bind({"shift", "alt"}, "k", pos.full)
hs.hotkey.bind({"shift", "alt"}, "j", pos.left)
hs.hotkey.bind({"shift", "alt"}, "l", pos.right)
hs.hotkey.bind({"shift", "alt"}, "i", pos.top)
hs.hotkey.bind({"shift", "alt"}, ",", pos.bottom)
hs.hotkey.bind({"shift", "alt"}, "u", pos.topLeft)
hs.hotkey.bind({"shift", "alt"}, "o", pos.topRight)
hs.hotkey.bind({"shift", "alt"}, "m", pos.bottomLeft)
hs.hotkey.bind({"shift", "alt"}, ".", pos.bottomRight)
