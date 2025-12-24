-- **************************************************
-- Some websites prohibit pasting, this script simulates system input events to bypass restrictions
-- **************************************************

hs.hotkey.bind({ 'cmd', 'shift' }, 'v', function() hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end)
