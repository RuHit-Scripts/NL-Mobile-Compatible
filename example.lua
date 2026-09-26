--[[
	NL Aim & Visuals - full demo on NL-Mobile library.
	Menu: RightShift or the floating Toggle button. Drag window by its top bar.
]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/RuHit-Scripts/NL-Mobile-Compatible/main/library.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

local cfg = {
	aimEnabled = false, aimFov = 150, aimSmooth = 0.2, teamCheck = true, part = "Head", triggerbot = false,
	espEnabled = false, boxes = true, names = true, healthbar = true, skeleton = false, distance = true,
	espColor = Color3.fromRGB(0, 170, 255), maxDist = 2000,
}

local function alive(p)
	if p == lp or not p.Character then return false end
	local hum = p.Character:FindFirstChildOfClass("Humanoid")
	local hrp = p.Character:FindFirstChild("HumanoidRootPart")
	return hum and hrp and hum.Health > 0
end

local function getTargets()
	local out = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if alive(p) and (not cfg.teamCheck or p.Team ~= lp.Team) then
			local d = (cam.CFrame.Position - p.Character.HumanoidRootPart.Position).Magnitude
			if d < cfg.maxDist then table.insert(out, p) end
		end
	end
	return out
end

local function closestTarget()
	local best, dist = nil, cfg.aimFov
	for _, p in ipairs(getTargets()) do
		local part = p.Character:FindFirstChild(cfg.part) or p.Character:FindFirstChild("Head")
		if part then
			local pos, vis = cam:WorldToViewportPoint(part.Position)
			if vis and pos.Z > 0 then
				local m = (Vector2.new(pos.X, pos.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
				if m < dist then dist = m; best = part end
			end
		end
	end
	return best
end

RunService.RenderStepped:Connect(function()
	if cfg.aimEnabled then
		local t = closestTarget()
		if t then cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, t.Position), cfg.aimSmooth) end
	end
end)

-- ===================== ESP (real, via Drawing API) =====================
local esp = {}
local function newEsp(p)
	local e = {
		box = Drawing.new("Square"),
		name = Drawing.new("Text"),
		dist = Drawing.new("Text"),
		hbBg = Drawing.new("Square"),
		hbFill = Drawing.new("Square"),
		lines = {},
	}
	e.box.Filled = false; e.box.Thickness = 1.5; e.box.Color = cfg.espColor
	e.name.Size = 14; e.name.Center = true; e.name.Outline = true; e.name.Text = p.Name; e.name.Color = cfg.espColor
	e.dist.Size = 12; e.dist.Center = true; e.dist.Outline = true; e.dist.Color = cfg.espColor
	e.hbBg.Filled = true; e.hbBg.Color = Color3.fromRGB(20,20,20)
	e.hbFill.Filled = true; e.hbFill.Color = Color3.fromRGB(0,255,90)
	for _ = 1, 6 do
		local l = Drawing.new("Line"); l.Thickness = 1; l.Color = cfg.espColor; table.insert(e.lines, l)
	end
	esp[p] = e
	return e
end

local function killEsp(p)
	local e = esp[p]; if not e then return end
	pcall(function() e.box:Remove(); e.name:Remove(); e.dist:Remove(); e.hbBg:Remove(); e.hbFill:Remove() end)
	for _, l in ipairs(e.lines) do pcall(function() l:Remove() end) end
	esp[p] = nil
end
Players.PlayerRemoving:Connect(killEsp)

local function renderEsp()
	for _, p in ipairs(getTargets()) do if not esp[p] then newEsp(p) end end
	for p, e in pairs(esp) do
		if not alive(p) then
			killEsp(p)
		else
			local char = p.Character
			local root = char.HumanoidRootPart
			local head = char:FindFirstChild("Head")
			local pos, vis = cam:WorldToViewportPoint(root.Position)
			local h = root.Size.Y * 8 / math.max(pos.Z, 1)
			local w = h * 0.55
			local x, y = pos.X - w/2, pos.Y - h/2
			local show = vis and pos.Z > 0
			e.box.Visible = show and cfg.boxes
			e.box.Position = Vector2.new(x, y); e.box.Size = Vector2.new(w, h)
			e.name.Visible = show and cfg.names
			e.name.Position = Vector2.new(pos.X, y - 18)
			e.dist.Visible = show and cfg.distance
			e.dist.Text = tostring(math.floor((cam.CFrame.Position - root.Position).Magnitude)) .. "m"
			e.dist.Position = Vector2.new(pos.X, y + h + 2)
			if cfg.healthbar then
				local hum = char:FindFirstChildOfClass("Humanoid")
				local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
				e.hbBg.Visible = show; e.hbBg.Position = Vector2.new(x - 6, y); e.hbBg.Size = Vector2.new(3, h)
				e.hbFill.Visible = show; e.hbFill.Position = Vector2.new(x - 6, y + h*(1-hp)); e.hbFill.Size = Vector2.new(3, h*hp)
			else
				e.hbBg.Visible = false; e.hbFill.Visible = false
			end
			if cfg.skeleton and head then
				for i, l in ipairs(e.lines) do
					l.Visible = show
					l.From = Vector2.new(pos.X, pos.Y)
					l.To = Vector2.new(pos.X, y + h*i/6)
				end
			else
				for _, l in ipairs(e.lines) do l.Visible = false end
			end
		end
	end
end

RunService.RenderStepped:Connect(function()
	if not cfg.espEnabled then
		for p, _ in pairs(esp) do killEsp(p) end
		return
	end
	renderEsp()
end)

-- ===================== UI =====================
local Window = Library:Window({ text = "NL Aim" })

local combatSec = Window:TabSection({ text = "Combat" })
local aimTab = combatSec:Tab({ text = "Aimbot", icon = "rbxassetid://7999345313" })
local rage = aimTab:Section({ text = "Rage" })
rage:Toggle({ text = "Enable", state = false, callback = function(v) cfg.aimEnabled = v end })
rage:Slider({ text = "FOV", min = 10, max = 500, default = 150, callback = function(v) cfg.aimFov = v end })
rage:Slider({ text = "Smooth", min = 1, max = 100, default = 20, callback = function(v) cfg.aimSmooth = v/100 end })
rage:Dropdown({ text = "Part", list = {"Head","HumanoidRootPart","UpperTorso"}, default = "Head", callback = function(s) cfg.part = s end })
local misc = aimTab:Section({ text = "Misc" })
misc:Toggle({ text = "Team Check", state = true, callback = function(v) cfg.teamCheck = v end })
misc:Toggle({ text = "Triggerbot", state = false, callback = function(v) cfg.triggerbot = v end })

local visSec = Window:TabSection({ text = "Visuals" })
local espTab = visSec:Tab({ text = "ESP", icon = "rbxassetid://7999345313" })
local render = espTab:Section({ text = "Render" })
render:Toggle({ text = "Enable ESP", state = false, callback = function(v) cfg.espEnabled = v end })
render:Toggle({ text = "Boxes", state = true, callback = function(v) cfg.boxes = v end })
render:Toggle({ text = "Names", state = true, callback = function(v) cfg.names = v end })
render:Toggle({ text = "Health Bar", state = true, callback = function(v) cfg.healthbar = v end })
render:Toggle({ text = "Distance", state = true, callback = function(v) cfg.distance = v end })
local style = espTab:Section({ text = "Style" })
style:Toggle({ text = "Skeleton", state = false, callback = function(v) cfg.skeleton = v end })
style:Slider({ text = "Max Dist", min = 100, max = 5000, default = 2000, callback = function(v) cfg.maxDist = v end })
style:Colorpicker({ text = "ESP Color", color = cfg.espColor, callback = function(hsv) cfg.espColor = hsv end })

print("[NL Aim] loaded.")
