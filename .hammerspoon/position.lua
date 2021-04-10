position = {}

function position.set(x, y, w, h)
    local win = hs.window.focusedWindow()
    local f = win:frame()

    f.x = x
    f.y = y
    f.w = w
    f.h = h

    win:setFrame(f)
end

function position.full()
    local max = hs.window.focusedWindow():screen():frame()
    position.set(max.x, max.y, max.w, max.h)
end

function position.left()
    local max = hs.window.focusedWindow():screen():frame()
    position.set(max.x, max.y, max.w / 2, max.h)
end

function position.right()
    local max = hs.window.focusedWindow():screen():frame()
    position.set(max.x + (max.w / 2), max.y, max.w / 2, max.h)
end

function position.top()
    local max = hs.window.focusedWindow():screen():frame()
    position.set(max.x, max.y, max.w, max.h / 2)
end

function position.bottom()
    local max = hs.window.focusedWindow():screen():frame()
    position.set(max.x, max.y + (max.h / 2), max.w, max.h / 2)
end

function position.topLeft()
    local max = hs.window.focusedWindow():screen():frame()
    position.set(max.x / 2, max.y / 2, max.w / 2, max.h / 2)
end

function position.topRight()
    local max = hs.window.focusedWindow():screen():frame()
    position.set(max.x + (max.w / 2), max.y / 2, max.w / 2, max.h / 2)
end

function position.bottomLeft()
    local max = hs.window.focusedWindow():screen():frame()
    position.set(max.x / 2, max.y + (max.h / 2), max.w / 2, max.h / 2)
end

function position.bottomRight()
    local max = hs.window.focusedWindow():screen():frame()
    position.set(max.x + (max.w / 2), max.y + (max.h / 2), max.w / 2, max.h / 2)
end
