# NL-Mobile-Compatible

Neverlose-style UI for Roblox, made mobile friendly. Touch drag on the window and the floating button, a square Toggle button (Code font) to open/close, RightShift hotkey, and a 1.5x smaller layout so it fits phones.

Based on the Neverlose UI library (GhostDuckyy/UI-Libraries), rebuilt for touch.

## Load

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/RuHit-Scripts/NL-Mobile-Compatible/main/library.lua"))()
```

## Usage

```lua
local Window = Library:Window({ text = "My Hub" })
local sec = Window:TabSection({ text = "Combat" }):Tab({ text = "Aim", icon = "rbxassetid://7999345313" }):Section({ text = "Rage" })

sec:Toggle({ text = "Enable", state = false, callback = function(v) end })
sec:Slider({ text = "FOV", min = 10, max = 500, default = 120, callback = function(v) end })
sec:Dropdown({ text = "Part", list = {"Head","Torso"}, default = "Head", callback = function(s) end })
sec:Colorpicker({ text = "Color", color = Color3.new(1,1,1), callback = function(hsv) end })
sec:Keybind({ text = "Key", default = Enum.KeyCode.E, callback = function() end })
```

See `example.lua` for a full aimbot + ESP demo.

## Mobile

- Open/close with the floating `Toggle` button or RightShift.
- Drag the window by its body, drag the button anywhere. Both work with touch.

## Files

- `library.lua` - the UI library.
- `example.lua` - ready aim + ESP script using it.
