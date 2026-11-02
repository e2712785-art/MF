--// MHUB - Básico (ESP, Fly, Noclip) - Delta Executor
--// Interfaz limpia y funciones universales

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--// Obtener el padre de la GUI de forma segura para Delta
local function getGuiParent()
    local ok, result = pcall(function() return gethui() end)
    if ok and result then return result end
    local ok2, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and coreGui then return coreGui end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local guiParent = getGuiParent()

--// Destruir versión anterior si existe
for _, child in ipairs(guiParent:GetChildren()) do
    if child.Name == "MHUB_Basic" then child:Destroy() end
end

--// Crear ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MHUB_Basic"
screenGui.ResetOnSpawn = false
screenGui.Parent = guiParent

--// Botón flotante (Móvil)
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(1, -70, 0, 20)
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Text = "MHUB"
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 12
toggleButton.Parent = screenGui
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(1, 0)

--// Ventana Principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 260, 0, 280)
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -140)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

--// Barra Superior (Para arrastrar)
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
topBar.Parent = mainFrame
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "MHUB | Básico"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

--// Botón Cerrar
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -32, 0, 7)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = topBar
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 6)

--// Contenedor de Botones
local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, -20, 1, -55)
contentFrame.Position = UDim2.new(0, 10, 0, 45)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 10)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = contentFrame

--// Funciones de Arrastre
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then updateDrag(input) end
end)

--// ==========================================
--// FUNCIONES: ESP, FLY, NOCLIP
--// ==========================================

-- 1. ESP (Resaltar Jugadores)
local espEnabled = false
local espHighlights = {}

local function toggleESP()
    espEnabled = not espEnabled
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            if espEnabled then
                local char = player.Character
                if char then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "MHUB_ESP"
                    highlight.Adornee = char
                    highlight.FillColor = Color3.fromRGB(255, 0, 255) -- Morado
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.Parent = char
                    espHighlights[player] = highlight
                end
            else
                if espHighlights[player] then
                    espHighlights[player]:Destroy()
                    espHighlights[player] = nil
                end
            end
        end
    end
end

-- 2. Fly (Volar)
local flyEnabled = false
local flySpeed = 50
local flyConnection
local flyBodyVelocity

local function toggleFly()
    flyEnabled = not flyEnabled
    local char = Players.LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if flyEnabled and hrp and hum then
        hum.PlatformStand = true
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.Name = "MHUB_Fly"
        flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyBodyVelocity.Parent = hrp
        
        flyConnection = RunService.RenderStepped:Connect(function()
            local camera = workspace.CurrentCamera
            local moveDir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
            
            if moveDir.Magnitude > 0 then
                flyBodyVelocity.Velocity = moveDir.Unit * flySpeed
            else
                flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        end)
    else
        if flyConnection then flyConnection:Disconnect() end
        if flyBodyVelocity then flyBodyVelocity:Destroy() end
        if hum then hum.PlatformStand = false end
    end
end

-- 3. Noclip (Atravesar paredes)
local noclipEnabled = false
RunService.Stepped:Connect(function()
    if noclipEnabled then
        local char = Players.LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

--// ==========================================
--// CREAR BOTONES
--// ==========================================

local function createToggleButton(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    btn.Text = name .. " [OFF]"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = contentFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(function()
        local state = callback()
        if state then
            btn.Text = name .. " [ON]"
            btn.TextColor3 = Color3.fromRGB(100, 255, 100)
            btn.BackgroundColor3 = Color3.fromRGB(30, 60, 30)
        else
            btn.Text = name .. " [OFF]"
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        end
    end)
end

createToggleButton("ESP (Ver Jugadores)", function()
    toggleESP()
    return espEnabled
end)

createToggleButton("Fly (Volar)", function()
    toggleFly()
    return flyEnabled
end)

createToggleButton("Noclip (Atravesar)", function()
    noclipEnabled = not noclipEnabled
    return noclipEnabled
end)

--// Abrir/Cerrar Interfaz
local function toggleUI()
    mainFrame.Visible = not mainFrame.Visible
end
toggleButton.MouseButton1Click:Connect(toggleUI)
closeButton.MouseButton1Click:Connect(toggleUI)

print("MHUB Básico cargado. ESP, Fly y Noclip listos.")
