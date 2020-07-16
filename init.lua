-- Emacs Mark Mode settings begin

local showInfo = false
local function info(message)
    if showInfo then
        hs.alert.show(message)
    end
end
-- hs.hotkey.bind({'cmd', 'shift', 'ctrl'}, 'D', function() showInfo = not(showInfo) end)

local function getTableLength(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

local function isEqualTable(t1, t2)
    if getTableLength(t1) ~= getTableLength(t2) then return false end
    for k, v in pairs(t1) do
        if t2[k] ~= v then
            return false
        end
    end
    return true
end

local function pressKey(modifiers, key)
    modifiers = modifiers or {}
    hs.eventtap.keyStroke(modifiers, key, 20 * 1000)
end

local function pressKeyFunc(modifiers, key)
    return function() pressKey(modifiers, key) end
end

local function cursorWithMarkModeFunc(modifiers, key)
   return function()
      pressKey(modifiers, key)
      markMode:enable()
   end
end

SubMode = {}
SubMode.new = function(name, commandTable, othersFunc)
    local obj = {}
    obj.name = name
    obj.commandTable = commandTable
    obj.othersFunc = othersFunc
    obj.commandWatcher = {}
    obj.enable = function(self)
        info(self.name.." start")
        self.commandWatcher:start()
    end

    obj.disable = function(self)
        info(self.name.." end")
        self.commandWatcher:stop()
    end

    obj.commandWatcher = hs.eventtap.new( {hs.eventtap.event.types.keyDown},
        function(tapEvent)
            for k,v in pairs(obj.commandTable) do
                if v.key == hs.keycodes.map[tapEvent:getKeyCode()] and isEqualTable(v.modifiers, tapEvent:getFlags()) then
                    info(obj.name.." end")
                    obj.commandWatcher:stop()
                    if v.func then
                        v.func()
                    end
                    return true
                end
            end

            if obj.othersFunc then
                return othersFunc(tapEvent)
            end
        end)
    return obj
end

markMode = SubMode.new(
    "Mark Mode",
    {
        {modifiers = {ctrl = true}, key = 'space'}, -- only disables mark mode
        {modifiers = {ctrl = true}, key = 'g'}, -- only disables mark mode
        {modifiers = {ctrl = true}, key = 'w', func = pressKeyFunc({'cmd'}, 'x')},
        {modifiers = {alt = true},  key = 'w', func = pressKeyFunc({'cmd'}, 'c')}, 
        {modifiers = {ctrl = true}, key = 'p', func = cursorWithMarkModeFunc({'shift'}, 'up')},
        {modifiers = {ctrl = true}, key = 'n', func = cursorWithMarkModeFunc({'shift'}, 'down')},
        {modifiers = {ctrl = true}, key = 'b', func = cursorWithMarkModeFunc({'shift'}, 'left')},
        {modifiers = {ctrl = true}, key = 'f', func = cursorWithMarkModeFunc({'shift'}, 'right')},
        {modifiers = {ctrl = true}, key = 'a', func = cursorWithMarkModeFunc({'cmd', 'shift'}, 'left')},
        {modifiers = {ctrl = true}, key = 'e', func = cursorWithMarkModeFunc({'cmd', 'shift'}, 'right')},
	{modifiers = {ctrl = true}, key = 'v', func = cursorWithMarkModeFunc({'shift'}, 'pagedown')},
	{modifiers = {alt = true},  key = 'v', func = cursorWithMarkModeFunc({'shift'}, 'pageup')}
    },

    function(tapEvent) -- force shift on
        flags = tapEvent:getFlags()
        flags.shift = true
        tapEvent:setFlags(flags)
        return false
    end
)

-- Emacs Mark Mode settings end

local function keyCode(key, modifiers, callback)
   modifiers = modifiers or {}
   callback = callback or function() end
   return function()
      hs.eventtap.event.newKeyEvent(modifiers, string.lower(key), true):post()
      hs.timer.usleep(1000)
      hs.eventtap.event.newKeyEvent(modifiers, string.lower(key), false):post()
      callback()
   end
end

local function remapKey(modifiers, key, keyCode)
   hs.hotkey.bind(modifiers, key, keyCode, nil, keyCode)
end

local function killLine()
   return keyCode('right', {'cmd', 'shift'}, keyCode('x', {'cmd'}))
end

-- watch & switch hotkey settings

local function disableAllHotkeys()
   for k, v in pairs(hs.hotkey.getHotkeys()) do
      v['_hk']:disable()
   end
end

local function enableAllHotkeys()
   for k, v in pairs(hs.hotkey.getHotkeys()) do
      v['_hk']:enable()
   end
end

local function handleGlobalAppEvent(name, event, app)
   if event == hs.application.watcher.activated then
      -- hs.alert.show(name)
      -- if name == "Microsoft Word" then
      if string.find(name, "Microsoft") then
	 enableAllHotkeys()
      elseif name == "Google Chrome" then
	 enableAllHotkeys()
      elseif name == "Thunderbird" then
	 enableAllHotkeys()
      elseif name == "Skype" then
	 enableAllHotkeys()
      elseif name == "LINE" then
	 enableAllHotkeys()
      elseif name == "Slack" then
	 enableAllHotkeys()
      elseif name == "DeepL" then
	 enableAllHotkeys()
      else
	 disableAllHotkeys()
	 markMode:disable()
      end
   end
end

appsWatcher = hs.application.watcher.new(handleGlobalAppEvent)
appsWatcher:start()

remapKey({'ctrl'}, 'p', keyCode('up'))
remapKey({'ctrl'}, 'n', keyCode('down'))
remapKey({'ctrl'}, 'b', keyCode('left'))
remapKey({'ctrl'}, 'f', keyCode('right'))

remapKey({'ctrl'}, 'a', keyCode('left', {'cmd'}))
remapKey({'ctrl'}, 'e', keyCode('right', {'cmd'}))

remapKey({'ctrl'}, 'v', keyCode('pagedown'))
remapKey({'alt'}, 'v', keyCode('pageup'))

remapKey({'ctrl'}, 'h', keyCode('delete'))              -- backspace
remapKey({'ctrl'}, 'd', keyCode('forwarddelete'))       -- delete

remapKey({'alt'}, 'w', keyCode('c', {'cmd'}))           -- copy
remapKey({'ctrl'}, 'w', keyCode('x', {'cmd'}))          -- cut
remapKey({'ctrl'}, 'k', killLine())                     -- kill-line
remapKey({'ctrl'}, 'y', keyCode('v', {'cmd'}))          -- paste
remapKey({'ctrl'}, '/', keyCode('z', {'cmd'}))          -- undo
remapKey({'alt'}, '/', keyCode('z', {'cmd', 'shift'}))  -- redo

remapKey({'ctrl'}, 'space', function() markMode:enable() end)
