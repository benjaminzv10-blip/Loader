local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local RuntimeConfig = {}
pcall(function()
    RuntimeConfig = (type(getgenv) == "function" and getgenv().BenJaMinZ_KeySystem) or _G.BenJaMinZ_KeySystem or {}
end)

local SCRIPT_ID = RuntimeConfig.ScriptId or "9b2fcfe32e150461b7cdb000ad8e1954"
local GET_KEY_URL = RuntimeConfig.GetKeyUrl or "https://ads.luarmor.net/get_key?for=BenJaMinZ_Hub-tjwoFAzSyLdc"
local SUPPORT_URL = RuntimeConfig.SupportUrl or "https://discord.gg/D2AaBZFztV"
local KEY_FILE = RuntimeConfig.KeyFile or "BenJaMinZhub_key.txt"
local DEFAULT_LOADER_URL = RuntimeConfig.LoaderUrl or ""
local LOADER_BY_PLACE = RuntimeConfig.LoadersByPlace or {
    [97598239454123] = "https://api.luarmor.net/files/v4/loaders/9b2fcfe32e150461b7cdb000ad8e1954.lua",
}

local Theme = {
    Bg = Color3.fromRGB(3, 8, 14),
    Panel = Color3.fromRGB(6, 15, 26),
    Panel2 = Color3.fromRGB(8, 22, 38),
    Cyan = Color3.fromRGB(0, 210, 255),
    CyanSoft = Color3.fromRGB(80, 235, 255),
    Blue = Color3.fromRGB(32, 116, 255),
    Text = Color3.fromRGB(226, 248, 255),
    Muted = Color3.fromRGB(120, 164, 180),
    Bad = Color3.fromRGB(255, 92, 126),
    Good = Color3.fromRGB(95, 255, 188),
}

local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = tostring(title or "BenJaMinZ Hub"),
            Text = tostring(text or ""),
            Duration = duration or 5,
        })
    end)
end

local function trim(value)
    return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function create(className, props, parent)
    local object = Instance.new(className)
    for key, value in pairs(props or {}) do
        object[key] = value
    end
    object.Parent = parent
    return object
end

local function saveKey(key)
    _G.KEY = key
    pcall(function()
        if writefile then
            writefile(KEY_FILE, key)
        end
    end)
end

local function clearKey()
    _G.KEY = nil
    pcall(function()
        if writefile then
            writefile(KEY_FILE, "")
        end
    end)
end

local function loadKey()
    local envKey = rawget(_G, "scriptkey") or rawget(_G, "script_key") or rawget(_G, "KEY")
    if type(scriptkey) == "string" and scriptkey ~= "" then
        return scriptkey
    end
    if type(script_key) == "string" and script_key ~= "" then
        return script_key
    end
    if type(envKey) == "string" and envKey ~= "" then
        return envKey
    end

    local fileKey
    pcall(function()
        if readfile and isfile and isfile(KEY_FILE) then
            fileKey = trim(readfile(KEY_FILE))
        end
    end)
    if type(fileKey) == "string" and fileKey ~= "" then
        return fileKey
    end

    return nil
end

local function formatExpiry(expiry)
    expiry = tonumber(expiry) or 0
    if expiry <= 0 then
        return "Lifetime key"
    end

    local secondsLeft = expiry - os.time()
    if secondsLeft <= 0 then
        return "Expired"
    end

    local days = math.floor(secondsLeft / 86400)
    local hours = math.floor((secondsLeft % 86400) / 3600)
    local minutes = math.floor((secondsLeft % 3600) / 60)

    local parts = {}
    if days > 0 then
        table.insert(parts, tostring(days) .. "d")
    end
    if hours > 0 then
        table.insert(parts, tostring(hours) .. "h")
    end
    if minutes > 0 or #parts == 0 then
        table.insert(parts, tostring(minutes) .. "m")
    end

    return table.concat(parts, " ")
end

local oldMain = PlayerGui:FindFirstChild("BenJaMinZBlueKeyUI")
if oldMain then
    oldMain:Destroy()
end
local oldOptions = PlayerGui:FindFirstChild("BenJaMinZBlueKeyOptions")
if oldOptions then
    oldOptions:Destroy()
end

local api
local apiOk = false
local apiErr = "Loading API..."
local apiLoading = false

local function ensureApi()
    if apiOk and api and type(api.check_key) == "function" then
        return true
    end

    if apiLoading then
        while apiLoading do
            task.wait(0.1)
        end
        return apiOk and api and type(api.check_key) == "function"
    end

    apiLoading = true
    local ok, result = pcall(function()
        local loadedApi = loadstring(game:HttpGet("https://sdkapi-public.luarmor.net/library.lua"))()
        loadedApi.script_id = SCRIPT_ID
        return loadedApi
    end)
    apiLoading = false

    if ok and result and type(result.check_key) == "function" then
        api = result
        apiOk = true
        apiErr = nil
        return true
    end

    api = nil
    apiOk = false
    apiErr = tostring(result or "Luarmor API failed")
    return false
end

local gui = create("ScreenGui", {
    Name = "BenJaMinZBlueKeyUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
}, PlayerGui)

local dim = create("Frame", {
    Name = "Dim",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.28,
    BorderSizePixel = 0,
}, gui)

local glow1 = create("Frame", {
    Name = "GlowOuter",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(464, 292),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
}, dim)
create("UICorner", { CornerRadius = UDim.new(0, 18) }, glow1)
local glowStroke1 = create("UIStroke", {
    Color = Theme.Cyan,
    Thickness = 5,
    Transparency = 0.72,
}, glow1)

local glow2 = create("Frame", {
    Name = "GlowInner",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(438, 266),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
}, dim)
create("UICorner", { CornerRadius = UDim.new(0, 14) }, glow2)
local glowStroke2 = create("UIStroke", {
    Color = Theme.CyanSoft,
    Thickness = 2,
    Transparency = 0.35,
}, glow2)

local main = create("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(420, 248),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0,
}, dim)
create("UICorner", { CornerRadius = UDim.new(0, 12) }, main)
local mainStroke = create("UIStroke", {
    Color = Theme.Cyan,
    Thickness = 1.7,
    Transparency = 0.08,
}, main)
local mainGradient = create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Bg),
        ColorSequenceKeypoint.new(0.5, Theme.Panel2),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(2, 9, 18)),
    }),
    Rotation = 90,
}, main)

local topLine = create("Frame", {
    Name = "TopLine",
    Position = UDim2.fromOffset(16, 44),
    Size = UDim2.new(1, -32, 0, 1),
    BackgroundColor3 = Theme.Cyan,
    BackgroundTransparency = 0.18,
    BorderSizePixel = 0,
}, main)
create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 80, 120)),
        ColorSequenceKeypoint.new(0.5, Theme.CyanSoft),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 80, 120)),
    }),
}, topLine)

local logo = create("ImageLabel", {
    Name = "Logo",
    Position = UDim2.fromOffset(14, 8),
    Size = UDim2.fromOffset(32, 32),
    BackgroundTransparency = 1,
    Image = RuntimeConfig.LogoImage or "rbxassetid://130000599184953",
    ImageColor3 = Color3.fromRGB(220, 250, 255),
}, main)

local title = create("TextLabel", {
    Name = "Title",
    Position = UDim2.fromOffset(54, 6),
    Size = UDim2.new(1, -98, 0, 22),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = RuntimeConfig.Title or "BenJaMinZ Hub",
    TextColor3 = Theme.Text,
    TextSize = 21,
    TextStrokeColor3 = Theme.Cyan,
    TextStrokeTransparency = 0.35,
    TextXAlignment = Enum.TextXAlignment.Left,
}, main)
create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Text),
        ColorSequenceKeypoint.new(0.45, Theme.CyanSoft),
        ColorSequenceKeypoint.new(1, Theme.Blue),
    }),
}, title)

local subtitle = create("TextLabel", {
    Name = "Subtitle",
    Position = UDim2.fromOffset(55, 27),
    Size = UDim2.new(1, -110, 0, 15),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamMedium,
    Text = "Key System",
    TextColor3 = Theme.Muted,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
}, main)

local closeButton = create("TextButton", {
    Name = "Close",
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -10, 0, 9),
    Size = UDim2.fromOffset(28, 26),
    BackgroundColor3 = Color3.fromRGB(7, 23, 34),
    BorderSizePixel = 0,
    Font = Enum.Font.GothamBold,
    Text = "X",
    TextColor3 = Theme.CyanSoft,
    TextSize = 14,
    TextStrokeColor3 = Theme.Cyan,
    TextStrokeTransparency = 0.18,
}, main)
create("UICorner", { CornerRadius = UDim.new(0, 7) }, closeButton)
create("UIStroke", { Color = Theme.Cyan, Thickness = 1, Transparency = 0.35 }, closeButton)

local inputFrame = create("Frame", {
    Name = "InputFrame",
    Position = UDim2.fromOffset(24, 70),
    Size = UDim2.new(1, -48, 0, 42),
    BackgroundColor3 = Color3.fromRGB(3, 13, 24),
    BorderSizePixel = 0,
}, main)
create("UICorner", { CornerRadius = UDim.new(0, 8) }, inputFrame)
create("UIStroke", { Color = Theme.Cyan, Thickness = 1.2, Transparency = 0.28 }, inputFrame)

local input = create("TextBox", {
    Name = "InputKey",
    Position = UDim2.fromOffset(12, 0),
    Size = UDim2.new(1, -24, 1, 0),
    BackgroundTransparency = 1,
    ClearTextOnFocus = false,
    Font = Enum.Font.GothamSemibold,
    PlaceholderText = "Paste your Luarmor key here",
    PlaceholderColor3 = Color3.fromRGB(80, 130, 150),
    Text = "",
    TextColor3 = Theme.Text,
    TextSize = 15,
    TextXAlignment = Enum.TextXAlignment.Left,
}, inputFrame)

local statusLabel = create("TextLabel", {
    Name = "Status",
    Position = UDim2.fromOffset(26, 119),
    Size = UDim2.new(1, -52, 0, 20),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamMedium,
    Text = "Ready. Get key, enter it, then check.",
    TextColor3 = Theme.Muted,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
}, main)

local function setStatus(text, color)
    statusLabel.Text = tostring(text or "")
    statusLabel.TextColor3 = color or Theme.Muted
end

local ButtonTextLayers = {}
local function setButtonText(button, text)
    button.Text = ""
    local layers = ButtonTextLayers[button]
    if layers then
        for _, layer in ipairs(layers) do
            layer.Text = tostring(text or "")
        end
    end
end

local function makeButton(name, text, xScale, xOffset, widthScale, widthOffset)
    local button = create("TextButton", {
        Name = name,
        Position = UDim2.new(xScale, xOffset, 0, 152),
        Size = UDim2.new(widthScale, widthOffset, 0, 38),
        BackgroundColor3 = Color3.fromRGB(5, 27, 44),
        BackgroundTransparency = 0.04,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.GothamBold,
        Text = "",
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextStrokeColor3 = Theme.CyanSoft,
        TextStrokeTransparency = 0.22,
    }, main)
    create("UICorner", { CornerRadius = UDim.new(0, 5) }, button)
    local stroke = create("UIStroke", {
        Color = Theme.Cyan,
        Thickness = 1.5,
        Transparency = 0.08,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, button)
    create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(4, 18, 30)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8, 45, 68)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(3, 16, 27)),
        }),
        Rotation = 90,
    }, button)

    local shine = create("Frame", {
        Name = "TopShine",
        Position = UDim2.fromOffset(2, 2),
        Size = UDim2.new(1, -4, 0, 1),
        BackgroundColor3 = Theme.CyanSoft,
        BackgroundTransparency = 0.32,
        BorderSizePixel = 0,
        ZIndex = button.ZIndex + 1,
    }, button)

    local glowOffsets = {
        Vector2.new(-1, 0),
        Vector2.new(1, 0),
        Vector2.new(0, -1),
        Vector2.new(0, 1),
    }
    local layers = {}

    for index, offset in ipairs(glowOffsets) do
        local glow = create("TextLabel", {
            Name = "TextGlow" .. tostring(index),
            Position = UDim2.new(0, offset.X, 0, offset.Y),
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = text,
            TextColor3 = Theme.Cyan,
            TextSize = 14,
            TextTransparency = 0.72,
            TextStrokeColor3 = Theme.CyanSoft,
            TextStrokeTransparency = 0.55,
            ZIndex = button.ZIndex + 1,
        }, button)
        table.insert(layers, glow)
    end

    local label = create("TextLabel", {
        Name = "Text",
        Position = UDim2.fromScale(0, 0),
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextStrokeColor3 = Theme.CyanSoft,
        TextStrokeTransparency = 0.45,
        ZIndex = button.ZIndex + 2,
    }, button)
    table.insert(layers, label)
    ButtonTextLayers[button] = layers

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.14), {
            BackgroundColor3 = Color3.fromRGB(8, 58, 82),
            BackgroundTransparency = 0,
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.14), { Transparency = 0, Thickness = 2 }):Play()
        TweenService:Create(shine, TweenInfo.new(0.14), { BackgroundTransparency = 0.12 }):Play()
        for index, layer in ipairs(layers) do
            TweenService:Create(layer, TweenInfo.new(0.14), {
                TextColor3 = index == #layers and Theme.CyanSoft or Theme.CyanSoft,
                TextTransparency = index == #layers and 0 or 0.58,
                TextStrokeTransparency = index == #layers and 0.32 or 0.42,
            }):Play()
        end
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.14), {
            BackgroundColor3 = Color3.fromRGB(5, 27, 44),
            BackgroundTransparency = 0.04,
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.14), { Transparency = 0.08, Thickness = 1.5 }):Play()
        TweenService:Create(shine, TweenInfo.new(0.14), { BackgroundTransparency = 0.32 }):Play()
        for index, layer in ipairs(layers) do
            TweenService:Create(layer, TweenInfo.new(0.14), {
                TextColor3 = index == #layers and Theme.Text or Theme.Cyan,
                TextTransparency = index == #layers and 0 or 0.72,
                TextStrokeTransparency = index == #layers and 0.45 or 0.55,
            }):Play()
        end
    end)

    for index, layer in ipairs(layers) do
        TweenService:Create(layer, TweenInfo.new(1.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            TextTransparency = index == #layers and 0 or 0.6,
            TextStrokeTransparency = index == #layers and 0.34 or 0.42,
        }):Play()
    end

    return button
end

local getKeyButton = makeButton("GetKey", "GET KEY", 0, 24, 0.5, -31)
local checkButton = makeButton("CheckKey", "CHECK KEY", 0.5, 7, 0.5, -31)

local clearButton = makeButton("ClearKey", "CLEAR", 0.33, 14, 0.34, -28)
clearButton.Position = UDim2.new(0, 24, 0, 202)
clearButton.Size = UDim2.new(0.5, -31, 0, 30)
clearButton.TextSize = 12

local discordButton = makeButton("Support", "SUPPORT", 0.67, -4, 0.33, -20)
discordButton.Position = UDim2.new(0.5, 7, 0, 202)
discordButton.Size = UDim2.new(0.5, -31, 0, 30)
discordButton.TextSize = 12

local dragging = false
local dragInput
local dragStart
local startPosition

local function beginDrag(inputObject)
    if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = inputObject.Position
        startPosition = main.Position
        inputObject.Changed:Connect(function()
            if inputObject.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end

main.InputBegan:Connect(beginDrag)
title.InputBegan:Connect(beginDrag)
logo.InputBegan:Connect(beginDrag)

main.InputChanged:Connect(function(inputObject)
    if inputObject.UserInputType == Enum.UserInputType.MouseMovement or inputObject.UserInputType == Enum.UserInputType.Touch then
        dragInput = inputObject
    end
end)

UserInputService.InputChanged:Connect(function(inputObject)
    if inputObject == dragInput and dragging then
        local delta = inputObject.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
        glow1.Position = main.Position
        glow2.Position = main.Position
    end
end)

TweenService:Create(glowStroke1, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
    Transparency = 0.42,
}):Play()
TweenService:Create(glowStroke2, TweenInfo.new(1.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
    Transparency = 0.05,
}):Play()
TweenService:Create(mainStroke, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
    Transparency = 0.0,
}):Play()

task.spawn(function()
    while gui.Parent do
        mainGradient.Rotation = (mainGradient.Rotation + 1) % 360
        task.wait(0.03)
    end
end)

local function destroyUI()
    if gui then
        gui:Destroy()
    end
end

local function runLoader(key)
    script_key = key
    _G.script_key = key

    if type(RuntimeConfig.OnValid) == "function" then
        RuntimeConfig.OnValid(key)
        return true
    end

    local globalCallback = rawget(_G, "BenJaMinZHub_OnKeyValid")
    if type(globalCallback) == "function" then
        globalCallback(key)
        return true
    end

    local loaderUrl = DEFAULT_LOADER_URL
    if loaderUrl == "" then
        loaderUrl = LOADER_BY_PLACE[game.PlaceId] or ""
    end

    if loaderUrl ~= "" then
        loadstring(game:HttpGet(loaderUrl))()
        return true
    end

    notify("BenJaMinZ Hub", "Key valid, but no loader URL configured.", 6)
    return false
end

local checking = false
local function checkKey(key)
    if checking then
        setStatus("Checking key already...", Theme.CyanSoft)
        return false
    end

    key = trim(key)
    if key == "" then
        setStatus("Please enter your key.", Theme.Bad)
        notify("BenJaMinZ Hub", "Please enter your key.", 4)
        return false
    end

    if not ensureApi() then
        setStatus("Luarmor API failed: " .. tostring(apiErr):sub(1, 70), Theme.Bad)
        notify("BenJaMinZ Hub", "Luarmor API failed.", 5)
        return false
    end

    checking = true
    setStatus("Checking key with Luarmor API...", Theme.CyanSoft)
    setButtonText(checkButton, "CHECKING...")

    local ok, status = pcall(function()
        return api.check_key(key)
    end)

    checking = false
    setButtonText(checkButton, "CHECK KEY")

    if not ok then
        setStatus("API request failed.", Theme.Bad)
        notify("BenJaMinZ Hub", "API request failed: " .. tostring(status):sub(1, 90), 5)
        return false
    end

    status = status or {}
    local code = tostring(status.code or "UNKNOWN")
    print("[BenJaMinZ Key] check:", code, tostring(status.message))

    if code == "KEY_VALID" then
        local expiryText = formatExpiry(status.data and status.data.auth_expire)
        saveKey(key)
        setStatus("Key valid. Loading...", Theme.Good)
        notify("BenJaMinZ Hub", "Key valid: " .. expiryText, 5)
        destroyUI()
        runLoader(key)
        return true
    elseif code == "KEY_EXPIRED" then
        clearKey()
        setStatus("Key expired. Get a new key.", Theme.Bad)
        notify("BenJaMinZ Hub", "Key expired. Get a new key.", 5)
    elseif code == "KEY_HWID_LOCKED" then
        setStatus("HWID mismatch. Reset HWID in Discord bot.", Theme.Bad)
        notify("BenJaMinZ Hub", "HWID mismatch. Reset HWID in Discord bot.", 6)
    elseif code == "KEY_INCORRECT" or code == "KEY_INVALID" then
        clearKey()
        setStatus("Invalid key. Try again.", Theme.Bad)
        notify("BenJaMinZ Hub", "Invalid key. Try again.", 5)
    elseif code == "KEY_BANNED" then
        clearKey()
        setStatus("Key is blacklisted.", Theme.Bad)
        notify("BenJaMinZ Hub", "Key is blacklisted.", 5)
    elseif code == "SCRIPT_ID_INCORRECT" or code == "SCRIPT_ID_INVALID" then
        setStatus("Script ID mismatch. Current: " .. tostring(SCRIPT_ID):sub(1, 8) .. "...", Theme.Bad)
        notify("BenJaMinZ Hub", "SCRIPT_ID does not match this key/project.", 6)
    elseif code == "INVALID_EXECUTOR" then
        setStatus("Unsupported executor.", Theme.Bad)
        notify("BenJaMinZ Hub", "Unsupported executor.", 5)
    else
        setStatus("API error: " .. tostring(status.message or code), Theme.Bad)
        notify("BenJaMinZ Hub", "API error: " .. tostring(status.message or code), 5)
    end

    return false
end

getKeyButton.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(GET_KEY_URL)
        setStatus("Get-key link copied to clipboard.", Theme.CyanSoft)
        notify("BenJaMinZ Hub", "Get-key link copied.", 4)
    else
        setStatus(GET_KEY_URL, Theme.CyanSoft)
        notify("BenJaMinZ Hub", "Copy function not supported. Link shown in status.", 5)
    end
end)

checkButton.MouseButton1Click:Connect(function()
    task.spawn(checkKey, input.Text)
end)

clearButton.MouseButton1Click:Connect(function()
    input.Text = ""
    clearKey()
    setStatus("Saved key cleared.", Theme.CyanSoft)
    notify("BenJaMinZ Hub", "Saved key cleared.", 4)
end)

discordButton.MouseButton1Click:Connect(function()
    if SUPPORT_URL ~= "" and setclipboard then
        setclipboard(SUPPORT_URL)
        setStatus("Support link copied.", Theme.CyanSoft)
        notify("BenJaMinZ Hub", "Support link copied.", 4)
    else
        setStatus("Clipboard write not supported.", Theme.Bad)
    end
end)

closeButton.MouseButton1Click:Connect(destroyUI)

local initialKey = loadKey()
if initialKey then
    input.Text = initialKey
    setStatus("Saved key loaded. Press CHECK KEY.", Theme.CyanSoft)
else
    setStatus("Ready. Get key, enter it, then check.", Theme.Muted)
end
