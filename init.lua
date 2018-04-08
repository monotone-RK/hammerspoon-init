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
      else
	 disableAllHotkeys()
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

remapKey({'ctrl'}, 'h', keyCode('delete'))              -- backspace
remapKey({'ctrl'}, 'd', keyCode('forwarddelete'))       -- delete

remapKey({'alt'}, 'w', keyCode('c', {'cmd'}))           -- copy
remapKey({'ctrl'}, 'w', keyCode('x', {'cmd'}))          -- cut
remapKey({'ctrl'}, 'k', killLine())                     -- kill-line
remapKey({'ctrl'}, 'y', keyCode('v', {'cmd'}))          -- paste
remapKey({'ctrl'}, '/', keyCode('z', {'cmd'}))          -- undo
remapKey({'alt'}, '/', keyCode('z', {'cmd', 'shift'}))  -- redo
