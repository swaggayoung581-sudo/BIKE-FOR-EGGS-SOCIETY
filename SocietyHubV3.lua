-- SOCIETY HUB v3 | LocalScript
-- Chrome bubble font everywhere, box only when closed (outside),
-- rounded bubble style inside, changeable speed

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local parentGui
pcall(function() parentGui = (gethui and gethui()) or game:GetService("CoreGui") end)
if not parentGui then parentGui = player:WaitForChild("PlayerGui") end
pcall(function()
	local old = parentGui:FindFirstChild("SocietyHub")
	if old then old:Destroy() end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "SocietyHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = parentGui

local BLACK, WHITE = Color3.new(0, 0, 0), Color3.new(1, 1, 1)
local FONT = Enum.Font.FredokaOne -- bubble font (closest to the logo)

-- chrome gradients
local chromeBorder = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 40)),
	ColorSequenceKeypoint.new(0.25, Color3.fromRGB(235, 235, 235)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(90, 90, 90)),
	ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 40)),
})
-- vertical metal look for text (bright top, dark middle, bright bottom)
local chromeText = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.45, Color3.fromRGB(150, 150, 155)),
	ColorSequenceKeypoint.new(0.55, Color3.fromRGB(70, 70, 75)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 230, 235)),
})

local rotators = {}
local function addRotatingGradient(parent, speed)
	local g = Instance.new("UIGradient")
	g.Color = chromeBorder
	g.Parent = parent
	table.insert(rotators, {g = g, speed = speed or 60})
	return g
end

local function corner(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = r or UDim.new(0, 8)
	c.Parent = p
	return c
end

local function stroke(p, t)
	local s = Instance.new("UIStroke")
	s.Thickness = t or 2
	s.Color = WHITE
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = p
	return s
end

-- chrome bubble text label
local function chromeLabel(parent, text, size, zindex)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Size = UDim2.fromScale(1, 1)
	l.Text = text
	l.Font = FONT
	l.TextSize = size
	l.TextColor3 = WHITE
	l.ZIndex = zindex or 6
	l.Parent = parent
	local g = Instance.new("UIGradient")
	g.Color = chromeText
	g.Rotation = 90
	g.Parent = l
	local s = Instance.new("UIStroke") -- dark outline for the bubble look
	s.Thickness = 1.5
	s.Color = Color3.fromRGB(10, 10, 10)
	s.Parent = l
	return l
end

local function makeDraggable(handle, target)
	local dragging, startPos, startInput, moved = false, nil, nil, false
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging, moved = true, false
			startInput = input.Position
			startPos = target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - startInput
			if d.Magnitude > 6 then moved = true end
			target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
	return function() return moved end
end

----------------------------------------------------------------
-- CLOSED: box (outside only)
----------------------------------------------------------------
local box = Instance.new("TextButton")
box.Name = "SocietyHubBox"
box.Size = UDim2.fromOffset(124, 38)
box.Position = UDim2.new(0, 15, 0.5, -19)
box.BackgroundColor3 = BLACK
box.Text = ""
box.AutoButtonColor = false
box.Parent = gui
corner(box, UDim.new(0, 6))
addRotatingGradient(stroke(box, 2.5), 120)
chromeLabel(box, "SOCIETY HUB", 17, 3)
local boxMoved = makeDraggable(box, box)

----------------------------------------------------------------
-- OPEN: bubble-style menu (rounded, no box look)
----------------------------------------------------------------
local MENU_W, MENU_H = 220, 262

local menu = Instance.new("Frame")
menu.Name = "SocietyHubMenu"
menu.Size = UDim2.fromOffset(MENU_W, MENU_H)
menu.Position = UDim2.new(0.5, -MENU_W / 2, 0.5, -MENU_H / 2)
menu.BackgroundColor3 = BLACK
menu.ClipsDescendants = true
menu.Visible = false
menu.Parent = gui
corner(menu, UDim.new(0, 26))
addRotatingGradient(stroke(menu, 3), 90)

-- rain (black & white)
local rainLayer = Instance.new("Frame")
rainLayer.Size = UDim2.fromScale(1, 1)
rainLayer.BackgroundTransparency = 1
rainLayer.ZIndex = 1
rainLayer.Parent = menu

local drops = {}
local rng = Random.new()
for i = 1, 30 do
	local d = Instance.new("Frame")
	d.BorderSizePixel = 0
	d.BackgroundColor3 = (i % 2 == 0) and WHITE or Color3.fromRGB(110, 110, 110)
	d.BackgroundTransparency = rng:NextNumber(0.4, 0.8)
	d.Size = UDim2.fromOffset(2, rng:NextInteger(8, 20))
	d.Position = UDim2.fromOffset(rng:NextInteger(0, MENU_W), rng:NextInteger(-MENU_H, 0))
	d.ZIndex = 1
	d.Parent = rainLayer
	table.insert(drops, {f = d, speed = rng:NextNumber(150, 380)})
end

local titleHolder = Instance.new("Frame")
titleHolder.Size = UDim2.new(1, -40, 0, 34)
titleHolder.BackgroundTransparency = 1
titleHolder.ZIndex = 5
titleHolder.Parent = menu
chromeLabel(titleHolder, "SOCIETY HUB", 19, 6)
makeDraggable(titleHolder, menu)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(24, 24)
closeBtn.Position = UDim2.new(1, -32, 0, 6)
closeBtn.BackgroundColor3 = BLACK
closeBtn.Text = ""
closeBtn.ZIndex = 6
closeBtn.Parent = menu
corner(closeBtn, UDim.new(1, 0))
stroke(closeBtn, 1.5)
chromeLabel(closeBtn, "X", 14, 7)

local statusHolder = Instance.new("Frame")
statusHolder.Size = UDim2.new(1, -16, 0, 18)
statusHolder.Position = UDim2.new(0, 8, 1, -22)
statusHolder.BackgroundTransparency = 1
statusHolder.ZIndex = 5
statusHolder.Parent = menu
local statusLabel = chromeLabel(statusHolder, "Ready", 13, 6)
local function setStatus(t) statusLabel.Text = t end

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -20, 1, -64)
list.Position = UDim2.new(0, 10, 0, 38)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 2
list.ScrollBarImageColor3 = WHITE
list.CanvasSize = UDim2.new()
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.ZIndex = 5
list.Parent = menu
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 7)
layout.Parent = list

-- pill (bubble) buttons inside the menu
local function styleButton(b)
	b.Size = UDim2.new(1, -4, 0, 32)
	b.BackgroundColor3 = BLACK
	b.Text = ""
	b.AutoButtonColor = true
	b.ZIndex = 6
	corner(b, UDim.new(1, 0))
	return stroke(b, 1.5)
end

local function addButton(text, cb)
	local b = Instance.new("TextButton")
	styleButton(b)
	b.Parent = list
	chromeLabel(b, text, 15, 7)
	b.MouseButton1Click:Connect(cb)
	return b
end

local function addToggle(text, cb)
	local state = false
	local b = Instance.new("TextButton")
	local st = styleButton(b)
	b.Parent = list
	local lbl = chromeLabel(b, "", 15, 7)
	local function refresh()
		lbl.Text = text .. ": " .. (state and "ON" or "OFF")
		b.BackgroundColor3 = state and Color3.fromRGB(70, 70, 75) or BLACK
		st.Thickness = state and 3 or 1.5
	end
	refresh()
	b.MouseButton1Click:Connect(function()
		state = not state
		refresh()
		cb(state)
	end)
	return b, lbl
end

----------------------------------------------------------------
-- FEATURES
----------------------------------------------------------------
local function getHRP()
	local c = player.Character
	return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
	local c = player.Character
	return c and c:FindFirstChildOfClass("Humanoid")
end

-- Save / TP position
local savedCFrame
addButton("Save Position", function()
	local hrp = getHRP()
	if hrp then
		savedCFrame = hrp.CFrame
		setStatus("Position saved")
	end
end)
addButton("TP Position", function()
	local hrp = getHRP()
	if hrp and savedCFrame then
		hrp.CFrame = savedCFrame
		setStatus("Teleported")
	else
		setStatus("Save a position first")
	end
end)

-- Instant Grab
local grabOn = false
local originalHold = setmetatable({}, {__mode = "k"})
local function applyGrab(p)
	if p:IsA("ProximityPrompt") then
		if originalHold[p] == nil then originalHold[p] = p.HoldDuration end
		p.HoldDuration = 0
	end
end
workspace.DescendantAdded:Connect(function(d)
	if grabOn then applyGrab(d) end
end)
addToggle("Instant Grab", function(on)
	grabOn = on
	for _, d in ipairs(workspace:GetDescendants()) do
		if d:IsA("ProximityPrompt") then
			if on then
				applyGrab(d)
			elseif originalHold[d] then
				d.HoldDuration = originalHold[d]
			end
		end
	end
	setStatus("Instant Grab " .. (on and "ON" or "OFF"))
end)

-- Speed (changeable)
local speedValue = 550
local speedOn = false
local defaultSpeed = 16

local _, speedLbl
_, speedLbl = addToggle("Speed", function(on)
	speedOn = on
	local h = getHum()
	if h then
		if on then defaultSpeed = h.WalkSpeed else h.WalkSpeed = defaultSpeed end
	end
	setStatus("Speed " .. (on and "ON" or "OFF"))
end)

-- speed input box (type any number)
local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(1, -4, 0, 32)
speedBox.BackgroundColor3 = BLACK
speedBox.Text = tostring(speedValue)
speedBox.PlaceholderText = "Speed value"
speedBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
speedBox.TextColor3 = WHITE
speedBox.Font = FONT
speedBox.TextSize = 16
speedBox.ClearTextOnFocus = false
speedBox.ZIndex = 6
speedBox.Parent = list
corner(speedBox, UDim.new(1, 0))
stroke(speedBox, 1.5)
local sg = Instance.new("UIGradient")
sg.Color = chromeText
sg.Rotation = 90
sg.Parent = speedBox
-- (gradient on a TextBox also tints its fill, so keep the fill black via transparency trick)
speedBox.BackgroundTransparency = 1
local speedBg = Instance.new("Frame")
speedBg.Size = UDim2.new(1, -4, 0, 32)
speedBg.BackgroundColor3 = BLACK
speedBg.ZIndex = 5
speedBg.LayoutOrder = speedBox.LayoutOrder
speedBg.Parent = list
speedBg:Destroy() -- not needed; transparent box on dark menu is fine

local function applySpeedText()
	local n = tonumber(speedBox.Text)
	if n then
		speedValue = math.clamp(n, 0, 10000)
		speedBox.Text = tostring(speedValue)
		setStatus("Speed set to " .. speedValue)
	else
		speedBox.Text = tostring(speedValue)
		setStatus("Numbers only")
	end
end
speedBox.FocusLost:Connect(applySpeedText)

RunService.Heartbeat:Connect(function()
	if speedOn then
		local h = getHum()
		if h and h.WalkSpeed ~= speedValue then h.WalkSpeed = speedValue end
	end
end)

player.CharacterAdded:Connect(function()
	task.wait(1)
	if speedOn then
		local h = getHum()
		if h then h.WalkSpeed = speedValue end
	end
end)

----------------------------------------------------------------
-- OPEN / CLOSE
----------------------------------------------------------------
local function openMenu()
	menu.Position = UDim2.fromOffset(box.AbsolutePosition.X, box.AbsolutePosition.Y)
	menu.Size = UDim2.fromOffset(0, 0)
	menu.Visible = true
	box.Visible = false
	TweenService:Create(menu, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Size = UDim2.fromOffset(MENU_W, MENU_H)}):Play()
end
local function closeMenu()
	local t = TweenService:Create(menu, TweenInfo.new(0.15), {Size = UDim2.fromOffset(0, 0)})
	t:Play()
	t.Completed:Wait()
	menu.Visible = false
	box.Position = UDim2.fromOffset(menu.AbsolutePosition.X, menu.AbsolutePosition.Y)
	box.Visible = true
end

box.MouseButton1Click:Connect(function()
	if not boxMoved() then openMenu() end
end)
closeBtn.MouseButton1Click:Connect(closeMenu)

----------------------------------------------------------------
-- ANIMATION LOOP
----------------------------------------------------------------
RunService.RenderStepped:Connect(function(dt)
	for _, r in ipairs(rotators) do
		r.g.Rotation = (r.g.Rotation + r.speed * dt) % 360
	end
	if menu.Visible then
		local h = menu.AbsoluteSize.Y
		for _, d in ipairs(drops) do
			local p = d.f.Position
			local y = p.Y.Offset + d.speed * dt
			if y > h then
				d.f.Position = UDim2.fromOffset(rng:NextInteger(0, MENU_W), -20)
			else
				d.f.Position = UDim2.fromOffset(p.X.Offset, y)
			end
		end
	end
end)
