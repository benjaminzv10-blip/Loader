local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TPService = game:GetService("TeleportService")

local MESSAGE = "มึงอย่ารันสคิปในนี้ ไปรันในห้อง Config"
local GUI_NAME = "ConfigRoomWarning"
local REJOIN_DELAY = 10

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
	pcall(function()
		Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	end)
	LocalPlayer = Players.LocalPlayer
end

local PlayerGui = LocalPlayer and (LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 10))

local function getGuiParent()
	if type(gethui) == "function" then
		local ok, result = pcall(gethui)
		if ok and result then
			return result
		end
	end

	if PlayerGui then
		return PlayerGui
	end

	local ok = pcall(function()
		local test = CoreGui.Name
		return test
	end)
	if ok then
		return CoreGui
	end

	return PlayerGui
end

local function create(className, props, parent)
	local object = Instance.new(className)
	for key, value in pairs(props or {}) do
		object[key] = value
	end
	object.Parent = parent
	return object
end

local parent = getGuiParent()
if not parent then
	warn("[ConfigRoomWarning] No GUI parent found")
	return
end

local oldGui = parent:FindFirstChild(GUI_NAME)
if oldGui then
	oldGui:Destroy()
end

if _G.ConfigRoomWarningGui then
	pcall(function()
		_G.ConfigRoomWarningGui:Destroy()
	end)
end

local gui = create("ScreenGui", {
	Name = GUI_NAME,
	IgnoreGuiInset = true,
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, parent)

_G.ConfigRoomWarningGui = gui

local overlay = create("Frame", {
	Name = "Overlay",
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BackgroundTransparency = 0.35,
	BorderSizePixel = 0,
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(1, 1)
}, gui)

local main = create("Frame", {
	Name = "WarningBox",
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(18, 20, 26),
	BorderSizePixel = 0,
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.new(0.86, 0, 0, 150)
}, overlay)

create("UICorner", {
	CornerRadius = UDim.new(0, 10)
}, main)

create("UISizeConstraint", {
	MaxSize = Vector2.new(520, 170),
	MinSize = Vector2.new(260, 120)
}, main)

create("UIStroke", {
	Color = Color3.fromRGB(255, 80, 80),
	Thickness = 2,
	Transparency = 0.05
}, main)

local messageLabel = create("TextLabel", {
	Name = "Message",
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Position = UDim2.new(0, 24, 0, 18),
	Size = UDim2.new(1, -48, 1, -36),
	Text = MESSAGE .. "\nอีก " .. REJOIN_DELAY .. " วิจะรีจอย",
	TextColor3 = Color3.fromRGB(255, 235, 235),
	TextScaled = true,
	TextWrapped = true
}, main)

create("UITextSizeConstraint", {
	MaxTextSize = 34,
	MinTextSize = 18
}, messageLabel)

local function Rejoin()
	local player = Players.LocalPlayer
	if player then
		TPService:Teleport(game.PlaceId, player)
	end
end

task.spawn(function()
	for secondsLeft = REJOIN_DELAY, 1, -1 do
		if not gui.Parent then
			return
		end

		messageLabel.Text = MESSAGE .. "\nอีก " .. secondsLeft .. " วิจะรีจอย"
		task.wait(1)
	end

	if gui.Parent then
		messageLabel.Text = MESSAGE .. "\nกำลังรีจอย..."
	end

	Rejoin()
end)
