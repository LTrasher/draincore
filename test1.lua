local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Создаем библиотеку интерфейса
local MyUILibrary = {}

-- Цветовая тема
local Theme = {
    Background = Color3.fromRGB(25, 25, 25),
    TextColor = Color3.fromRGB(240, 240, 240),
    ElementBackground = Color3.fromRGB(35, 35, 35),
    ElementBackgroundHover = Color3.fromRGB(40, 40, 40),
    ToggleEnabled = Color3.fromRGB(0, 146, 214),
    ToggleDisabled = Color3.fromRGB(100, 100, 100),
}

-- Создание окна
function MyUILibrary:CreateWindow(settings)
    local Window = {}
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = CoreGui
    ScreenGui.Name = settings.Name or "MyUI"
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 300)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    local Tabs = Instance.new("Frame")
    Tabs.Size = UDim2.new(1, 0, 1, 0)
    Tabs.BackgroundTransparency = 1
    Tabs.Parent = MainFrame

    local UIPageLayout = Instance.new("UIPageLayout")
    UIPageLayout.Parent = Tabs
    UIPageLayout.EasingStyle = Enum.EasingStyle.Quad
    UIPageLayout.TweenTime = 0.3

    -- Функция для создания вкладки
    function Window:CreateTab(tabName)
        local Tab = {}
        local TabPage = Instance.new("Frame")
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Parent = Tabs
        TabPage.Name = tabName

        local UIListLayout = Instance.new("UIListLayout")
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Padding = UDim.new(0, 5)
        UIListLayout.Parent = TabPage

        -- Создание кнопки
        function Tab:CreateButton(buttonSettings)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, -10, 0, 40)
            Button.BackgroundColor3 = Theme.ElementBackground
            Button.TextColor3 = Theme.TextColor
            Button.Text = buttonSettings.Name
            Button.Parent = TabPage

            local UICorner = Instance.new("UICorner")
            UICorner.CornerRadius = UDim.new(0, 4)
            UICorner.Parent = Button

            Button.MouseEnter:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundColor3 = Theme.ElementBackgroundHover}):Play()
            end)
            Button.MouseLeave:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundColor3 = Theme.ElementBackground}):Play()
            end)
            Button.MouseButton1Click:Connect(function()
                local success, err = pcall(buttonSettings.Callback)
                if not success then
                    warn("Button Callback Error: " .. tostring(err))
                end
            end)
        end

        -- Создание переключателя
        function Tab:CreateToggle(toggleSettings)
            local Toggle = {}
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, -10, 0, 40)
            ToggleFrame.BackgroundColor3 = Theme.ElementBackground
            ToggleFrame.Parent = TabPage

            local UICorner = Instance.new("UICorner")
            UICorner.CornerRadius = UDim.new(0, 4)
            UICorner.Parent = ToggleFrame

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(0.8, 0, 1, 0)
            Title.BackgroundTransparency = 1
            Title.TextColor3 = Theme.TextColor
            Title.Text = toggleSettings.Name
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Parent = ToggleFrame

            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 40, 0, 20)
            Switch.Position = UDim2.new(1, -50, 0.5, -10)
            Switch.BackgroundColor3 = Theme.ToggleDisabled
            Switch.Parent = ToggleFrame

            local Indicator = Instance.new("Frame")
            Indicator.Size = UDim2.new(0, 16, 0, 16)
            Indicator.Position = toggleSettings.CurrentValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            Indicator.BackgroundColor3 = toggleSettings.CurrentValue and Theme.ToggleEnabled or Theme.ToggleDisabled
            Indicator.Parent = Switch

            local UICornerSwitch = Instance.new("UICorner")
            UICornerSwitch.CornerRadius = UDim.new(0, 10)
            UICornerSwitch.Parent = Switch

            local UICornerIndicator = Instance.new("UICorner")
            UICornerIndicator.CornerRadius = UDim.new(0, 8)
            UICornerIndicator.Parent = Indicator

            ToggleFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    toggleSettings.CurrentValue = not toggleSettings.CurrentValue
                    local newPos = toggleSettings.CurrentValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                    local newColor = toggleSettings.CurrentValue and Theme.ToggleEnabled or Theme.ToggleDisabled
                    TweenService:Create(Indicator, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = newPos, BackgroundColor3 = newColor}):Play()
                    local success, err = pcall(toggleSettings.Callback, toggleSettings.CurrentValue)
                    if not success then
                        warn("Toggle Callback Error: " .. tostring(err))
                    end
                end
            end)

            function Toggle:Set(value)
                toggleSettings.CurrentValue = value
                local newPos = value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                local newColor = value and Theme.ToggleEnabled or Theme.ToggleDisabled
                TweenService:Create(Indicator, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = newPos, BackgroundColor3 = newColor}):Play()
                local success, err = pcall(toggleSettings.Callback, value)
                if not success then
                    warn("Toggle Callback Error: " .. tostring(err))
                end
            end

            return Toggle
        end

        return Tab
    end

    return Window
end
