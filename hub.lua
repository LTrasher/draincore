--[[
    DrainCore Interface Library
    by DrainDev
]]
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local DrainCore = {}
DrainCore.Flags = {}
DrainCore.Themes = {
    Default = {
        Background = Color3.fromRGB(0, 0, 0),
        TextColor = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(0, 255, 0),
        AccentRed = Color3.fromRGB(255, 0, 0),
        Border = Color3.fromRGB(100, 100, 100),
        DarkBackground = Color3.fromRGB(20, 20, 20),
        LightBackground = Color3.fromRGB(30, 30, 30),
        HighlightBar = Color3.fromRGB(255, 255, 255),
        SearchBG = Color3.fromRGB(10, 10, 10),
    },
}

local currentTheme = DrainCore.Themes.Default

-- UI Utility Functions
local function createStyledFrame(parent, size, position, name, bgColor, transparency)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = position
    frame.Name = name
    frame.BackgroundColor3 = bgColor or currentTheme.DarkBackground
    frame.BackgroundTransparency = transparency or 0
    frame.BorderSizePixel = 0
    frame.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 10, 10)
    shadow.ZIndex = -1
    shadow.Parent = frame
    local glow = Instance.new("UIStroke")
    glow.Thickness = 1
    glow.Color = currentTheme.Border
    glow.Transparency = 0.9
    glow.Parent = frame
    return frame
end

local function createTextButton(parent, size, position, name, text, bgColor, textColor, font, textSize)
    local button = Instance.new("TextButton")
    button.Size = size
    button.Position = position
    button.Name = name
    button.BackgroundColor3 = bgColor or currentTheme.DarkBackground
    button.BackgroundTransparency = 0
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = textColor or currentTheme.TextColor
    button.TextSize = textSize or 14
    button.Font = font or Enum.Font.GothamBold
    button.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    return button
end

local function createToggleSwitch(parent, size, position, name, defaultState)
    local switchFrame = Instance.new("Frame")
    switchFrame.Size = size
    switchFrame.Position = position
    switchFrame.Name = name
    switchFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    switchFrame.BorderSizePixel = 0
    switchFrame.Parent = parent
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(0, 10)
    switchCorner.Parent = switchFrame
    local switchKnob = Instance.new("Frame")
    switchKnob.Size = UDim2.new(0, 20, 0, 20)
    switchKnob.Position = defaultState and UDim2.new(0, 20, 0, 0) or UDim2.new(0, 0, 0, 0)
    switchKnob.BackgroundColor3 = defaultState and currentTheme.Accent or currentTheme.AccentRed
    switchKnob.BorderSizePixel = 0
    switchKnob.Parent = switchFrame
    switchKnob.ZIndex = 2
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(0, 10)
    knobCorner.Parent = switchKnob
    return switchFrame, switchKnob
end

local function createSlider(parent, size, position, name, minValue, maxValue, defaultValue, labelText)
    local sliderFrame = createStyledFrame(parent, size, position, name, currentTheme.LightBackground, 0)
    local sliderValue = Instance.new("NumberValue")
    sliderValue.Value = defaultValue
    sliderValue.Parent = sliderFrame
    local sliderFill = createStyledFrame(sliderFrame, UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0), UDim2.new(0, 0, 0, 0), name .. "Fill", currentTheme.Accent, 0.8)
    local sliderText = Instance.new("TextLabel")
    sliderText.Size = UDim2.new(1, 0, 1, 0)
    sliderText.BackgroundTransparency = 1
    sliderText.Text = labelText .. ": " .. defaultValue
    sliderText.TextColor3 = currentTheme.TextColor
    sliderText.TextSize = 12
    sliderText.Font = Enum.Font.GothamBold
    sliderText.Parent = sliderFrame
    return sliderFrame, sliderValue, sliderFill, sliderText
end

local function createDropdown(parent, size, position, name, options, defaultOption)
    local dropdownFrame = createStyledFrame(parent, size, position, name, currentTheme.LightBackground, 0)
    local dropdownButton = createTextButton(dropdownFrame, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), name .. "Button", defaultOption, nil, nil, Enum.Font.GothamBold, 14)
    local dropdownList = createStyledFrame(dropdownFrame, UDim2.new(1, 0, 0, #options * 30), UDim2.new(0, 0, 0, 30), name .. "List", currentTheme.LightBackground, 0)
    dropdownList.Visible = false
    local selectedValue = Instance.new("StringValue")
    selectedValue.Value = defaultOption
    selectedValue.Parent = dropdownFrame
    for i, option in ipairs(options) do
        local optionButton = createTextButton(dropdownList, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, (i-1)*30), option .. "Option", option, nil, nil, Enum.Font.GothamBold, 14)
        optionButton.MouseButton1Click:Connect(function()
            selectedValue.Value = option
            dropdownButton.Text = option
            dropdownList.Visible = false
        end)
    end
    dropdownButton.MouseButton1Click:Connect(function()
        dropdownList.Visible = not dropdownList.Visible
    end)
    return dropdownFrame, selectedValue
end

local function createCheckbox(parent, size, position, name, defaultState, labelText)
    local checkboxFrame = Instance.new("Frame")
    checkboxFrame.Size = size
    checkboxFrame.Position = position
    checkboxFrame.Name = name
    checkboxFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    checkboxFrame.BorderSizePixel = 0
    checkboxFrame.Parent = parent
    local checkboxCorner = Instance.new("UICorner")
    checkboxCorner.CornerRadius = UDim.new(0, 4)
    checkboxCorner.Parent = checkboxFrame
    local checkmark = Instance.new("ImageLabel")
    checkmark.Size = UDim2.new(0, 16, 0, 16)
    checkmark.Position = UDim2.new(0.5, -8, 0.5, -8)
    checkmark.BackgroundTransparency = 1
    checkmark.Image = "rbxassetid://7072706620"
    checkmark.ImageColor3 = Color3.fromRGB(0, 255, 0)
    checkmark.ImageTransparency = defaultState and 0 or 1
    checkmark.Parent = checkboxFrame
    local checkboxLabel = Instance.new("TextLabel")
    checkboxLabel.Size = UDim2.new(0, 80, 0, 20)
    checkboxLabel.Position = UDim2.new(0, -165, 0, 0)
    checkboxLabel.BackgroundTransparency = 1
    checkboxLabel.Text = labelText
    checkboxLabel.TextColor3 = currentTheme.TextColor
    checkboxLabel.TextSize = 14
    checkboxLabel.Font = Enum.Font.GothamBold
    checkboxLabel.TextXAlignment = Enum.TextXAlignment.Right
    checkboxLabel.Parent = checkboxFrame
    return checkboxFrame, checkmark
end

local function createContainer(parent, name, elements, position)
    local container = createStyledFrame(parent, UDim2.new(0, 200, 0, 50), position or UDim2.new(0, 0, 0, 0), name, currentTheme.DarkBackground, 0.2)
    local height = 50
    for i, element in ipairs(elements) do
        element.Parent = container
        if i == 1 then
            element.Position = UDim2.new(0, 10, 0, 10)
        elseif i == 2 then
            element.Position = UDim2.new(0, 100, 0, 15)
        else
            element.Position = UDim2.new(0, 10, 0, height)
            height = height + element.Size.Y.Offset + 10
        end
    end
    container.Size = UDim2.new(0, 200, 0, height)
    return container
end

local activeNotifications = {}

local function createNotification(message, color)
    local notificationContainer = screenGui:FindFirstChild("NotificationContainer") or createStyledFrame(screenGui, UDim2.new(0, 200, 0, 0), UDim2.new(1, -210, 1, -60), "NotificationContainer", nil, 1)
    local notificationFrame = createStyledFrame(notificationContainer, UDim2.new(0, 200, 0, 50), UDim2.new(1, 0, 0, 0), "Notification", currentTheme.LightBackground, 0.3)
    local notifGlow = Instance.new("UIStroke")
    notifGlow.Thickness = 1
    notifGlow.Color = color or currentTheme.Accent
    notifGlow.Transparency = 0.7
    notifGlow.Parent = notificationFrame
    local notificationText = Instance.new("TextLabel")
    notificationText.Size = UDim2.new(1, 0, 1, 0)
    notificationText.BackgroundTransparency = 1
    notificationText.Text = message
    notificationText.TextColor3 = color or currentTheme.TextColor
    notificationText.TextSize = 16
    notificationText.Font = Enum.Font.GothamBold
    notificationText.Parent = notificationFrame
    local offsetY = #activeNotifications * 60
    notificationFrame.Position = UDim2.new(1, 0, 0, -offsetY)
    table.insert(activeNotifications, notificationFrame)
    TweenService:Create(notificationFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0.2, Position = UDim2.new(0, 0, 0, -offsetY)}):Play()
    task.delay(2, function()
        TweenService:Create(notificationFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1, Position = UDim2.new(1, 0, 0, -offsetY)}):Play()
        notificationFrame.Destroying:Connect(function()
            for i, notif in ipairs(activeNotifications) do
                if notif == notificationFrame then
                    table.remove(activeNotifications, i)
                    break
                end
            end
        end)
        notificationFrame:Destroy()
    end)
end

-- Main GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DrainCoreGui"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

if playerGui:FindFirstChild("DrainCoreGui") then
    playerGui.DrainCoreGui:Destroy()
end

local mainFrame = createStyledFrame(screenGui, UDim2.new(0, 700, 0, 500), UDim2.new(0.5, -350, 0.5, -250), "MainFrame", currentTheme.Background, 0.3)
local mainGlow = Instance.new("UIStroke")
mainGlow.Thickness = 2
mainGlow.Color = currentTheme.Border
mainGlow.Transparency = 0.8
mainGlow.Parent = mainFrame

local dragBar = Instance.new("Frame")
dragBar.Size = UDim2.new(1, 0, 0, 30)
dragBar.Position = UDim2.new(0, 0, 0, 0)
dragBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
dragBar.BackgroundTransparency = 1
dragBar.BorderSizePixel = 0
dragBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 200, 1, 0)
title.Position = UDim2.new(0, 6, 0, -205)
title.BackgroundTransparency = 1
title.Text = "DRAINCORE"
title.TextColor3 = currentTheme.TextColor
title.TextSize = 30
title.Font = Enum.Font.GothamBold
title.Parent = dragBar

local searchBar = Instance.new("TextBox")
searchBar.Size = UDim2.new(0, 400, 0, 20)
searchBar.Position = UDim2.new(1, -475, 0, 5)
searchBar.BackgroundColor3 = currentTheme.SearchBG
searchBar.BackgroundTransparency = 0.3
searchBar.TextColor3 = currentTheme.TextColor
searchBar.TextSize = 14
searchBar.Font = Enum.Font.GothamBold
searchBar.PlaceholderText = "Search..."
searchBar.Text = ""
searchBar.BorderSizePixel = 0
searchBar.Parent = dragBar

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 8)
searchCorner.Parent = searchBar

local searchGlow = Instance.new("UIStroke")
searchGlow.Thickness = 1
searchGlow.Color = currentTheme.Border
searchGlow.Transparency = 0.9
searchGlow.Parent = searchBar

local closeButton = createTextButton(dragBar, UDim2.new(0, 25, 0, 25), UDim2.new(1, -30, 0, 3), "CloseButton", "X", nil, currentTheme.TextColor, Enum.Font.GothamBold, 18)
closeButton.BackgroundTransparency = 1

local funcFrame = createStyledFrame(mainFrame, UDim2.new(0, 215, 0, 410), UDim2.new(0, 0, 0, 90), "FuncFrame", nil, 1)
local baseFrame = createStyledFrame(mainFrame, UDim2.new(0, 485, 0, 470), UDim2.new(0, 215, 0, 30), "BaseFrame", nil, 1)
local tabContents = createStyledFrame(baseFrame, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "TabContents", nil, 1)

-- Tab System
local tabNames = {"General", "Rage", "Visuals", "Movement"}
local tabs = {}
local tabFrames = {}
local tabElements = {}
local activeTab = nil

local function createTab(name, index, parent)
    local tab = createTextButton(parent, UDim2.new(1, -20, 0, 40), UDim2.new(0, 10, 0, 15 + (index - 1) * 50), name .. "Tab", name, currentTheme.DarkBackground, currentTheme.TextColor, Enum.Font.GothamBold, 14)
    tab.BackgroundTransparency = 0.4
    local highlightBar = Instance.new("Frame")
    highlightBar.Name = "HighlightBar"
    highlightBar.Size = UDim2.new(0, 4, 1, 0)
    highlightBar.Position = UDim2.new(0, -6, 0, 0)
    highlightBar.BackgroundColor3 = currentTheme.HighlightBar
    highlightBar.BackgroundTransparency = 1
    highlightBar.BorderSizePixel = 0
    highlightBar.ZIndex = 2
    highlightBar.Parent = tab

    local contentFrame = createStyledFrame(tabContents, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), name .. "Content", nil, 1)
    contentFrame.Visible = false
    contentFrame:FindFirstChild("ImageLabel"):Destroy()

    local function activateTab()
        if activeTab == tab then return end
        if activeTab then
            TweenService:Create(activeTab, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.4,
                TextColor3 = currentTheme.TextColor
            }):Play()
            local prevHighlight = activeTab:FindFirstChild("HighlightBar")
            if prevHighlight then
                TweenService:Create(prevHighlight, TweenInfo.new(0.2), {
                    BackgroundTransparency = 1
                }):Play()
            end
        end
        TweenService:Create(tab, TweenInfo.new(0.2), {
            BackgroundTransparency = 0,
            TextColor3 = currentTheme.TextColor
        }):Play()
        TweenService:Create(highlightBar, TweenInfo.new(0.2), {
            BackgroundTransparency = 0
        }):Play()
        activeTab = tab
        for _, frame in pairs(tabFrames) do
            frame.Visible = false
        end
        contentFrame.Visible = true
    end

    tab.MouseEnter:Connect(function()
        if activeTab ~= tab then
            TweenService:Create(tab, TweenInfo.new(0.2), {
                BackgroundTransparency = 0,
                TextColor3 = currentTheme.TextColor
            }):Play()
        end
    end)
    tab.MouseLeave:Connect(function()
        if activeTab ~= tab then
            TweenService:Create(tab, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.4,
                TextColor3 = currentTheme.TextColor
            }):Play()
        end
    end)
    tab.MouseButton1Click:Connect(activateTab)
    if index == 1 then
        activateTab()
    end
    tabs[name] = tab
    tabFrames[name] = contentFrame
    tabElements[name] = {}
    return contentFrame
end

for i, name in ipairs(tabNames) do
    createTab(name, i, funcFrame)
end

-- Search Logic
searchBar:GetPropertyChangedSignal("Text"):Connect(function()
    local searchQuery = searchBar.Text
    if activeTab and tabFrames[activeTab.Text] then
        local contentFrame = tabFrames[activeTab.Text]
        for _, child in ipairs(contentFrame:GetChildren()) do
            if child:IsA("Frame") then
                local label = child:FindFirstChildWhichIsA("TextLabel")
                local labelText = label and label.Text or child.Name
                child.Visible = searchQuery == "" or string.find(string.lower(labelText), string.lower(searchQuery), 1, true)
            end
        end
    end
end)

-- Dragging Logic
local dragging = false
local dragStart, startPos

dragBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = Vector2.new(input.Position.X, input.Position.Y)
        startPos = Vector2.new(mainFrame.Position.X.Offset, mainFrame.Position.Y.Offset)
    end
end)

dragBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
        mainFrame.Position = UDim2.new(0, startPos.X + delta.X, 0, startPos.Y + delta.Y)
    end
end)

-- Close Button
closeButton.MouseEnter:Connect(function()
    closeButton.TextColor3 = currentTheme.AccentRed
end)
closeButton.MouseLeave:Connect(function()
    closeButton.TextColor3 = currentTheme.TextColor
end)
closeButton.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)

-- Global Table
local keybinds = {}

-- CreateWindow Function
function DrainCore:CreateWindow(settings)
    mainFrame.Visible = true
    title.Text = settings.Name
    local window = {}
    local containers = {}

    function window:CreateTab(name)
        local contentFrame = tabFrames[name]
        local tab = tabs[name]
        local tabObj = {}

        function tabObj:CreateSection(titleText)
            local section = Instance.new("TextLabel")
            section.Size = UDim2.new(1, 0, 0, 30)
            section.BackgroundTransparency = 1
            section.Text = titleText
            section.TextColor3 = currentTheme.TextColor
            section.TextSize = 16
            section.Font = Enum.Font.GothamBold
            section.TextXAlignment = Enum.TextXAlignment.Left
            section.Position = UDim2.new(0, 10, 0, #contentFrame:GetChildren() * 10)
            section.Parent = contentFrame
            return section
        end

        function tabObj:CreateToggle(toggleSettings)
            local toggleFrame, toggleKnob = createToggleSwitch(contentFrame, UDim2.new(0, 40, 0, 20), UDim2.new(0, 100, 0, 15), toggleSettings.Name, toggleSettings.CurrentValue)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0, 80, 0, 30)
            label.Position = UDim2.new(0, 10, 0, 10)
            label.BackgroundTransparency = 1
            label.Text = toggleSettings.Name
            label.TextColor3 = currentTheme.TextColor
            label.TextSize = 14
            label.Font = Enum.Font.GothamBold
            label.Parent = contentFrame
            toggleFrame.Position = UDim2.new(0, 100, 0, 15)
            toggleKnob.MouseButton1Click:Connect(function()
                local isEnabled = toggleKnob.Position.X.Offset == 0
                local newValue = not isEnabled
                TweenService:Create(toggleKnob, TweenInfo.new(0.2), {
                    Position = newValue and UDim2.new(0, 20, 0, 0) or UDim2.new(0, 0, 0, 0),
                    BackgroundColor3 = newValue and currentTheme.Accent or currentTheme.AccentRed
                }):Play()
                if toggleSettings.Callback then
                    toggleSettings.Callback(newValue)
                end
            end)
            DrainCore.Flags[toggleSettings.Flag] = {
                Type = "toggle",
                CurrentValue = toggleSettings.CurrentValue,
                Callback = toggleSettings.Callback,
                Set = function(value)
                    toggleSettings.CurrentValue = value
                    TweenService:Create(toggleKnob, TweenInfo.new(0.2), {
                        Position = value and UDim2.new(0, 20, 0, 0) or UDim2.new(0, 0, 0, 0),
                        BackgroundColor3 = value and currentTheme.Accent or currentTheme.AccentRed
                    }):Play()
                end
            }
            return DrainCore.Flags[toggleSettings.Flag]
        end

        function tabObj:CreateSlider(sliderSettings)
            local sliderFrame, sliderValue, sliderFill, sliderText = createSlider(contentFrame, UDim2.new(0, 180, 0, 30), UDim2.new(0, 10, 0, 50), sliderSettings.Name, sliderSettings.Min, sliderSettings.Max, sliderSettings.Default, sliderSettings.Label)
            sliderFrame.Parent = contentFrame
            sliderText.Parent = sliderFrame
            sliderFill.Parent = sliderFrame
            local dragging = false
            sliderFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    local offset = input.Position.X - sliderFrame.AbsolutePosition.X
                    local percent = math.clamp(offset / sliderFrame.AbsoluteSize.X, 0, 1)
                    local value = math.floor(percent * (sliderSettings.Max - sliderSettings.Min) + sliderSettings.Min)
                    sliderValue.Value = value
                    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    sliderText.Text = sliderSettings.Label .. ": " .. value
                    if sliderSettings.Callback then
                        sliderSettings.Callback(value)
                    end
                end
            end)
            sliderFrame.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                    local offset = input.Position.X - sliderFrame.AbsolutePosition.X
                    local percent = math.clamp(offset / sliderFrame.AbsoluteSize.X, 0, 1)
                    local value = math.floor(percent * (sliderSettings.Max - sliderSettings.Min) + sliderSettings.Min)
                    sliderValue.Value = value
                    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    sliderText.Text = sliderSettings.Label .. ": " .. value
                    if sliderSettings.Callback then
                        sliderSettings.Callback(value)
                    end
                end
            end)
            sliderFrame.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            DrainCore.Flags[sliderSettings.Flag] = {
                Type = "slider",
                Value = sliderSettings.Default,
                Min = sliderSettings.Min,
                Max = sliderSettings.Max,
                Callback = sliderSettings.Callback,
                Set = function(val)
                    local percent = (val - sliderSettings.Min) / (sliderSettings.Max - sliderSettings.Min)
                    sliderValue.Value = val
                    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    sliderText.Text = sliderSettings.Label .. ": " .. val
                end
            }
            return DrainCore.Flags[sliderSettings.Flag]
        end

        function tabObj:CreateDropdown(dropdownSettings)
            local dropdownFrame, selectedValue = createDropdown(contentFrame, UDim2.new(0, 180, 0, 30), UDim2.new(0, 10, 0, 90), dropdownSettings.Name, dropdownSettings.Options, dropdownSettings.Default)
            dropdownFrame.Parent = contentFrame
            DrainCore.Flags[dropdownSettings.Flag] = {
                Type = "dropdown",
                Options = dropdownSettings.Options,
                CurrentValue = dropdownSettings.Default,
                Callback = dropdownSettings.Callback,
                Set = function(value)
                    selectedValue.Value = value
                    dropdownFrame:FindFirstChild("Button").Text = value
                    dropdownSettings.Callback(value)
                end
            }
            return DrainCore.Flags[dropdownSettings.Flag]
        end

        function tabObj:CreateKeybind(keybindSettings)
            local keybindButton = createTextButton(contentFrame, UDim2.new(0, 80, 0, 30), UDim2.new(0, 10, 0, 170), keybindSettings.Name, "Key: " .. keybindSettings.Default.Name, currentTheme.LightBackground, currentTheme.TextColor, Enum.Font.GothamBold, 14)
            keybindButton.Parent = contentFrame
            keybinds[keybindSettings.Name] = keybindSettings.Default
            local keybindWindow = createStyledFrame(screenGui, UDim2.new(0, 200, 0, 100), UDim2.new(0.5, -100, 0.5, -50), "KeybindWindow", currentTheme.DarkBackground, 0.3)
            keybindWindow.Visible = false
            keybindWindow.ZIndex = 10
            local prompt = Instance.new("TextLabel")
            prompt.Size = UDim2.new(1, 0, 0, 50)
            prompt.BackgroundTransparency = 1
            prompt.Text = "Press a key..."
            prompt.TextColor3 = currentTheme.TextColor
            prompt.TextSize = 16
            prompt.Font = Enum.Font.GothamBold
            prompt.Parent = keybindWindow
            local cancelButton = createTextButton(keybindWindow, UDim2.new(0, 80, 0, 30), UDim2.new(0.5, -40, 0, 60), "CancelButton", "Cancel", currentTheme.LightBackground, currentTheme.TextColor, Enum.Font.GothamBold, 14)
            cancelButton.MouseButton1Click:Connect(function()
                keybindWindow.Visible = false
            end)
            keybindButton.MouseButton1Click:Connect(function()
                keybindWindow.Visible = true
                local connection
                connection = UserInputService.InputBegan:Connect(function(input, gp)
                    if gp then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        keybinds[keybindSettings.Name] = input.KeyCode
                        keybindButton.Text = "Key: " .. input.KeyCode.Name
                        keybindWindow.Visible = false
                        createNotification("Keybind set to " .. input.KeyCode.Name, currentTheme.Accent)
                        connection:Disconnect()
                    end
                end)
            end)
            return keybindButton
        end

        function tabObj:CreateNotification(data)
            createNotification(data.Title, data.Color or currentTheme.Accent)
        end

        return tabObj
    end

    return window
end

-- Visibility Control
function DrainCore:SetVisibility(visible)
    screenGui.Enabled = visible
    mainFrame.Visible = visible
end

-- Hotkey Toggle
function DrainCore:BindToToggle(key)
    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == key then
            screenGui.Enabled = not screenGui.Enabled
            mainFrame.Visible = screenGui.Enabled
        end
    end)
end

return DrainCore
