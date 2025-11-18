-- Hydra Hub UI Library
-- Lightweight UI library for Roblox exploits

local Library = {}

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Create ScreenGui
local function CreateScreenGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HydraHubUI_" .. tostring(math.random(1000, 9999))
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Try to parent to CoreGui, fallback to PlayerGui
    local success = pcall(function()
        screenGui.Parent = CoreGui
    end)
    
    if not success then
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        if LocalPlayer then
            screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
    end
    
    return screenGui
end

-- Create Window
function Library:CreateWindow(config)
    config = config or {}
    local title = config.Title or "Hydra Hub"
    local draggable = config.Draggable ~= false
    
    local screenGui = CreateScreenGui()
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 550, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    -- Title Text
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 2.5)
    closeButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Tab Container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, 120, 1, -45)
    tabContainer.Position = UDim2.new(0, 5, 0, 40)
    tabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabContainer
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.Parent = tabContainer
    
    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingTop = UDim.new(0, 5)
    tabPadding.PaddingLeft = UDim.new(0, 5)
    tabPadding.PaddingRight = UDim.new(0, 5)
    tabPadding.Parent = tabContainer
    
    -- Content Container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -135, 1, -45)
    contentContainer.Position = UDim2.new(0, 130, 0, 40)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = mainFrame
    
    -- Dragging
    if draggable then
        local dragging = false
        local dragInput, mousePos, framePos
        
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                mousePos = input.Position
                framePos = mainFrame.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        titleBar.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - mousePos
                mainFrame.Position = UDim2.new(
                    framePos.X.Scale,
                    framePos.X.Offset + delta.X,
                    framePos.Y.Scale,
                    framePos.Y.Offset + delta.Y
                )
            end
        end)
    end
    
    -- Window object
    local Window = {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        TabContainer = tabContainer,
        ContentContainer = contentContainer,
        Tabs = {},
        CurrentTab = nil
    }
    
    -- Create Tab
    function Window:CreateTab(name)
        local tabButton = Instance.new("TextButton")
        tabButton.Name = name
        tabButton.Size = UDim2.new(1, 0, 0, 35)
        tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        tabButton.Text = name
        tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabButton.TextSize = 14
        tabButton.Font = Enum.Font.Gotham
        tabButton.Parent = self.TabContainer
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 6)
        tabCorner.Parent = tabButton
        
        -- Tab Content
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = name .. "Content"
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
        tabContent.Visible = false
        tabContent.Parent = self.ContentContainer
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 8)
        contentLayout.Parent = tabContent
        
        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingTop = UDim.new(0, 5)
        contentPadding.PaddingLeft = UDim.new(0, 5)
        contentPadding.PaddingRight = UDim.new(0, 5)
        contentPadding.Parent = tabContent
        
        -- Auto-resize content
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
        end)
        
        -- Tab object
        local Tab = {
            Button = tabButton,
            Content = tabContent,
            Sections = {}
        }
        
        -- Tab click
        tabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(self.Tabs) do
                tab.Content.Visible = false
                tab.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                tab.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            
            tabContent.Visible = true
            tabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            self.CurrentTab = Tab
        end)
        
        -- Auto-select first tab
        if #self.Tabs == 0 then
            tabContent.Visible = true
            tabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            self.CurrentTab = Tab
        end
        
        table.insert(self.Tabs, Tab)
        
        -- Create Section
        function Tab:CreateSection(name)
            local sectionFrame = Instance.new("Frame")
            sectionFrame.Name = name
            sectionFrame.Size = UDim2.new(1, 0, 0, 30)
            sectionFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            sectionFrame.BorderSizePixel = 0
            sectionFrame.Parent = tabContent
            
            local sectionCorner = Instance.new("UICorner")
            sectionCorner.CornerRadius = UDim.new(0, 6)
            sectionCorner.Parent = sectionFrame
            
            local sectionLabel = Instance.new("TextLabel")
            sectionLabel.Size = UDim2.new(1, -10, 0, 25)
            sectionLabel.Position = UDim2.new(0, 5, 0, 2.5)
            sectionLabel.BackgroundTransparency = 1
            sectionLabel.Text = name
            sectionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            sectionLabel.TextSize = 15
            sectionLabel.Font = Enum.Font.GothamBold
            sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            sectionLabel.Parent = sectionFrame
            
            local sectionContent = Instance.new("Frame")
            sectionContent.Name = "Content"
            sectionContent.Size = UDim2.new(1, 0, 0, 0)
            sectionContent.Position = UDim2.new(0, 0, 0, 30)
            sectionContent.BackgroundTransparency = 1
            sectionContent.Parent = sectionFrame
            
            local sectionLayout = Instance.new("UIListLayout")
            sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sectionLayout.Padding = UDim.new(0, 5)
            sectionLayout.Parent = sectionContent
            
            local sectionPadding = Instance.new("UIPadding")
            sectionPadding.PaddingTop = UDim.new(0, 5)
            sectionPadding.PaddingLeft = UDim.new(0, 5)
            sectionPadding.PaddingRight = UDim.new(0, 5)
            sectionPadding.PaddingBottom = UDim.new(0, 5)
            sectionPadding.Parent = sectionContent
            
            -- Auto-resize section
            sectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sectionContent.Size = UDim2.new(1, 0, 0, sectionLayout.AbsoluteContentSize.Y + 10)
                sectionFrame.Size = UDim2.new(1, 0, 0, sectionLayout.AbsoluteContentSize.Y + 40)
            end)
            
            local Section = {
                Frame = sectionFrame,
                Content = sectionContent
            }
            
            table.insert(Tab.Sections, Section)

            -- Create Toggle
            function Section:CreateToggle(config)
                config = config or {}
                local name = config.Name or "Toggle"
                local currentValue = config.CurrentValue or false
                local callback = config.Callback or function() end
                
                local toggleFrame = Instance.new("Frame")
                toggleFrame.Name = name
                toggleFrame.Size = UDim2.new(1, 0, 0, 30)
                toggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                toggleFrame.BorderSizePixel = 0
                toggleFrame.Parent = sectionContent
                
                local toggleCorner = Instance.new("UICorner")
                toggleCorner.CornerRadius = UDim.new(0, 6)
                toggleCorner.Parent = toggleFrame
                
                local toggleLabel = Instance.new("TextLabel")
                toggleLabel.Size = UDim2.new(1, -50, 1, 0)
                toggleLabel.Position = UDim2.new(0, 10, 0, 0)
                toggleLabel.BackgroundTransparency = 1
                toggleLabel.Text = name
                toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                toggleLabel.TextSize = 13
                toggleLabel.Font = Enum.Font.Gotham
                toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                toggleLabel.Parent = toggleFrame
                
                local toggleButton = Instance.new("TextButton")
                toggleButton.Size = UDim2.new(0, 40, 0, 20)
                toggleButton.Position = UDim2.new(1, -45, 0.5, -10)
                toggleButton.BackgroundColor3 = currentValue and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
                toggleButton.Text = ""
                toggleButton.Parent = toggleFrame
                
                local toggleButtonCorner = Instance.new("UICorner")
                toggleButtonCorner.CornerRadius = UDim.new(1, 0)
                toggleButtonCorner.Parent = toggleButton
                
                local toggleCircle = Instance.new("Frame")
                toggleCircle.Size = UDim2.new(0, 16, 0, 16)
                toggleCircle.Position = currentValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                toggleCircle.BorderSizePixel = 0
                toggleCircle.Parent = toggleButton
                
                local circleCorner = Instance.new("UICorner")
                circleCorner.CornerRadius = UDim.new(1, 0)
                circleCorner.Parent = toggleCircle
                
                local toggled = currentValue
                
                toggleButton.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    
                    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    local colorTween = TweenService:Create(toggleButton, tweenInfo, {
                        BackgroundColor3 = toggled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
                    })
                    local positionTween = TweenService:Create(toggleCircle, tweenInfo, {
                        Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                    })
                    
                    colorTween:Play()
                    positionTween:Play()
                    
                    callback(toggled)
                end)
                
                return toggleFrame
            end
            
            -- Create Slider
            function Section:CreateSlider(config)
                config = config or {}
                local name = config.Name or "Slider"
                local range = config.Range or {0, 100}
                local increment = config.Increment or 1
                local currentValue = config.CurrentValue or range[1]
                local callback = config.Callback or function() end
                
                local sliderFrame = Instance.new("Frame")
                sliderFrame.Name = name
                sliderFrame.Size = UDim2.new(1, 0, 0, 50)
                sliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                sliderFrame.BorderSizePixel = 0
                sliderFrame.Parent = sectionContent
                
                local sliderCorner = Instance.new("UICorner")
                sliderCorner.CornerRadius = UDim.new(0, 6)
                sliderCorner.Parent = sliderFrame
                
                local sliderLabel = Instance.new("TextLabel")
                sliderLabel.Size = UDim2.new(1, -60, 0, 20)
                sliderLabel.Position = UDim2.new(0, 10, 0, 5)
                sliderLabel.BackgroundTransparency = 1
                sliderLabel.Text = name
                sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                sliderLabel.TextSize = 13
                sliderLabel.Font = Enum.Font.Gotham
                sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                sliderLabel.Parent = sliderFrame
                
                local valueLabel = Instance.new("TextLabel")
                valueLabel.Size = UDim2.new(0, 50, 0, 20)
                valueLabel.Position = UDim2.new(1, -55, 0, 5)
                valueLabel.BackgroundTransparency = 1
                valueLabel.Text = tostring(currentValue)
                valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                valueLabel.TextSize = 13
                valueLabel.Font = Enum.Font.Gotham
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right
                valueLabel.Parent = sliderFrame
                
                local sliderBar = Instance.new("Frame")
                sliderBar.Size = UDim2.new(1, -20, 0, 6)
                sliderBar.Position = UDim2.new(0, 10, 1, -15)
                sliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                sliderBar.BorderSizePixel = 0
                sliderBar.Parent = sliderFrame
                
                local sliderBarCorner = Instance.new("UICorner")
                sliderBarCorner.CornerRadius = UDim.new(1, 0)
                sliderBarCorner.Parent = sliderBar
                
                local sliderFill = Instance.new("Frame")
                sliderFill.Size = UDim2.new((currentValue - range[1]) / (range[2] - range[1]), 0, 1, 0)
                sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
                sliderFill.BorderSizePixel = 0
                sliderFill.Parent = sliderBar
                
                local sliderFillCorner = Instance.new("UICorner")
                sliderFillCorner.CornerRadius = UDim.new(1, 0)
                sliderFillCorner.Parent = sliderFill
                
                local sliderButton = Instance.new("TextButton")
                sliderButton.Size = UDim2.new(1, 0, 1, 0)
                sliderButton.BackgroundTransparency = 1
                sliderButton.Text = ""
                sliderButton.Parent = sliderBar
                
                local dragging = false
                
                sliderButton.MouseButton1Down:Connect(function()
                    dragging = true
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                sliderButton.MouseMoved:Connect(function(x, y)
                    if dragging then
                        local pos = math.clamp((x - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
                        local value = math.floor((range[1] + (range[2] - range[1]) * pos) / increment + 0.5) * increment
                        value = math.clamp(value, range[1], range[2])
                        
                        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
                        valueLabel.Text = tostring(value)
                        callback(value)
                    end
                end)
                
                return sliderFrame
            end
            
            -- Create Dropdown
            function Section:CreateDropdown(config)
                config = config or {}
                local name = config.Name or "Dropdown"
                local options = config.Options or {"Option 1", "Option 2"}
                local currentOption = config.CurrentOption or options[1]
                local callback = config.Callback or function() end
                
                local dropdownFrame = Instance.new("Frame")
                dropdownFrame.Name = name
                dropdownFrame.Size = UDim2.new(1, 0, 0, 30)
                dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                dropdownFrame.BorderSizePixel = 0
                dropdownFrame.ClipsDescendants = true
                dropdownFrame.Parent = sectionContent
                
                local dropdownCorner = Instance.new("UICorner")
                dropdownCorner.CornerRadius = UDim.new(0, 6)
                dropdownCorner.Parent = dropdownFrame
                
                local dropdownLabel = Instance.new("TextLabel")
                dropdownLabel.Size = UDim2.new(1, -30, 0, 30)
                dropdownLabel.Position = UDim2.new(0, 10, 0, 0)
                dropdownLabel.BackgroundTransparency = 1
                dropdownLabel.Text = name .. ": " .. currentOption
                dropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                dropdownLabel.TextSize = 13
                dropdownLabel.Font = Enum.Font.Gotham
                dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                dropdownLabel.Parent = dropdownFrame
                
                local dropdownButton = Instance.new("TextButton")
                dropdownButton.Size = UDim2.new(1, 0, 0, 30)
                dropdownButton.BackgroundTransparency = 1
                dropdownButton.Text = ""
                dropdownButton.Parent = dropdownFrame
                
                local arrow = Instance.new("TextLabel")
                arrow.Size = UDim2.new(0, 20, 0, 30)
                arrow.Position = UDim2.new(1, -25, 0, 0)
                arrow.BackgroundTransparency = 1
                arrow.Text = "▼"
                arrow.TextColor3 = Color3.fromRGB(200, 200, 200)
                arrow.TextSize = 12
                arrow.Font = Enum.Font.Gotham
                arrow.Parent = dropdownFrame
                
                local optionsFrame = Instance.new("Frame")
                optionsFrame.Size = UDim2.new(1, 0, 0, 0)
                optionsFrame.Position = UDim2.new(0, 0, 0, 30)
                optionsFrame.BackgroundTransparency = 1
                optionsFrame.Parent = dropdownFrame
                
                local optionsLayout = Instance.new("UIListLayout")
                optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                optionsLayout.Parent = optionsFrame
                
                local expanded = false
                
                for _, option in ipairs(options) do
                    local optionButton = Instance.new("TextButton")
                    optionButton.Size = UDim2.new(1, 0, 0, 25)
                    optionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    optionButton.BorderSizePixel = 0
                    optionButton.Text = option
                    optionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                    optionButton.TextSize = 12
                    optionButton.Font = Enum.Font.Gotham
                    optionButton.Parent = optionsFrame
                    
                    optionButton.MouseButton1Click:Connect(function()
                        currentOption = option
                        dropdownLabel.Text = name .. ": " .. option
                        callback(option)
                        
                        expanded = false
                        arrow.Text = "▼"
                        dropdownFrame.Size = UDim2.new(1, 0, 0, 30)
                    end)
                end
                
                dropdownButton.MouseButton1Click:Connect(function()
                    expanded = not expanded
                    
                    if expanded then
                        arrow.Text = "▲"
                        dropdownFrame.Size = UDim2.new(1, 0, 0, 30 + (#options * 25))
                    else
                        arrow.Text = "▼"
                        dropdownFrame.Size = UDim2.new(1, 0, 0, 30)
                    end
                end)
                
                return dropdownFrame
            end
            
            -- Create Button
            function Section:CreateButton(config)
                config = config or {}
                local name = config.Name or "Button"
                local callback = config.Callback or function() end
                
                local buttonFrame = Instance.new("TextButton")
                buttonFrame.Name = name
                buttonFrame.Size = UDim2.new(1, 0, 0, 30)
                buttonFrame.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
                buttonFrame.BorderSizePixel = 0
                buttonFrame.Text = name
                buttonFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
                buttonFrame.TextSize = 13
                buttonFrame.Font = Enum.Font.GothamBold
                buttonFrame.Parent = sectionContent
                
                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 6)
                buttonCorner.Parent = buttonFrame
                
                buttonFrame.MouseButton1Click:Connect(function()
                    callback()
                end)
                
                return buttonFrame
            end
            
            -- Create Input
            function Section:CreateInput(config)
                config = config or {}
                local name = config.Name or "Input"
                local placeholderText = config.PlaceholderText or "Enter text..."
                local callback = config.Callback or function() end
                
                local inputFrame = Instance.new("Frame")
                inputFrame.Name = name
                inputFrame.Size = UDim2.new(1, 0, 0, 55)
                inputFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                inputFrame.BorderSizePixel = 0
                inputFrame.Parent = sectionContent
                
                local inputCorner = Instance.new("UICorner")
                inputCorner.CornerRadius = UDim.new(0, 6)
                inputCorner.Parent = inputFrame
                
                local inputLabel = Instance.new("TextLabel")
                inputLabel.Size = UDim2.new(1, -20, 0, 20)
                inputLabel.Position = UDim2.new(0, 10, 0, 5)
                inputLabel.BackgroundTransparency = 1
                inputLabel.Text = name
                inputLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                inputLabel.TextSize = 13
                inputLabel.Font = Enum.Font.Gotham
                inputLabel.TextXAlignment = Enum.TextXAlignment.Left
                inputLabel.Parent = inputFrame
                
                local textBox = Instance.new("TextBox")
                textBox.Size = UDim2.new(1, -20, 0, 25)
                textBox.Position = UDim2.new(0, 10, 0, 25)
                textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                textBox.BorderSizePixel = 0
                textBox.PlaceholderText = placeholderText
                textBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
                textBox.Text = ""
                textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                textBox.TextSize = 12
                textBox.Font = Enum.Font.Gotham
                textBox.ClearTextOnFocus = false
                textBox.Parent = inputFrame
                
                local textBoxCorner = Instance.new("UICorner")
                textBoxCorner.CornerRadius = UDim.new(0, 4)
                textBoxCorner.Parent = textBox
                
                textBox.FocusLost:Connect(function(enterPressed)
                    if enterPressed then
                        callback(textBox.Text)
                    end
                end)
                
                return inputFrame
            end
            
            return Section
        end
        
        return Tab
    end
    
    return Window
end

return Library
