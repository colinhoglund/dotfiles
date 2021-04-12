this = {}

function this.set(x, y, w, h)
    local win = hs.window.focusedWindow()
    local f = win:frame()

    f.x = x
    f.y = y
    f.w = w
    f.h = h

    win:setFrame(f)
end

function this.nextScreen()
    hs.window.focusedWindow():moveOneScreenEast()
end

function this.previousScreen()
    hs.window.focusedWindow():moveOneScreenWest()
end

function this.full()
    local max = hs.window.focusedWindow():screen():frame()
    this.set(max.x, max.y, max.w, max.h)
end

function this.left()
    local max = hs.window.focusedWindow():screen():frame()
    this.set(max.x, max.y, max.w / 2, max.h)
end

function this.right()
    local max = hs.window.focusedWindow():screen():frame()
    this.set(max.x + (max.w / 2), max.y, max.w / 2, max.h)
end

function this.top()
    local max = hs.window.focusedWindow():screen():frame()
    this.set(max.x, max.y, max.w, max.h / 2)
end

function this.bottom()
    local max = hs.window.focusedWindow():screen():frame()
    this.set(max.x, max.y + (max.h / 2), max.w, max.h / 2)
end

function this.topLeft()
    local max = hs.window.focusedWindow():screen():frame()
    this.set(max.x / 2, max.y / 2, max.w / 2, max.h / 2)
end

function this.topRight()
    local max = hs.window.focusedWindow():screen():frame()
    this.set(max.x + (max.w / 2), max.y / 2, max.w / 2, max.h / 2)
end

function this.bottomLeft()
    local max = hs.window.focusedWindow():screen():frame()
    this.set(max.x / 2, max.y + (max.h / 2), max.w / 2, max.h / 2)
end

function this.bottomRight()
    local max = hs.window.focusedWindow():screen():frame()
    this.set(max.x + (max.w / 2), max.y + (max.h / 2), max.w / 2, max.h / 2)
end

return this
