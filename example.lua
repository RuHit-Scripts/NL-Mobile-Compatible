--[[
	NL Aim & Visuals - compact demo on NL-Mobile library.
	Menu: RightShift or the floating Toggle button.
]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/RuHit-Scripts/NL-Mobile-Compatible/f5d202a/library.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

local cfg = {
	aimEnabled = false, aimFov = 120, aimSmooth = 0.2, aimTeamCheck = true, targetPart = "Head",
	espEnabled = false, espBoxes = true, espNames = true, espColor = Color3.fromRGB(0, 170, 255),
}

local function getTargets()
	local out = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= lp and p.Character and p.Character:FindFirstChild(cfg.targetPart) then
			local hum = p.Character:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 and (not cfg.aimTeamCheck or p.Team ~= lp.Team) then
				table.insert(out, p)
			end
		end
	end
	return out
end

local function getClosestTarget()
	local best, dist = nil, cfg.aimFov
	for _, p in ipairs(getTargets()) do
		local part = p.Character[cfg.targetPart]
		local pos, vis = cam:WorldToViewportPoint(part.Position)
		if vis then
			local m = (Vector2.new(pos.X, pos.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
			if m < dist then dist = m; best = part end
		end
	end
	return best
end

RunService.RenderStepped:Connect(function()
	if not cfg.aimEnabled then return end
	local t = getClosestTarget()
	if t then cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, t.Position), cfg.aimSmooth) end
end)

-- ESP
local cache = {}
local function ensure(p)
	if cache[p] then return cache[p] end
	local box = Drawing.new("Square"); box.Filled = false; box.Thickness = 1.5; box.Color = cfg.espColor
	local name = Drawing.new("Text"); name.Size = 14; name.Center = true; name.Outline = true; name.Color = cfg.espColor; name.Text = p.Name
	cache[p] = { box = box, name = name }
	return cache[p]
end
Players.PlayerRemoving:Connect(function(p) if cache[p] then cache[p].box:Remove(); cache[p].name:Remove(); cache[p]=nil end end)

RunService.RenderStepped:Connect(function()
	if not cfg.espEnabled then
		for _, d in pairs(cache) do d.box.Visible=false; d.name.Visible=false end
		return
	end
	for _, p in ipairs(getTargets()) do
		local d = ensure(p)
		local hrp = p.Character:FindFirstChild("HumanoidRootPart")
		local pos, vis = cam:WorldToViewportPoint(hrp.Position)
		local h = hrp.Size.Y * 6 / math.max(pos.Z, 1); local w = h * 0.5
		d.box.Visible = vis and cfg.espBoxes
		d.box.Position = Vector2.new(pos.X - w/2, pos.Y - h/2); d.box.Size = Vector2.new(w, h)
		d.name.Visible = vis and cfg.espNames
		d.name.Position = Vector2.new(pos.X, pos.Y - h/2 - 18)
	end
end)

-- UI
local Window = Library:Window({ text = "NL Aim" })
local combat = Window:TabSection({ text = "Combat" })
local aim = combat:Tab({ text = "Aimbot", icon = "rbxassetid://7999345313" }):Section({ text = "Rage" })
aim:Toggle({ text = "Enable", state = false, callback = function(v) cfg.aimEnabled = v end })
aim:Slider({ text = "FOV", min = 10, max = 500, default = 120, callback = function(v) cfg.aimFov = v end })
aim:Slider({ text = "Smooth", min = 1, max = 100, default = 20, callback = function(v) cfg.aimSmooth = v/100 end })
aim:Dropdown({ text = "Part", list = {"Head","HumanoidRootPart","Torso"}, default = "Head", callback = function(s) cfg.targetPart = s end })
aim:Toggle({ text = "Team Check", state = true, callback = function(v) cfg.aimTeamCheck = v end })

local vis = Window:TabSection({ text = "Visuals" })
local esp = vis:Tab({ text = "ESP", icon = "rbxassetid://7999345313" }):Section({ text = "Render" })
esp:Toggle({ text = "Enable", state = false, callback = function(v) cfg.espEnabled = v end })
esp:Toggle({ text = "Boxes", state = true, callback = function(v) cfg.espBoxes = v end })
esp:Toggle({ text = "Names", state = true, callback = function(v) cfg.espNames = v end })
esp:Colorpicker({ text = "Color", color = cfg.espColor, callback = function(hsv) cfg.espColor = hsv end })

print("[NL Aim] loaded.")
