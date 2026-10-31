local InputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")

local lp = Players.LocalPlayer
local mouse = lp:GetMouse()
local CoreGui = (gethui and gethui()) or lp:WaitForChild("PlayerGui")

local vec2 = Vector2.new
local dim2 = UDim2.new
local dim = UDim.new
local rect = Rect.new
local dim_offset = UDim2.fromOffset
local rgb = Color3.fromRGB
local hex = Color3.fromHex

getgenv().fully = getgenv().fully or {}
local fully = getgenv().fully

fully.Directory = "fully"
fully.Folders = {"/configs"}
fully.Flags = {}
fully.ConfigFlags = {}
fully.Connections = {}
fully.Notifications = {Notifs = {}}
fully.__index = fully

local Flags = fully.Flags
local ConfigFlags = fully.ConfigFlags
local Notifications = fully.Notifications

local function GetDeviceType()
    if GuiService:IsTenFootInterface() then
        return "Console"
    elseif InputService.TouchEnabled and not InputService.KeyboardEnabled then
        return "Phone"
    elseif InputService.TouchEnabled and InputService.KeyboardEnabled then
        return "Tablet"
    else
        return "PC"
    end
end

local DeviceType = GetDeviceType()

local SizeConfig = {
    PC = {
        WindowSize = dim2(0, 720, 0, 500),
        MinSize = vec2(600, 450),
        MaxSize = vec2(1000, 800),
        TabSize = dim2(0, 30, 0, 30),
        IconSize = dim2(0, 16, 0, 16),
        HeaderHeight = 50,
        FooterHeight = 55,
        FontSize = {
            Title = 13,
            Subtitle = 11,
            Text = 13,
            SmallText = 11,
            ButtonText = 13,
            TabText = 13
        }
    },
    Tablet = {
        WindowSize = dim2(0, 600, 0, 420),
        MinSize = vec2(500, 380),
        MaxSize = vec2(850, 650),
        TabSize = dim2(0, 35, 0, 35),
        IconSize = dim2(0, 18, 0, 18),
        HeaderHeight = 45,
        FooterHeight = 50,
        FontSize = {
            Title = 12,
            Subtitle = 10,
            Text = 12,
            SmallText = 10,
            ButtonText = 12,
            TabText = 12
        }
    },
    Phone = {
        WindowSize = dim2(0, 0, 0, 0),
        MinSize = vec2(300, 320),
        MaxSize = vec2(500, 600),
        TabSize = dim2(0, 40, 0, 40),
        IconSize = dim2(0, 20, 0, 20),
        HeaderHeight = 40,
        FooterHeight = 45,
        FontSize = {
            Title = 11,
            Subtitle = 9,
            Text = 11,
            SmallText = 9,
            ButtonText = 11,
            TabText = 11
        }
    },
    Console = {
        WindowSize = dim2(0, 800, 0, 600),
        MinSize = vec2(700, 550),
        MaxSize = vec2(1200, 900),
        TabSize = dim2(0, 28, 0, 28),
        IconSize = dim2(0, 14, 0, 14),
        HeaderHeight = 55,
        FooterHeight = 60,
        FontSize = {
            Title = 14,
            Subtitle = 12,
            Text = 14,
            SmallText = 12,
            ButtonText = 14,
            TabText = 14
        }
    }
}

local CurrentSizeConfig = SizeConfig[DeviceType]

local themes = {
    preset = {
        accent       = rgb(0, 255, 0),
        glow         = rgb(0, 255, 0),
        background   = rgb(0, 0, 0),
        section      = rgb(15, 18, 15),
        element      = rgb(22, 26, 22),
        outline      = rgb(0, 255, 0),
        text         = rgb(0, 255, 0),
        subtext      = rgb(0, 255, 0),
        tab_active   = rgb(21, 0, 255),
        tab_inactive = rgb(15, 18, 15),
    },
    utility = {}
}

for property, _ in themes.preset do
    themes.utility[property] = {
        BackgroundColor3 = {}, TextColor3 = {}, ImageColor3 = {}, Color = {}, ScrollBarImageColor3 = {}
    }
end

local Keys = {
    [Enum.KeyCode.LeftShift] = "LS", [Enum.KeyCode.RightShift] = "RS",
    [Enum.KeyCode.LeftControl] = "LC", [Enum.KeyCode.RightControl] = "RC",
    [Enum.KeyCode.Insert] = "INS", [Enum.KeyCode.Backspace] = "BS",
    [Enum.KeyCode.Return] = "Ent", [Enum.KeyCode.Escape] = "ESC",
    [Enum.KeyCode.Space] = "SPC", [Enum.UserInputType.MouseButton1] = "MB1",
    [Enum.UserInputType.MouseButton2] = "MB2", [Enum.UserInputType.MouseButton3] = "MB3"
}

for _, path in fully.Folders do
    pcall(function() makefolder(fully.Directory .. path) end)
end

function fully:Tween(Object, Properties, Info)
    if not Object then return end
    local tween = TweenService:Create(Object, Info or TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), Properties)
    tween:Play()
    return tween
end

function fully:Create(instance, options)
    local ins = Instance.new(instance)
    for prop, value in options do ins[prop] = value end
    if ins:IsA("TextButton") or ins:IsA("ImageButton") then ins.AutoButtonColor = false end
    return ins
end

local function AddSubtleGradient(parent, rotation)
    return fully:Create("UIGradient", {
        Parent = parent,
        Rotation = rotation or 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, rgb(255, 255, 255)),
            ColorSequenceKeypoint.new(1, rgb(21, 0, 255))
        })
    })
end

function fully:Themify(instance, theme, property)
    if not themes.utility[theme] then return end
    table.insert(themes.utility[theme][property], instance)
    instance[property] = themes.preset[theme]
end

function fully:RefreshTheme(theme, color3)
    themes.preset[theme] = color3
    for property, instances in themes.utility[theme] do
        for _, object in instances do
            object[property] = color3
        end
    end
end

function fully:Resizify(Parent)
    local Resizing = fully:Create("TextButton", {
        AnchorPoint = vec2(1, 1), Position = dim2(1, 0, 1, 0), Size = dim2(0, 34, 0, 34),
        BorderSizePixel = 0, BackgroundTransparency = 1, Text = "", Parent = Parent, ZIndex = 999,
    })
    
    local grip = fully:Create("ImageLabel", {
        Parent = Resizing,
        AnchorPoint = vec2(1, 1),
        Position = dim2(1, -4, 1, -4),
        Size = dim2(0, 20, 0, 20),
        BackgroundTransparency = 1,
        Image = "rbxthumb://type=Asset&id=6153965696&w=150&h=150",
        ImageColor3 = themes.preset.accent,
        ImageTransparency = 0.5
    })
    
    fully:Themify(grip, "accent", "ImageColor3")

    local IsResizing, StartInputPos, StartSize = false, nil, nil
    local MIN_SIZE = CurrentSizeConfig.MinSize
    local MAX_SIZE = CurrentSizeConfig.MaxSize

    Resizing.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            IsResizing = true
            StartInputPos = input.Position
            StartSize = Parent.AbsoluteSize
        end
    end)

    Resizing.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            IsResizing = false
        end
    end)

    InputService.InputChanged:Connect(function(input)
        if not IsResizing then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - StartInputPos
            Parent.Size = UDim2.fromOffset(
                math.clamp(StartSize.X + delta.X, MIN_SIZE.X, MAX_SIZE.X),
                math.clamp(StartSize.Y + delta.Y, MIN_SIZE.Y, MAX_SIZE.Y)
            )
        end
    end)
end

function fully:Window(properties)
    local initialSize = properties.Size or properties.size or CurrentSizeConfig.WindowSize
    
    if DeviceType == "Phone" then
        local screenSize = Workspace.CurrentCamera.ViewportSize
        local width = math.clamp(screenSize.X * 0.9, 300, 500)
        local height = math.clamp(screenSize.Y * 0.7, 320, 600)
        initialSize = dim2(0, width, 0, height)
    end
    
    local Cfg = {
        Title = properties.Title or properties.title or properties.Prefix or "fully", 
        Subtitle = properties.Subtitle or properties.subtitle or properties.Suffix or "",
        Size = initialSize, 
        TabInfo = nil, Items = {}, Tweening = false, IsSwitchingTab = false
    }

    if fully.Gui then fully.Gui:Destroy() end
    if fully.Other then fully.Other:Destroy() end
    if fully.ToggleGui then fully.ToggleGui:Destroy() end

    fully.Gui = fully:Create("ScreenGui", { Parent = CoreGui, Name = HttpService:GenerateGUID(false), Enabled = true, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
    fully.Other = fully:Create("ScreenGui", { Parent = CoreGui, Name = HttpService:GenerateGUID(false), Enabled = false, IgnoreGuiInset = true })
    
    local Items = Cfg.Items
    local uiVisible = true

    Items.Wrapper = fully:Create("Frame", {
        Parent = fully.Gui, 
        Position = dim2(0.5, -Cfg.Size.X.Offset / 2, 0.5, -Cfg.Size.Y.Offset / 2),
        Size = Cfg.Size, 
        BackgroundTransparency = 1, 
        BorderSizePixel = 0
    })
    
    Items.Glow = fully:Create("ImageLabel", {
        ImageColor3 = themes.preset.glow,
        ScaleType = Enum.ScaleType.Slice,
        ImageTransparency = 0.65,
        BorderColor3 = rgb(0, 0, 0),
        Parent = Items.Wrapper,
        Name = "\0",
        Size = dim2(1, 40, 1, 40),
        Image = "rbxassetid://18245826428",
        BackgroundTransparency = 1,
        Position = dim2(0, -20, 0, -20),
        BackgroundColor3 = rgb(255, 255, 255),
        BorderSizePixel = 0,
        SliceCenter = rect(vec2(21, 21), vec2(79, 79)),
        ZIndex = 0
    })
    fully:Themify(Items.Glow, "glow", "ImageColor3")

    Items.Window = fully:Create("Frame", {
        Parent = Items.Wrapper, Position = dim2(0, 0, 0, 0), Size = dim2(1, 0, 1, 0),
        BackgroundColor3 = themes.preset.background, BorderSizePixel = 0, ZIndex = 1, ClipsDescendants = true
    })
    fully:Themify(Items.Window, "background", "BackgroundColor3")
    fully:Create("UICorner", { Parent = Items.Window, CornerRadius = dim(0, 6) })
    fully:Themify(fully:Create("UIStroke", { Parent = Items.Window, Color = themes.preset.outline, Thickness = 1 }), "outline", "Color")

    Items.Header = fully:Create("Frame", { 
        Parent = Items.Window, 
        Size = dim2(1, 0, 0, CurrentSizeConfig.HeaderHeight), 
        BackgroundTransparency = 1, 
        Active = true, 
        ZIndex = 2 
    })

    Items.LogoBlock = fully:Create("Frame", {
        Parent = Items.Header, 
        AnchorPoint = vec2(0, 0.5), 
        Position = dim2(0, 20, 0.5, 0), 
        Size = dim2(0, 3, 0, 20),
        BackgroundColor3 = themes.preset.accent,
        BorderSizePixel = 0,
        ZIndex = 4
    })
    fully:Create("UICorner", { Parent = Items.LogoBlock, CornerRadius = dim(0, 2) })
    fully:Themify(Items.LogoBlock, "accent", "BackgroundColor3")

    Items.LogoText = fully:Create("TextLabel", {
        Parent = Items.Header, 
        Text = Cfg.Title, 
        TextColor3 = themes.preset.text,
        AnchorPoint = vec2(0, 0), 
        Position = dim2(0, 28, 0, 12), 
        Size = dim2(0, 0, 0, 14), 
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1, 
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold), 
        TextSize = CurrentSizeConfig.FontSize.Title, 
        TextXAlignment = Enum.TextXAlignment.Left, 
        ZIndex = 4
    })
    fully:Themify(Items.LogoText, "text", "TextColor3")

    Items.SubLogoText = fully:Create("TextLabel", {
        Parent = Items.Header, 
        Text = Cfg.Subtitle, 
        TextColor3 = themes.preset.subtext,
        AnchorPoint = vec2(0, 0), 
        Position = dim2(0, 28, 0, 26), 
        Size = dim2(0, 0, 0, 12), 
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1, 
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium), 
        TextSize = CurrentSizeConfig.FontSize.Subtitle, 
        TextXAlignment = Enum.TextXAlignment.Left, 
        ZIndex = 4
    })
    fully:Themify(Items.SubLogoText, "subtext", "TextColor3")

    Items.TabHolder = fully:Create("Frame", { 
        Parent = Items.Header, 
        AnchorPoint = vec2(1, 0.5), 
        Position = dim2(1, -20, 0.5, 0),
        Size = dim2(1, -200, 1, 0), 
        BackgroundTransparency = 1, 
        ZIndex = 4
    })
    fully:Create("UIListLayout", { 
        Parent = Items.TabHolder, 
        FillDirection = Enum.FillDirection.Horizontal, 
        HorizontalAlignment = Enum.HorizontalAlignment.Right, 
        VerticalAlignment = Enum.VerticalAlignment.Center, 
        Padding = dim(0, 8) 
    })

    Items.Footer = fully:Create("Frame", { 
        Parent = Items.Window, 
        AnchorPoint = vec2(0, 1), 
        Position = dim2(0, 0, 1, 0), 
        Size = dim2(1, 0, 0, CurrentSizeConfig.FooterHeight), 
        BackgroundTransparency = 1, 
        BorderSizePixel = 0, 
        ZIndex = 2 
    })

    local headshot = "rbxthumb://type=AvatarHeadShot&id=" .. lp.UserId .. "&w=48&h=48"
    Items.AvatarFrame = fully:Create("Frame", {
        Parent = Items.Footer, 
        AnchorPoint = vec2(0, 0.5), 
        Position = dim2(0, 20, 0.5, 0), 
        Size = dim2(0, 28, 0, 28), 
        BackgroundColor3 = themes.preset.element, 
        BorderSizePixel = 0, 
        ZIndex = 5
    })
    fully:Themify(Items.AvatarFrame, "element", "BackgroundColor3")
    fully:Create("UICorner", { Parent = Items.AvatarFrame, CornerRadius = dim(0, 6) })
    
    Items.Avatar = fully:Create("ImageLabel", { 
        Parent = Items.AvatarFrame, 
        AnchorPoint = vec2(0.5, 0.5), 
        Position = dim2(0.5, 0, 0.5, 0), 
        Size = dim2(1, 0, 1, 0), 
        BackgroundTransparency = 1, 
        Image = headshot, 
        ZIndex = 6 
    })
    fully:Create("UICorner", { Parent = Items.Avatar, CornerRadius = dim(0, 6) })

    Items.Username = fully:Create("TextLabel", {
        Parent = Items.Footer, 
        Text = lp.Name, 
        TextColor3 = themes.preset.text,
        AnchorPoint = vec2(0, 0), 
        Position = dim2(0, 58, 0, 13), 
        Size = dim2(0, 200, 0, 14),
        BackgroundTransparency = 1, 
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium), 
        TextSize = CurrentSizeConfig.FontSize.Text, 
        TextXAlignment = Enum.TextXAlignment.Left, 
        ZIndex = 5
    })
    fully:Themify(Items.Username, "text", "TextColor3")

    Items.Status = fully:Create("TextLabel", {
        Parent = Items.Footer, 
        Text = "Status : " .. DeviceType, 
        TextColor3 = themes.preset.subtext,
        AnchorPoint = vec2(0, 0), 
        Position = dim2(0, 58, 0, 28), 
        Size = dim2(0, 200, 0, 12),
        BackgroundTransparency = 1, 
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium), 
        TextSize = CurrentSizeConfig.FontSize.SmallText, 
        TextXAlignment = Enum.TextXAlignment.Left, 
        ZIndex = 5
    })
    fully:Themify(Items.Status, "subtext", "TextColor3")

    Items.SettingsBtn = fully:Create("ImageButton", {
        Parent = Items.Footer, 
        AnchorPoint = vec2(1, 0.5), 
        Position = dim2(1, -45, 0.5, 0),
        Size = CurrentSizeConfig.IconSize, 
        BackgroundTransparency = 1, 
        Image = "rbxassetid://11293977610", 
        ImageColor3 = themes.preset.subtext, 
        ZIndex = 5
    })
    fully:Themify(Items.SettingsBtn, "subtext", "ImageColor3")
    
    Items.SettingsBtn.MouseButton1Click:Connect(function()
        if Cfg.SettingsTabOpen then Cfg.SettingsTabOpen() end
    end)

    Items.PageHolder = fully:Create("Frame", { 
        Parent = Items.Window, 
        Position = dim2(0, 0, 0, CurrentSizeConfig.HeaderHeight), 
        Size = dim2(1, 0, 1, -(CurrentSizeConfig.HeaderHeight + CurrentSizeConfig.FooterHeight)), 
        BackgroundTransparency = 1, 
        ClipsDescendants = true 
    })

    local Dragging, DragInput, DragStart, StartPos
    Items.Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true; DragStart = input.Position; StartPos = Items.Wrapper.Position
        end
    end)
    Items.Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            Dragging = false 
        end
    end)
    InputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - DragStart
            Items.Wrapper.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
        end
    end)
    fully:Resizify(Items.Wrapper)

    function Cfg.ToggleMenu(bool)
        if Cfg.Tweening then return end
        if bool == nil then uiVisible = not uiVisible else uiVisible = bool end
        Items.Wrapper.Visible = uiVisible
    end

    if DeviceType == "Phone" or DeviceType == "Tablet" then
        fully.ToggleGui = fully:Create("ScreenGui", { Parent = CoreGui, Name = HttpService:GenerateGUID(false), IgnoreGuiInset = true })
        local ToggleButton = fully:Create("ImageButton", {
            Name = "ToggleButton", 
            Parent = fully.ToggleGui, 
            Position = UDim2.new(1, -80, 0, 150), 
            Size = UDim2.new(0, 55, 0, 55),
            BackgroundTransparency = 0.2, 
            BackgroundColor3 = themes.preset.element, 
            Image = "rbxthumb://type=Asset&id=72832907201517&w=420&h=420", 
            ZIndex = 10000,
        })
        fully:Create("UICorner", { Parent = ToggleButton, CornerRadius = dim(0, 12) })
        fully:Themify(ToggleButton, "element", "BackgroundColor3")
        fully:Themify(fully:Create("UIStroke", { Parent = ToggleButton, Color = themes.preset.outline, Thickness = 1.5 }), "outline", "Color")

        local isTDrag, tDragStart, tStartPos, hasTDragged = false, nil, nil, false
        ToggleButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isTDrag = true; hasTDragged = false; tDragStart = input.Position; tStartPos = ToggleButton.Position
            end
        end)
        ToggleButton.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isTDrag = false; if not hasTDragged then Cfg.ToggleMenu() end
            end
        end)
        InputService.InputChanged:Connect(function(input)
            if isTDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - tDragStart
                if delta.Magnitude > 5 then 
                    hasTDragged = true
                    ToggleButton.Position = UDim2.new(tStartPos.X.Scale, tStartPos.X.Offset + delta.X, tStartPos.Y.Scale, tStartPos.Y.Offset + delta.Y) 
                end
            end
        end)
    end

    if DeviceType == "Phone" then
        task.spawn(function()
            task.wait(0.1)
            local screenSize = Workspace.CurrentCamera.ViewportSize
            local guiSize = Items.Wrapper.AbsoluteSize
            Items.Wrapper.Position = UDim2.new(0.5, -guiSize.X/2, 0.5, -guiSize.Y/2)
        end)
    end

    return setmetatable(Cfg, fully)
end

function fully:Tab(properties)
    local Cfg = { 
        Name = properties.Name or properties.name or "Tab", 
        Icon = properties.Icon or properties.icon or "rbxassetid://11293977610", 
        Hidden = properties.Hidden or properties.hidden or false, 
        Items = {} 
    }
    if tonumber(Cfg.Icon) then Cfg.Icon = "rbxassetid://" .. tostring(Cfg.Icon) end
    local Items = Cfg.Items

    if not Cfg.Hidden then
        Items.Button = fully:Create("TextButton", { 
            Parent = self.Items.TabHolder, 
            Size = CurrentSizeConfig.TabSize, 
            BackgroundColor3 = themes.preset.accent,
            BackgroundTransparency = 1, 
            Text = "", 
            AutoButtonColor = false, 
            ZIndex = 5 
        })
        fully:Themify(Items.Button, "accent", "BackgroundColor3")
        fully:Create("UICorner", { Parent = Items.Button, CornerRadius = dim(0, 6) })
        
        fully:Create("UIGradient", {
            Parent = Items.Button,
            Rotation = 45,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.4),
                NumberSequenceKeypoint.new(1, 0.8)
            }),
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, rgb(255, 255, 255)),
                ColorSequenceKeypoint.new(1, rgb(180, 230, 180))
            })
        })
        
        Items.IconImg = fully:Create("ImageLabel", { 
            Parent = Items.Button, 
            AnchorPoint = vec2(0.5, 0.5), 
            Position = dim2(0.5, 0, 0.5, 0),
            Size = CurrentSizeConfig.IconSize, 
            BackgroundTransparency = 1, 
            Image = Cfg.Icon, 
            ImageColor3 = themes.preset.subtext, 
            ZIndex = 6 
        })
        fully:Themify(Items.IconImg, "subtext", "ImageColor3")
    end

    Items.Pages = fully:Create("CanvasGroup", { 
        Parent = fully.Other, 
        Size = dim2(1, 0, 1, 0), 
        BackgroundTransparency = 1, 
        Visible = false, 
        GroupTransparency = 1 
    })
    
    if DeviceType == "Phone" then
        Items.Left = fully:Create("ScrollingFrame", { 
            Parent = Items.Pages, 
            Size = dim2(1, 0, 1, 0), 
            BackgroundTransparency = 1, 
            ScrollBarThickness = 0, 
            CanvasSize = dim2(0, 0, 0, 0), 
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        fully:Create("UIListLayout", { Parent = Items.Left, Padding = dim(0, 10) })
        fully:Create("UIPadding", { Parent = Items.Left, PaddingTop = dim(0, 10), PaddingBottom = dim(0, 10), PaddingRight = dim(0, 15), PaddingLeft = dim(0, 15) })
    else
        fully:Create("UIListLayout", { Parent = Items.Pages, FillDirection = Enum.FillDirection.Horizontal, Padding = dim(0, 14) })
        fully:Create("UIPadding", { Parent = Items.Pages, PaddingTop = dim(0, 10), PaddingBottom = dim(0, 10), PaddingRight = dim(0, 20), PaddingLeft = dim(0, 20) })

        Items.Left = fully:Create("ScrollingFrame", { 
            Parent = Items.Pages, 
            Size = dim2(0.5, -7, 1, 0), 
            BackgroundTransparency = 1, 
            ScrollBarThickness = 0, 
            CanvasSize = dim2(0, 0, 0, 0), 
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        fully:Create("UIListLayout", { Parent = Items.Left, Padding = dim(0, 14) })
        fully:Create("UIPadding", { Parent = Items.Left, PaddingBottom = dim(0, 10) })

        Items.Right = fully:Create("ScrollingFrame", { 
            Parent = Items.Pages, 
            Size = dim2(0.5, -7, 1, 0), 
            BackgroundTransparency = 1, 
            ScrollBarThickness = 0, 
            CanvasSize = dim2(0, 0, 0, 0), 
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        fully:Create("UIListLayout", { Parent = Items.Right, Padding = dim(0, 14) })
        fully:Create("UIPadding", { Parent = Items.Right, PaddingBottom = dim(0, 10) })
    end

    function Cfg.OpenTab()
        if self.IsSwitchingTab or self.TabInfo == Cfg.Items then return end
        local oldTab = self.TabInfo
        self.IsSwitchingTab = true
        self.TabInfo = Cfg.Items

        local buttonTween = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

        if oldTab and oldTab.Button then
            fully:Tween(oldTab.Button, {BackgroundTransparency = 1}, buttonTween)
            fully:Tween(oldTab.IconImg, {ImageColor3 = themes.preset.subtext}, buttonTween)
        end

        if Items.Button then 
            fully:Tween(Items.Button, {BackgroundTransparency = 0}, buttonTween)
            fully:Tween(Items.IconImg, {ImageColor3 = rgb(10, 14, 10)}, buttonTween) 
        end
        
        task.spawn(function()
            if oldTab then
                fully:Tween(oldTab.Pages, {GroupTransparency = 1, Position = dim2(0, 0, 0, 10)}, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
                task.wait(0.2)
                oldTab.Pages.Visible = false
                oldTab.Pages.Parent = fully.Other
            end

            Items.Pages.Position = dim2(0, 0, 0, 10) 
            Items.Pages.GroupTransparency = 1
            Items.Pages.Parent = self.Items.PageHolder
            Items.Pages.Visible = true

            fully:Tween(Items.Pages, {GroupTransparency = 0, Position = dim2(0, 0, 0, 0)}, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
            task.wait(0.35)
            
            Items.Pages.GroupTransparency = 0 
            self.IsSwitchingTab = false
        end)
    end

    function Cfg.SetIcon(newIcon)
        if tonumber(newIcon) then newIcon = "rbxassetid://" .. tostring(newIcon) end
        Cfg.Icon = newIcon
        if Items.IconImg then Items.IconImg.Image = newIcon end
    end

    if Items.Button then Items.Button.MouseButton1Down:Connect(Cfg.OpenTab) end
    if not self.TabInfo and not Cfg.Hidden then Cfg.OpenTab() end
    return setmetatable(Cfg, fully)
end

function fully:Section(properties)
    local Cfg = { 
        Name = properties.Name or properties.name or "Section", 
        Side = properties.Side or properties.side or "Left", 
        RightIcon = properties.RightIcon or properties.righticon or "rbxassetid://12338898398",
        Items = {} 
    }
    Cfg.Side = (Cfg.Side:lower() == "right") and "Right" or "Left"
    local Items = Cfg.Items

    local parent = self.Items[Cfg.Side]
    if DeviceType == "Phone" then parent = self.Items.Left end

    Items.Section = fully:Create("Frame", { 
        Parent = parent, 
        Size = dim2(1, 0, 0, 0), 
        AutomaticSize = Enum.AutomaticSize.Y, 
        BackgroundColor3 = themes.preset.section, 
        BorderSizePixel = 0, 
        ClipsDescendants = true 
    })
    fully:Themify(Items.Section, "section", "BackgroundColor3")
    fully:Create("UICorner", { Parent = Items.Section, CornerRadius = dim(0, 6) })
    
    fully:Create("UIGradient", {
        Parent = Items.Section, Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, rgb(255, 255, 255)),
            ColorSequenceKeypoint.new(1, rgb(225, 225, 225))
        })
    })

    Items.AccentLine = fully:Create("Frame", {
        Parent = Items.Section, 
        Size = dim2(0, 2, 1, 0), 
        Position = dim2(0, 0, 0, 0),
        BackgroundColor3 = themes.preset.accent, 
        BorderSizePixel = 0, 
        ZIndex = 2
    })
    fully:Themify(Items.AccentLine, "accent", "BackgroundColor3")

    fully:Create("UIGradient", {
        Parent = Items.AccentLine, Rotation = 90,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.6, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
    })

    Items.Header = fully:Create("Frame", { Parent = Items.Section, Size = dim2(1, 0, 0, 36), BackgroundTransparency = 1 })
    
    Items.Title = fully:Create("TextLabel", { 
        Parent = Items.Header, 
        Position = dim2(0, 14, 0.5, 0), 
        AnchorPoint = vec2(0, 0.5), 
        Size = dim2(1, -46, 0, 14), 
        BackgroundTransparency = 1, 
        Text = Cfg.Name, 
        TextColor3 = themes.preset.text, 
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold), 
        TextSize = CurrentSizeConfig.FontSize.TabText, 
        TextXAlignment = Enum.TextXAlignment.Left 
    })
    fully:Themify(Items.Title, "text", "TextColor3")

    Items.Chevron = fully:Create("ImageLabel", {
        Parent = Items.Header, 
        Position = dim2(1, -14, 0.5, 0), 
        AnchorPoint = vec2(1, 0.5), 
        Size = dim2(0, 12, 0, 12),
        BackgroundTransparency = 1, 
        Image = Cfg.RightIcon, 
        ImageColor3 = themes.preset.subtext, 
        Rotation = 0
    })
    fully:Themify(Items.Chevron, "subtext", "ImageColor3")

    Items.Container = fully:Create("Frame", { 
        Parent = Items.Section, 
        Position = dim2(0, 0, 0, 36), 
        Size = dim2(1, 0, 0, 0), 
        AutomaticSize = Enum.AutomaticSize.Y, 
        BackgroundTransparency = 1 
    })
    fully:Create("UIListLayout", { Parent = Items.Container, Padding = dim(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
    fully:Create("UIPadding", { Parent = Items.Container, PaddingBottom = dim(0, 12), PaddingLeft = dim(0, 14), PaddingRight = dim(0, 14) })

    return setmetatable(Cfg, fully)
end

function fully:Toggle(properties)
    local Cfg = { 
        Name = properties.Name or properties.name or "Toggle", 
        Flag = properties.Flag or properties.flag, 
        Default = properties.Default or properties.default or false, 
        Callback = properties.Callback or properties.callback or function() end, 
        Items = {} 
    }
    local Items = Cfg.Items

    Items.Button = fully:Create("TextButton", { Parent = self.Items.Container, Size = dim2(1, 0, 0, 22), BackgroundTransparency = 1, Text = "" })
    
    Items.Checkbox = fully:Create("Frame", { 
        Parent = Items.Button, AnchorPoint = vec2(0, 0.5), Position = dim2(0, 6, 0.5, 0), Size = dim2(0, 14, 0, 14), 
        BackgroundColor3 = themes.preset.element, BorderSizePixel = 0 
    })
    fully:Themify(Items.Checkbox, "element", "BackgroundColor3")
    fully:Create("UICorner", { Parent = Items.Checkbox, CornerRadius = dim(0, 3) })
    AddSubtleGradient(Items.Checkbox, 90)

    Items.CheckFill = fully:Create("Frame", {
        Parent = Items.Checkbox, Size = dim2(1, 0, 1, 0),
        BackgroundColor3 = themes.preset.accent, BorderSizePixel = 0,
        BackgroundTransparency = 1
    })
    fully:Themify(Items.CheckFill, "accent", "BackgroundColor3")
    fully:Create("UICorner", { Parent = Items.CheckFill, CornerRadius = dim(0, 3) })
    AddSubtleGradient(Items.CheckFill, 90)

    Items.Title = fully:Create("TextLabel", { 
        Parent = Items.Button, Position = dim2(0, 30, 0.5, 0), AnchorPoint = vec2(0, 0.5), Size = dim2(1, -26, 1, 0), 
        BackgroundTransparency = 1, Text = Cfg.Name, TextColor3 = themes.preset.subtext, 
        TextSize = CurrentSizeConfig.FontSize.Text, 
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium), TextXAlignment = Enum.TextXAlignment.Left 
    })
    fully:Themify(Items.Title, "subtext", "TextColor3")

    local State = false
    function Cfg.set(bool)
        State = bool
        fully:Tween(Items.CheckFill, {BackgroundTransparency = State and 0 or 1}, TweenInfo.new(0.2))
        fully:Tween(Items.Title, {TextColor3 = State and themes.preset.text or themes.preset.subtext}, TweenInfo.new(0.2))
        if Cfg.Flag then Flags[Cfg.Flag] = State end
        Cfg.Callback(State)
    end

    Items.Button.MouseButton1Click:Connect(function() Cfg.set(not State) end)
    if Cfg.Default then Cfg.set(true) end
    if Cfg.Flag then ConfigFlags[Cfg.Flag] = Cfg.set end

    return setmetatable(Cfg, fully)
end

function fully:Button(properties)
    local Cfg = { 
        Name = properties.Name or properties.name or "Button", 
        Callback = properties.Callback or properties.callback or function() end, 
        Items = {} 
    }
    local Items = Cfg.Items

    Items.Button = fully:Create("TextButton", { 
        Parent = self.Items.Container, Size = dim2(1, 0, 0, 30), BackgroundColor3 = themes.preset.element, 
        Text = Cfg.Name, TextColor3 = themes.preset.subtext, 
        TextSize = CurrentSizeConfig.FontSize.ButtonText, 
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium), AutoButtonColor = false 
    })
    fully:Themify(Items.Button, "element", "BackgroundColor3")
    fully:Themify(Items.Button, "subtext", "TextColor3")
    fully:Create("UICorner", { Parent = Items.Button, CornerRadius = dim(0, 4) })
    AddSubtleGradient(Items.Button, 90)

    Items.Button.MouseButton1Click:Connect(function()
        fully:Tween(Items.Button, {BackgroundColor3 = themes.preset.outline, TextColor3 = themes.preset.text}, TweenInfo.new(0.1))
        task.wait(0.1)
        fully:Tween(Items.Button, {BackgroundColor3 = themes.preset.element, TextColor3 = themes.preset.subtext}, TweenInfo.new(0.2))
        Cfg.Callback()
    end)
    return setmetatable(Cfg, fully)
end

function fully:Slider(properties)
    local Cfg = { 
        Name = properties.Name or properties.name or "Slider", 
        Flag = properties.Flag or properties.flag, 
        Min = properties.Min or properties.min or 0, 
        Max = properties.Max or properties.max or 100, 
        Default = properties.Default or properties.default or properties.Value or properties.value or 0, 
        Increment = properties.Increment or properties.increment or 1, 
        Suffix = properties.Suffix or properties.suffix or "", 
        Callback = properties.Callback or properties.callback or function() end, 
        Items = {} 
    }
    local Items = Cfg.Items

    Items.Container = fully:Create("Frame", { Parent = self.Items.Container, Size = dim2(1, 0, 0, 38), BackgroundTransparency = 1 })
    Items.Title = fully:Create("TextLabel", { Parent = Items.Container, Size = dim2(1, 0, 0, 20), BackgroundTransparency = 1, Text = "  " .. Cfg.Name, TextColor3 = themes.preset.subtext, TextSize = CurrentSizeConfig.FontSize.Text, FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium), TextXAlignment = Enum.TextXAlignment.Left })
    fully:Themify(Items.Title, "subtext", "TextColor3")

    Items.Val = fully:Create("TextLabel", { Parent = Items.Container, Size = dim2(1, 0, 0, 20), BackgroundTransparency = 1, Text = tostring(Cfg.Default) .. Cfg.Suffix, TextColor3 = themes.preset.subtext, TextSize = CurrentSizeConfig.FontSize.Text, FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium), TextXAlignment = Enum.TextXAlignment.Right })
    fully:Themify(Items.Val, "subtext", "TextColor3")

    Items.Track = fully:Create("TextButton", { Parent = Items.Container, Position = dim2(0, 4, 0, 24), Size = dim2(1, -8, 0, 6), BackgroundColor3 = themes.preset.element, Text = "", AutoButtonColor = false })
    fully:Themify(Items.Track, "element", "BackgroundColor3")
    fully:Create("UICorner", { Parent = Items.Track, CornerRadius = dim(1, 0) })
    AddSubtleGradient(Items.Track, 90)

    Items.Fill = fully:Create("Frame", { Parent = Items.Track, Size = dim2(0, 0, 1, 0), BackgroundColor3 = themes.preset.accent })
    fully:Themify(Items.Fill, "accent", "BackgroundColor3")
    fully:Create("UICorner", { Parent = Items.Fill, CornerRadius = dim(1, 0) })
    AddSubtleGradient(Items.Fill, 90)
    
    Items.Knob = fully:Create("Frame", { Parent = Items.Fill, AnchorPoint = vec2(0.5, 0.5), Position = dim2(1, 0, 0.5, 0), Size = dim2(0, 12, 0, 12), BackgroundColor3 = themes.preset.accent })
    fully:Create("UICorner", { Parent = Items.Knob, CornerRadius = dim(1, 0) })
    fully:Themify(Items.Knob, "accent", "BackgroundColor3")
    AddSubtleGradient(Items.Knob, 90)

    local Value = Cfg.Default
    function Cfg.set(val)
        Value = math.clamp(math.round(val / Cfg.Increment) * Cfg.Increment, Cfg.Min, Cfg.Max)
        Items.Val.Text = tostring(Value) .. Cfg.Suffix
        fully:Tween(Items.Fill, {Size = dim2((Value - Cfg.Min) / (Cfg.Max - Cfg.Min), 0, 1, 0)}, TweenInfo.new(0.15))
        if Cfg.Flag then Flags[Cfg.Flag] = Value end
        Cfg.Callback(Value)
    end

    local Dragging = false
    Items.Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            Dragging = true
            Cfg.set(Cfg.Min + (Cfg.Max - Cfg.Min) * math.clamp((input.Position.X - Items.Track.AbsolutePosition.X) / Items.Track.AbsoluteSize.X, 0, 1)) 
        end
    end)
    InputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then Dragging = false end
    end)
    InputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            Cfg.set(Cfg.Min + (Cfg.Max - Cfg.Min) * math.clamp((input.Position.X - Items.Track.AbsolutePosition.X) / Items.Track.AbsoluteSize.X, 0, 1))
        end
    end)

    Cfg.set(Cfg.Default)
    if Cfg.Flag then ConfigFlags[Cfg.Flag] = Cfg.set end
    return setmetatable(Cfg, fully)
end

function fully:Textbox(properties)
    local Cfg = { 
        Name = properties.Name or properties.name or "", 
        Placeholder = properties.Placeholder or properties.placeholder or "Enter text...", 
        Default = properties.Default or properties.default or "", 
        Flag = properties.Flag or properties.flag, 
        Numeric = properties.Numeric or properties.numeric or false, 
        Callback = properties.Callback or properties.callback or function() end, 
        Items = {} 
    }
    local Items = Cfg.Items

    Items.Container = fully:Create("Frame", { Parent = self.Items.Container, Size = dim2(1, 0, 0, 32), BackgroundTransparency = 1 })
    Items.Bg = fully:Create("Frame", { Parent = Items.Container, Size = dim2(1, 0, 1, 0), BackgroundColor3 = themes.preset.element })
    fully:Themify(Items.Bg, "element", "BackgroundColor3")
    fully:Create("UICorner", { Parent = Items.Bg, CornerRadius = dim(0, 4) })
    AddSubtleGradient(Items.Bg, 90)

    Items.Input = fully:Create("TextBox", { 
        Parent = Items.Bg, Position = dim2(0, 12, 0, 0), Size = dim2(1, -24, 1, 0), BackgroundTransparency = 1, 
        Text = Cfg.Default, PlaceholderText = Cfg.Placeholder, TextColor3 = themes.preset.text, PlaceholderColor3 = themes.preset.subtext, 
        TextSize = CurrentSizeConfig.FontSize.Text, 
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium), TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false 
    })
    fully:Themify(Items.Input, "text", "TextColor3")

    function Cfg.set(val)
        if Cfg.Numeric and tonumber(val) == nil and val ~= "" then return end
        Items.Input.Text = tostring(val)
        if Cfg.Flag then Flags[Cfg.Flag] = val end
        Cfg.Callback(val)
    end
    
    Items.Input.FocusLost:Connect(function() Cfg.set(Items.Input.Text) end)
    if Cfg.Default ~= "" then Cfg.set(Cfg.Default) end
    if Cfg.Flag then ConfigFlags[Cfg.Flag] = Cfg.set end

    return setmetatable(Cfg, fully)
end

function fully:Dropdown(properties)
    local Cfg = { 
        Name = properties.Name or properties.name or "Dropdown", 
        Flag = properties.Flag or properties.flag, 
        Options = properties.Options or properties.options or properties.items or {}, 
        Default = properties.Default or properties.default, 
        Callback = properties.Callback or properties.callback or function() end, 
        Items = {} 
    }
    local Items = Cfg.Items
    
    Items.Container = fully:Create("Frame", { Parent = self.Items.Container, Size = dim2(1, 0, 0, 46), BackgroundTransparency = 1 })
    Items.Title = fully:Create("TextLabel", { Parent = Items.Container, Size = dim2(1, 0, 0, 16), BackgroundTransparency = 1, Text = "  " .. Cfg.Name, TextColor3 = themes.preset.subtext, TextSize = CurrentSizeConfig.FontSize.Text, FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium), TextXAlignment = Enum.TextXAlignment.Left })
    fully:Themify(Items.Title, "subtext", "TextColor3")

    Items.Main = fully:Create("TextButton", { 
        Parent = Items.Container, Position = dim2(0, 0, 0, 20), Size = dim2(1, 0, 0, 26), 
        BackgroundColor3 = themes.preset.element, Text = "", AutoButtonColor = false 
    })
    fully:Themify(Items.Main, "element", "BackgroundColor3")
    fully:Create("UICorner", { Parent = Items.Main, CornerRadius = dim(0, 4) })
    AddSubtleGradient(Items.Main, 90)

    Items.SelectedText = fully:Create("TextLabel", { Parent = Items.Main, Position = dim2(0, 12, 0, 0), Size = dim2(1, -24, 1, 0), BackgroundTransparency = 1, Text = "...", TextColor3 = themes.preset.subtext, TextSize = CurrentSizeConfig.FontSize.Text, FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium), TextXAlignment = Enum.TextXAlignment.Left })
    fully:Themify(Items.SelectedText, "subtext", "TextColor3")
    
    Items.Icon = fully:Create("ImageLabel", { Parent = Items.Main, Position = dim2(1, -20, 0.5, 0), AnchorPoint = vec2(0, 0.5), Size = dim2(0, 10, 0, 10), BackgroundTransparency = 1, Image = "rbxassetid://12338898398", ImageColor3 = themes.preset.subtext, Rotation = 0 })

    Items.DropFrame = fully:Create("Frame", { 
        Parent = fully.Gui, Size = dim2(1, 0, 0, 0), Position = dim2(0, 0, 0, 0), 
        BackgroundColor3 = themes.preset.element, Visible = false, ZIndex = 200, ClipsDescendants = true 
    })
    fully:Themify(Items.DropFrame, "element", "BackgroundColor3")
    fully:Create("UICorner", { Parent = Items.DropFrame, CornerRadius = dim(0, 4) })

    Items.SearchBg = fully:Create("Frame", { Parent = Items.DropFrame, Size = dim2(1, -12, 0, 24), Position = dim2(0, 6, 0, 6), BackgroundColor3 = themes.preset.background, BorderSizePixel = 0, BackgroundTransparency = 1, ZIndex = 201 })
    fully:Themify(Items.SearchBg, "background", "BackgroundColor3")
    fully:Create("UICorner", { Parent = Items.SearchBg, CornerRadius = dim(0, 4) })
    AddSubtleGradient(Items.SearchBg, 90)

    Items.SearchInput = fully:Create("TextBox", {
        Parent = Items.SearchBg, Size = dim2(1, -16, 1, 0), Position = dim2(0, 8, 0, -4), BackgroundTransparency = 1, 
        Text = "", PlaceholderText = "Search...", TextColor3 = themes.preset.text, PlaceholderColor3 = themes.preset.subtext, 
        TextSize = CurrentSizeConfig.FontSize.SmallText, 
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium), TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, TextTransparency = 1, ZIndex = 202
    })
    fully:Themify(Items.SearchInput, "text", "TextColor3")

    Items.Scroll = fully:Create("ScrollingFrame", { 
        Parent = Items.DropFrame, Size = dim2(1, 0, 1, -36), Position = dim2(0, 0, 0, 32), 
        BackgroundTransparency = 1, ScrollBarThickness = 0, BorderSizePixel = 0, ZIndex = 201 
    })
    fully:Create("UIListLayout", { Parent = Items.Scroll, SortOrder = Enum.SortOrder.LayoutOrder })

    local Open = false
    local isTweening = false
    local OptionBtns = {}

    function Cfg.UpdatePosition()
        local absPos = Items.Main.AbsolutePosition
        local absSize = Items.Main.AbsoluteSize
        Items.DropFrame.Position = dim2(0, absPos.X, 0, absPos.Y + absSize.Y + 4)
        local visibleCount = 0
        for _, data in ipairs(OptionBtns) do
            if data.btn.Size.Y.Offset > 0 then visibleCount += 1 end
        end
        Items.Scroll.CanvasSize = dim2(0, 0, 0, visibleCount * 24)
    end

    local function FilterOptions()
        local text = Items.SearchInput.Text:lower()
        local visibleCount = 0
        
        for _, data in ipairs(OptionBtns) do
            local btn = data.btn
            local optText = data.text:lower()
            
            if text == "" or optText:find(text, 1, true) then
                visibleCount += 1
                fully:Tween(btn, {Size = dim2(1, 0, 0, 24), TextTransparency = 0}, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
            else
                fully:Tween(btn, {Size = dim2(1, 0, 0, 0), TextTransparency = 1}, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
            end
        end
        
        if Open and not isTweening then
            local targetHeight = math.clamp(visibleCount * 24 + 38, 38, 180)
            fully:Tween(Items.DropFrame, {Size = dim2(0, Items.Main.AbsoluteSize.X, 0, targetHeight)}, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
            Items.Scroll.CanvasSize = dim2(0, 0, 0, visibleCount * 24)
        end
    end
    Items.SearchInput:GetPropertyChangedSignal("Text"):Connect(FilterOptions)

    local function ToggleDropdown()
        if isTweening then return end
        isTweening = true

        if not Open then
            Items.SearchInput.Text = ""
            Open = true
            
            Items.DropFrame.Visible = true
            Cfg.UpdatePosition()
            Items.DropFrame.Size = dim2(0, Items.Main.AbsoluteSize.X, 0, 0)
            
            local visibleCount = #Cfg.Options
            local targetHeight = math.clamp(visibleCount * 24 + 38, 38, 180)
            
            fully:Tween(Items.Icon, {Rotation = 180}, TweenInfo.new(0.3))
            
            Items.SearchBg.BackgroundTransparency = 1
            Items.SearchInput.TextTransparency = 1
            Items.SearchInput.Position = dim2(0, 8, 0, -4)
            fully:Tween(Items.SearchBg, {BackgroundTransparency = 0}, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
            fully:Tween(Items.SearchInput, {TextTransparency = 0, Position = dim2(0, 8, 0, 0)}, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
            
            local tw = fully:Tween(Items.DropFrame, {Size = dim2(0, Items.Main.AbsoluteSize.X, 0, targetHeight)}, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
            tw.Completed:Wait()
        else
            Open = false
            fully:Tween(Items.Icon, {Rotation = 0}, TweenInfo.new(0.3))
            
            fully:Tween(Items.SearchBg, {BackgroundTransparency = 1}, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In))
            fully:Tween(Items.SearchInput, {TextTransparency = 1, Position = dim2(0, 8, 0, -4)}, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In))
            
            local tw = fully:Tween(Items.DropFrame, {Size = dim2(0, Items.Main.AbsoluteSize.X, 0, 0)}, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
            tw.Completed:Wait()
            Items.DropFrame.Visible = false
        end
        isTweening = false
    end
    Items.Main.MouseButton1Click:Connect(ToggleDropdown)

    InputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if Open and not isTweening then
                local mx, my = input.Position.X, input.Position.Y
                local p0, s0 = Items.DropFrame.AbsolutePosition, Items.DropFrame.AbsoluteSize
                local p1, s1 = Items.Main.AbsolutePosition, Items.Main.AbsoluteSize
                
                if not (mx >= p0.X and mx <= p0.X + s0.X and my >= p0.Y and my <= p0.Y + s0.Y) and 
                   not (mx >= p1.X and mx <= p1.X + s1.X and my >= p1.Y and my <= p1.Y + s1.Y) then
                    ToggleDropdown()
                end
            end
        end
    end)

    function Cfg.RefreshOptions(newList)
        Cfg.Options = newList or Cfg.Options
        for _, data in ipairs(OptionBtns) do data.btn:Destroy() end
        table.clear(OptionBtns)
        for _, opt in ipairs(Cfg.Options) do
            local btn = fully:Create("TextButton", { 
                Parent = Items.Scroll, Size = dim2(1, 0, 0, 24), BackgroundTransparency = 1, 
                Text = "   " .. tostring(opt), TextColor3 = themes.preset.subtext, 
                TextSize = CurrentSizeConfig.FontSize.SmallText, 
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 202,
                ClipsDescendants = true
            })
            fully:Themify(btn, "subtext", "TextColor3")
            btn.MouseButton1Click:Connect(function() Cfg.set(opt); ToggleDropdown() end)
            table.insert(OptionBtns, {btn = btn, text = tostring(opt)})
        end
        FilterOptions()
    end

    function Cfg.set(val)
        Items.SelectedText.Text = tostring(val)
        if Cfg.Flag then Flags[Cfg.Flag] = val end
        Cfg.Callback(val)
    end

    Cfg.RefreshOptions(Cfg.Options)
    if Cfg.Default then Cfg.set(Cfg.Default) end
    if Cfg.Flag then ConfigFlags[Cfg.Flag] = Cfg.set end

    RunService.RenderStepped:Connect(function() 
        if Open or isTweening then 
            Items.DropFrame.Position = dim2(0, Items.Main.AbsolutePosition.X, 0, Items.Main.AbsolutePosition.Y + Items.Main.AbsoluteSize.Y + 4)
        end 
    end)
    return setmetatable(Cfg, fully)
end

function fully:Label(properties)
    local Cfg = { 
        Name = properties.Name or properties.name or "Label", 
        Wrapped = properties.Wrapped or properties.wrapped or false, 
        Items = {} 
    }
    local Items = Cfg.Items
    Items.Title = fully:Create("TextLabel", { 
        Parent = self.Items.Container, Size = dim2(1, 0, 0, Cfg.Wrapped and 26 or 18), BackgroundTransparency = 1, 
        Text = "  " .. Cfg.Name, TextColor3 = themes.preset.subtext, 
        TextSize = CurrentSizeConfig.FontSize.Text, TextWrapped = Cfg.Wrapped, 
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium), TextXAlignment = Enum.TextXAlignment.Left, 
        TextYAlignment = Cfg.Wrapped and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center 
    })
    fully:Themify(Items.Title, "subtext", "TextColor3")
    
    function Cfg.set(val) Items.Title.Text = "  " .. tostring(val) end
    return setmetatable(Cfg, fully)
end

function fully:Colorpicker(properties)
    local Cfg = { 
        Color = properties.Color or properties.color or rgb(255, 255, 255), 
        Callback = properties.Callback or properties.callback or function() end, 
        Flag = properties.Flag or properties.flag, 
        Items = {} 
    }
    local Items = Cfg.Items

    local btn = fully:Create("TextButton", { Parent = self.Items.Title or self.Items.Button or self.Items.Container, AnchorPoint = vec2(1, 0.5), Position = dim2(1, -6, 0.5, 0), Size = dim2(0, 30, 0, 14), BackgroundColor3 = Cfg.Color, Text = "" })
    fully:Create("UICorner", {Parent = btn, CornerRadius = dim(0, 4)})
    AddSubtleGradient(btn, 90)

    local h, s, v = Color3.toHSV(Cfg.Color)
    
    Items.DropFrame = fully:Create("Frame", { Parent = fully.Gui, Size = dim2(0, 150, 0, 0), BackgroundColor3 = themes.preset.element, Visible = false, ZIndex = 200, ClipsDescendants = true })
    fully:Themify(Items.DropFrame, "element", "BackgroundColor3")
    fully:Create("UICorner", { Parent = Items.DropFrame, CornerRadius = dim(0, 4) })

    Items.SVMap = fully:Create("TextButton", { Parent = Items.DropFrame, Position = dim2(0, 8, 0, 8), Size = dim2(1, -16, 1, -38), AutoButtonColor = false, Text = "", BackgroundColor3 = Color3.fromHSV(h, 1, 1), ZIndex = 201 })
    fully:Create("UICorner", { Parent = Items.SVMap, CornerRadius = dim(0, 3) })
    Items.SVImage = fully:Create("ImageLabel", { Parent = Items.SVMap, Size = dim2(1, 0, 1, 0), Image = "rbxassetid://4155801252", BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 202 })
    fully:Create("UICorner", { Parent = Items.SVImage, CornerRadius = dim(0, 3) })
    
    Items.SVKnob = fully:Create("Frame", { Parent = Items.SVMap, AnchorPoint = vec2(0.5, 0.5), Size = dim2(0, 4, 0, 4), BackgroundColor3 = rgb(255,255,255), ZIndex = 203 })
    fully:Create("UICorner", { Parent = Items.SVKnob, CornerRadius = dim(1, 0) })
    fully:Create("UIStroke", { Parent = Items.SVKnob, Color = rgb(0,0,0) })

    Items.HueBar = fully:Create("TextButton", { Parent = Items.DropFrame, Position = dim2(0, 8, 1, -22), Size = dim2(1, -16, 0, 14), AutoButtonColor = false, Text = "", BorderSizePixel = 0, BackgroundColor3 = rgb(255, 255, 255), ZIndex = 201 })
    fully:Create("UICorner", { Parent = Items.HueBar, CornerRadius = dim(0, 3) })
    fully:Create("UIGradient", { Parent = Items.HueBar, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, rgb(255,0,0)), ColorSequenceKeypoint.new(0.167, rgb(255,0,255)), ColorSequenceKeypoint.new(0.333, rgb(0,0,255)), ColorSequenceKeypoint.new(0.5, rgb(0,255,255)), ColorSequenceKeypoint.new(0.667, rgb(0,255,0)), ColorSequenceKeypoint.new(0.833, rgb(255,255,0)), ColorSequenceKeypoint.new(1, rgb(255,0,0))}) })
    
    Items.HueKnob = fully:Create("Frame", { Parent = Items.HueBar, AnchorPoint = vec2(0.5, 0.5), Size = dim2(0, 2, 1, 4), BackgroundColor3 = rgb(255,255,255), ZIndex = 203 })
    fully:Create("UIStroke", { Parent = Items.HueKnob, Color = rgb(0,0,0) })

    local Open = false
    local isTweening = false

    local function Toggle() 
        if isTweening then return end
        Open = not Open
        isTweening = true
        
        if Open then
            Items.DropFrame.Visible = true
            local tw = fully:Tween(Items.DropFrame, {Size = dim2(0, 150, 0, 140)}, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
            tw.Completed:Wait()
        else
            local tw = fully:Tween(Items.DropFrame, {Size = dim2(0, 150, 0, 0)}, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
            tw.Completed:Wait()
            Items.DropFrame.Visible = false
        end
        isTweening = false
    end
    btn.MouseButton1Click:Connect(Toggle)

    InputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if Open and not isTweening then
                local mx, my = input.Position.X, input.Position.Y
                local p0, s0 = Items.DropFrame.AbsolutePosition, dim2(0, 150, 0, 140)
                local p1, s1 = btn.AbsolutePosition, btn.AbsoluteSize
                if not (mx >= p0.X and mx <= p0.X + s0.X.Offset and my >= p0.Y and my <= p0.Y + s0.Y.Offset) and not (mx >= p1.X and mx <= p1.X + s1.X and my >= p1.Y and my <= p1.Y + s1.Y) then
                    Toggle()
                end
            end
        end
    end)

    function Cfg.set(color3)
        Cfg.Color = color3
        btn.BackgroundColor3 = color3
        if Cfg.Flag then Flags[Cfg.Flag] = color3 end
        Cfg.Callback(color3)
    end

    local svDragging, hueDragging = false, false
    Items.SVMap.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then svDragging = true end end)
    Items.HueBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then hueDragging = true end end)
    InputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then svDragging = false; hueDragging = false end end)

    InputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if svDragging then
                local x = math.clamp((input.Position.X - Items.SVMap.AbsolutePosition.X) / Items.SVMap.AbsoluteSize.X, 0, 1)
                local y = math.clamp((input.Position.Y - Items.SVMap.AbsolutePosition.Y) / Items.SVMap.AbsoluteSize.Y, 0, 1)
                s, v = x, 1 - y
                Items.SVKnob.Position = dim2(x, 0, y, 0)
                Cfg.set(Color3.fromHSV(h, s, v))
            elseif hueDragging then
                local x = math.clamp((input.Position.X - Items.HueBar.AbsolutePosition.X) / Items.HueBar.AbsoluteSize.X, 0, 1)
                h = 1 - x
                Items.HueKnob.Position = dim2(x, 0, 0.5, 0)
                Items.SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                Cfg.set(Color3.fromHSV(h, s, v))
            end
        end
    end)

    RunService.RenderStepped:Connect(function()
        if Open or isTweening then Items.DropFrame.Position = dim2(0, btn.AbsolutePosition.X - 150 + btn.AbsoluteSize.X, 0, btn.AbsolutePosition.Y + btn.AbsoluteSize.Y + 2) end
    end)
    
    Items.SVKnob.Position = dim2(s, 0, 1 - v, 0)
    Items.HueKnob.Position = dim2(1 - h, 0, 0.5, 0)
    
    Cfg.set(Cfg.Color)
    if Cfg.Flag then ConfigFlags[Cfg.Flag] = Cfg.set end
    return setmetatable(Cfg, fully)
end

function fully:Keybind(properties)
    local Cfg = { 
        Name = properties.Name or properties.name or "Keybind", 
        Flag = properties.Flag or properties.flag, 
        Default = properties.Default or properties.default or Enum.KeyCode.Unknown, 
        Callback = properties.Callback or properties.callback or function() end, 
        Items = {} 
    }
    local KeyBtn = fully:Create("TextButton", { Parent = self.Items.Title or self.Items.Button or self.Items.Container, AnchorPoint = vec2(1, 0.5), Position = dim2(1, -6, 0.5, 0), Size = dim2(0, 40, 0, 16), BackgroundColor3 = themes.preset.element, TextColor3 = themes.preset.subtext, Text = Keys[Cfg.Default] or "None", TextSize = CurrentSizeConfig.FontSize.SmallText, FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium) })
    fully:Themify(KeyBtn, "element", "BackgroundColor3")
    fully:Themify(KeyBtn, "subtext", "TextColor3")

    fully:Create("UICorner", {Parent = KeyBtn, CornerRadius = dim(0, 4)})
    AddSubtleGradient(KeyBtn, 90)

    local binding = false
    KeyBtn.MouseButton1Click:Connect(function() binding = true; KeyBtn.Text = "..." end)
    
    InputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed and not binding then return end
        if binding then
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                binding = false; Cfg.set(input.KeyCode)
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
                binding = false; Cfg.set(input.UserInputType)
            end
        elseif (input.KeyCode == Cfg.Default or input.UserInputType == Cfg.Default) and not binding then
            Cfg.Callback()
        end
    end)
    
    function Cfg.set(val)
        if not val or type(val) == "boolean" then return end
        Cfg.Default = val
        local keyName = Keys[val] or (typeof(val) == "EnumItem" and val.Name) or tostring(val)
        KeyBtn.Text = keyName
        if Cfg.Flag then Flags[Cfg.Flag] = val end
    end
    
    Cfg.set(Cfg.Default)
    if Cfg.Flag then ConfigFlags[Cfg.Flag] = Cfg.set end
    return setmetatable(Cfg, fully)
end

function Notifications:RefreshNotifications()
    local offset = 50
    for _, v in ipairs(Notifications.Notifs) do
        local ySize = math.max(v.AbsoluteSize.Y, 36)
        fully:Tween(v, {Position = dim_offset(20, offset)}, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
        offset += (ySize + 10)
    end
end

function Notifications:Create(properties)
    local Cfg = { 
        Name = properties.Name or properties.name or "Notification", 
        Lifetime = properties.LifeTime or properties.lifetime or 2.5, 
        Items = {} 
    }
    local Items = Cfg.Items
   
    Items.Outline = fully:Create("Frame", { Parent = fully.Gui, Position = dim_offset(-500, 50), Size = dim2(0, 300, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = themes.preset.background, BorderSizePixel = 0, ZIndex = 300, ClipsDescendants = true })
    fully:Themify(Items.Outline, "background", "BackgroundColor3")
    fully:Create("UICorner", { Parent = Items.Outline, CornerRadius = dim(0, 4) })
   
    Items.Name = fully:Create("TextLabel", {
        Parent = Items.Outline, Text = Cfg.Name, TextColor3 = themes.preset.text, FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium),
        BackgroundTransparency = 1, Size = dim2(1, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.None, TextWrapped = true, TextSize = CurrentSizeConfig.FontSize.Text, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 302
    })
    fully:Themify(Items.Name, "text", "TextColor3")
   
    fully:Create("UIPadding", { Parent = Items.Name, PaddingTop = dim(0, 10), PaddingBottom = dim(0, 10), PaddingRight = dim(0, 12), PaddingLeft = dim(0, 12) })
   
    Items.TimeBar = fully:Create("Frame", { Parent = Items.Outline, AnchorPoint = vec2(0, 1), Position = dim2(0, 0, 1, 0), Size = dim2(1, 0, 0, 2), BackgroundColor3 = themes.preset.accent, BorderSizePixel = 0, ZIndex = 303 })
    fully:Themify(Items.TimeBar, "accent", "BackgroundColor3")
    table.insert(Notifications.Notifs, Items.Outline)
   
    task.spawn(function()
        RunService.RenderStepped:Wait()
        Items.Outline.Position = dim_offset(-Items.Outline.AbsoluteSize.X - 20, 50)
        Notifications:RefreshNotifications()
        fully:Tween(Items.TimeBar, {Size = dim2(0, 0, 0, 2)}, TweenInfo.new(Cfg.Lifetime, Enum.EasingStyle.Linear))
        task.wait(Cfg.Lifetime)
        fully:Tween(Items.Outline, {Position = dim_offset(-Items.Outline.AbsoluteSize.X - 50, Items.Outline.Position.Y.Offset)}, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In))
        task.wait(0.4)
        local idx = table.find(Notifications.Notifs, Items.Outline)
        if idx then table.remove(Notifications.Notifs, idx) end
        Items.Outline:Destroy()
        task.wait(0.05)
        Notifications:RefreshNotifications()
    end)
end

function fully:GetConfig()
    local g = {}
    for Idx, Value in Flags do g[Idx] = Value end
    return HttpService:JSONEncode(g)
end

function fully:LoadConfig(JSON)
    local g = HttpService:JSONDecode(JSON)
    for Idx, Value in g do
        if Idx == "config_Name_list" or Idx == "config_Name_text" then continue end
        local Function = ConfigFlags[Idx]
        if Function then Function(Value) end
    end
end

local ConfigHolder
function fully:UpdateConfigList()
    if not ConfigHolder then return end
    local List = {}
    for _, file in listfiles(fully.Directory .. "/configs") do
        local Name = file:gsub(fully.Directory .. "/configs\\", ""):gsub(".cfg", ""):gsub(fully.Directory .. "\\configs\\", "")
        List[#List + 1] = Name
    end
    ConfigHolder.RefreshOptions(List)
end

function fully:Configs(window)
    local Text

    local Tab = window:Tab({ Name = "", Hidden = true })
    window.SettingsTabOpen = Tab.OpenTab

    local Section = Tab:Section({Name = "Configs", Side = "Left"})

    ConfigHolder = Section:Dropdown({
        Name = "Available Configs",
        Options = {},
        Callback = function(option) if Text then Text.set(option) end end,
        Flag = "config_Name_list"
    })

    fully:UpdateConfigList()

    Text = Section:Textbox({ Name = "Config Name:", Flag = "config_Name_text", Default = "" })

    Section:Button({
        Name = "Save Config",
        Callback = function()
            if Flags["config_Name_text"] == "" then return end
            writefile(fully.Directory .. "/configs/" .. Flags["config_Name_text"] .. ".cfg", fully:GetConfig())
            fully:UpdateConfigList()
            Notifications:Create({Name = "Saved Config: " .. Flags["config_Name_text"]})
        end
    })

    Section:Button({
        Name = "Load Config",
        Callback = function()
            if Flags["config_Name_text"] == "" then return end
            fully:LoadConfig(readfile(fully.Directory .. "/configs/" .. Flags["config_Name_text"] .. ".cfg"))
            fully:UpdateConfigList()
            Notifications:Create({Name = "Loaded Config: " .. Flags["config_Name_text"]})
        end
    })

    Section:Button({
        Name = "Delete Config",
        Callback = function()
            if Flags["config_Name_text"] == "" then return end
            delfile(fully.Directory .. "/configs/" .. Flags["config_Name_text"] .. ".cfg")
            fully:UpdateConfigList()
            Notifications:Create({Name = "Deleted Config: " .. Flags["config_Name_text"]})
        end
    })

    local SectionRight = Tab:Section({Name = "Settings & Themes", Side = "Right"})

    SectionRight:Toggle({
        Name = "Streamer Mode",
        Flag = "fully_StreamerMode",
        Callback = function(state)
            if state then
                window.Items.Username.Text = "Bypass.cc User"
                window.Items.Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=1&w=48&h=48"
            else
                window.Items.Username.Text = lp.Name
                window.Items.Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. lp.UserId .. "&w=48&h=48"
            end
        end
    })

    SectionRight:Label({Name = "Accent Color"}):Colorpicker({ Callback = function(color3) fully:RefreshTheme("accent", color3) end, Color = themes.preset.accent })
    SectionRight:Label({Name = "Glow Color"}):Colorpicker({ Callback = function(color3) fully:RefreshTheme("glow", color3) end, Color = themes.preset.glow })
    SectionRight:Label({Name = "Background Color"}):Colorpicker({ Callback = function(color3) fully:RefreshTheme("background", color3) end, Color = themes.preset.background })
    SectionRight:Label({Name = "Section Color"}):Colorpicker({ Callback = function(color3) fully:RefreshTheme("section", color3) end, Color = themes.preset.section })
    SectionRight:Label({Name = "Element Color"}):Colorpicker({ Callback = function(color3) fully:RefreshTheme("element", color3) end, Color = themes.preset.element })
    SectionRight:Label({Name = "Text Color"}):Colorpicker({ Callback = function(color3) fully:RefreshTheme("text", color3) end, Color = themes.preset.text })

    if DeviceType ~= "Phone" then
        window.Tweening = true
        SectionRight:Label({Name = "Menu Bind"}):Keybind({
            Name = "Menu Bind",
            Callback = function(bool) if window.Tweening then return end window.ToggleMenu(bool) end,
            Default = Enum.KeyCode.RightShift
        })
        task.delay(1, function() window.Tweening = false end)
    end

    local ServerSection = Tab:Section({Name = "Server", Side = "Right"})

    ServerSection:Button({ Name = "Rejoin Server", Callback = function() TeleportService:Teleport(game.PlaceId, Players.LocalPlayer) end })

    ServerSection:Button({
        Name = "Server Hop",
        Callback = function()
            local servers, cursor = {}, ""
            repeat
                local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")
                local data = HttpService:JSONDecode(game:HttpGet(url))
                for _, server in ipairs(data.data) do
                    if server.id ~= game.JobId and server.playing < server.maxPlayers then table.insert(servers, server) end
                end
                cursor = data.nextPageCursor
            until not cursor or #servers > 0
            if #servers > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)].id, Players.LocalPlayer) end
        end
    })
end

return fully
            
