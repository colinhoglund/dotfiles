require "position"

hs.hotkey.alertDuration = 0
hs.hints.showTitleThresh = 0
hs.window.animationDuration = 0

hs.hotkey.bind({"shift", "alt"}, "k", position.full)
hs.hotkey.bind({"shift", "alt"}, "j", position.left)
hs.hotkey.bind({"shift", "alt"}, "l", position.right)
hs.hotkey.bind({"shift", "alt"}, "i", position.top)
hs.hotkey.bind({"shift", "alt"}, ",", position.bottom)
hs.hotkey.bind({"shift", "alt"}, "u", position.topLeft)
hs.hotkey.bind({"shift", "alt"}, "o", position.topRight)
hs.hotkey.bind({"shift", "alt"}, "m", position.bottomLeft)
hs.hotkey.bind({"shift", "alt"}, ".", position.bottomRight)
