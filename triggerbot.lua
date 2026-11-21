-- ============================================================
--  ██████  ██ ███    ███ ██████  ██      ██    ██  ██████  ██████  ██████  
-- ██       ██ ████  ████ ██   ██ ██       ██  ██  ██       ██   ██ ██   ██ 
-- ███████  ██ ██ ████ ██ ██████  ██        ████   ██   ███ ██   ██ ██   ██ 
--      ██  ██ ██  ██  ██ ██      ██         ██    ██    ██ ██   ██ ██   ██ 
-- ███████  ██ ██      ██ ██      ███████    ██     ██████  ██████  ██████  
-- ============================================================
--  Author   : Simplygodd
--  Version  : v1.2
--  Executor : Xeno  |  Bootstrap : Voidstrap  |  Platform : PC
--  Games    : Rivals, Arsenal, Duels, Universal
-- ============================================================

-- ============================================================
--  SERVICES
-- ============================================================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Camera            = workspace.CurrentCamera
local lp                = Players.LocalPlayer
local mouse             = lp:GetMouse()

-- ============================================================
--  META
-- ============================================================
local META = {
    name      = "SimplyGodd",
    version   = "v1.2",
    author    = "Simplygodd",
    executor  = "Xeno / Voidstrap",
    discord   = "discord.gg/simplygodd",   -- pon el tuyo
}

-- ============================================================
--  CONFIG  — edita aquí, todo en un solo lugar
-- ============================================================
local CFG = {
    -- [ TRIGGERBOT ]
    TBot_Enabled     = true,
    TBot_Key         = Enum.KeyCode.Q,     -- hold para activar
    TBot_Delay       = 0.08,              -- segundos antes de disparar
    TBot_AutoFire    = true,

    -- [ HITBOX ]
    HB_Enabled       = true,
    HB_Multiplier    = 3,                 -- tamaño × multiplicador
    HB_Visible       = false,             -- ver hitbox expandida
    HB_Color         = Color3.fromRGB(255, 40, 40),
    HB_Transparency  = 0.55,

    -- [ KEYBINDS ]
    Key_ToggleTBot   = Enum.KeyCode.F1,
    Key_ToggleHB     = Enum.KeyCode.F2,
    Key_ToggleVis    = Enum.KeyCode.F3,
    Key_ToggleGUI    = Enum.KeyCode.RightControl,

    -- [ GUI ]
    GUI_AccentColor  = Color3.fromRGB(220, 50, 50),   -- rojo signature
    GUI_BG           = Color3.fromRGB(12, 12, 12),
    GUI_Panel        = Color3.fromRGB(20, 20, 20),
    GUI_Text         = Color3.fromRGB(210, 210, 210),
    GUI_Muted        = Color3.fromRGB(90, 90, 90),
}

-- ============================================================
--  STATE
-- ============================================================
local State = {
    lastFire  = 0,
    hbParts   = {},
    ticking   = true,
    guiOpen   = true,
}

-- ============================================================
--  BANNER  (output de Xeno)
-- ============================================================
local function banner()
    print("\n")
    print("  ╔══════════════════════════════════════╗")
    print(string.format("  ║  %s  %-6s  │  %s", META.name, META.version, META.executor))
    print("  ║  by " .. META.author)
    print("  ╠══════════════════════════════════════╣")
    print("  ║  F1  → TBot   F2  → Hitbox")
    print("  ║  F3  → HB Vis  RCtrl → GUI")
    print("  ║  Hold Q → fire when on target")
    print("  ╚══════════════════════════════════════╝\n")
end
banner()

-- ============================================================
--  UTILS
-- ============================================================
local function isAlive(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function isEnemy(plr)
    if plr == lp then return false end
    -- team check universal: extiende aquí si el juego usa Teams
    return true
end

local function getCharOwner(part)
    if not part then return nil end
    local model = part:FindFirstAncestorOfClass("Model")
    if not model then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == model then return p end
    end
    return nil
end

-- ============================================================
--  HITBOX EXPANDER
-- ============================================================
local function clearHitboxes()
    for _, d in ipairs(State.hbParts) do
        if d.box and d.box.Parent then d.box:Destroy() end
    end
    State.hbParts = {}
end

local function buildBox(part)
    local box          = Instance.new("Part")
    box.Name           = "__SG_HB"
    box.Anchored       = false
    box.CanCollide     = false
    box.CanTouch       = false
    box.CanQuery       = true
    box.Massless       = true
    box.CastShadow     = false
    box.Material       = Enum.Material.SmoothPlastic
    box.Color          = CFG.HB_Color
    box.Transparency   = CFG.HB_Visible and CFG.HB_Transparency or 1
    box.Size           = part.Size * CFG.HB_Multiplier
    box.CFrame         = part.CFrame

    local w     = Instance.new("WeldConstraint")
    w.Part0     = part
    w.Part1     = box
    w.Parent    = box

    box.Parent  = part.Parent or workspace
    return box
end

local function applyHitboxes()
    clearHitboxes()
    if not CFG.HB_Enabled then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if isEnemy(plr) then
            local char = plr.Character
            if char and isAlive(char) then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "__SG_HB" then
                        local box = buildBox(part)
                        table.insert(State.hbParts, { part = part, box = box })
                    end
                end
            end
        end
    end
end

-- auto-refresh en spawn
local function hookPlayer(plr)
    if isEnemy(plr) then
        plr.CharacterAdded:Connect(function()
            task.wait(1)
            applyHitboxes()
        end)
        if plr.Character then
            task.spawn(function() task.wait(0.5) applyHitboxes() end)
        end
    end
end

for _, p in ipairs(Players:GetPlayers()) do hookPlayer(p) end
Players.PlayerAdded:Connect(hookPlayer)
Players.PlayerRemoving:Connect(function() task.wait(0.1) applyHitboxes() end)
applyHitboxes()

-- ============================================================
--  TRIGGERBOT
-- ============================================================
local function getTarget()
    local unitRay = Camera:ScreenPointToRay(mouse.X, mouse.Y)
    local ignore  = { lp.Character or Instance.new("Folder") }
    local hit     = workspace:FindPartOnRayWithIgnoreList(
        Ray.new(unitRay.Origin, unitRay.Direction * 1000), ignore, false, false
    )
    return hit
end

local function doClick()
    if mouse1click then mouse1click()
    elseif click    then click() end
end

RunService.Heartbeat:Connect(function()
    if not State.ticking        then return end
    if not CFG.TBot_Enabled     then return end
    if not UserInputService:IsKeyDown(CFG.TBot_Key) then return end
    if tick() - State.lastFire < CFG.TBot_Delay     then return end

    local part  = getTarget()
    local owner = getCharOwner(part)
    if owner and isEnemy(owner) and isAlive(owner.Character) then
        State.lastFire = tick()
        if CFG.TBot_AutoFire then doClick() end
    end
end)

-- ============================================================
--  GUI — pro, draggable, animada
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name           = "SimplyGodd_" .. META.version
gui.ResetOnSpawn   = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true

pcall(function()
    gui.Parent = gethui and gethui() or game:GetService("CoreGui")
end)
if not gui.Parent then gui.Parent = lp:WaitForChild("PlayerGui") end

-- contenedor principal
local main = Instance.new("Frame")
main.Name              = "Main"
main.Size              = UDim2.new(0, 240, 0, 0)   -- altura crece con lista
main.Position          = UDim2.new(0, 24, 0.42, 0)
main.BackgroundColor3  = CFG.GUI_BG
main.BorderSizePixel   = 0
main.Active            = true
main.Draggable         = true
main.ClipsDescendants  = true
main.Parent            = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

-- barra de acento superior
local accent = Instance.new("Frame")
accent.Size             = UDim2.new(1, 0, 0, 3)
accent.BackgroundColor3 = CFG.GUI_AccentColor
accent.BorderSizePixel  = 0
accent.Parent           = main
Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 10)

-- header
local header = Instance.new("Frame")
header.Size             = UDim2.new(1, 0, 0, 36)
header.Position         = UDim2.new(0, 0, 0, 3)
header.BackgroundColor3 = CFG.GUI_Panel
header.BorderSizePixel  = 0
header.Parent           = main

local titleLbl = Instance.new("TextLabel")
titleLbl.Size            = UDim2.new(1, -10, 1, 0)
titleLbl.Position        = UDim2.new(0, 10, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text            = META.name .. "  " .. META.version
titleLbl.TextColor3      = CFG.GUI_Text
titleLbl.Font            = Enum.Font.GothamBold
titleLbl.TextSize        = 13
titleLbl.TextXAlignment  = Enum.TextXAlignment.Left
titleLbl.Parent          = header

local subLbl = Instance.new("TextLabel")
subLbl.Size              = UDim2.new(1, -10, 0, 14)
subLbl.Position          = UDim2.new(0, 10, 1, -1)
subLbl.BackgroundTransparency = 1
subLbl.Text              = "by " .. META.author .. "  •  " .. META.executor
subLbl.TextColor3        = CFG.GUI_Muted
subLbl.Font              = Enum.Font.Gotham
subLbl.TextSize          = 9
subLbl.TextXAlignment    = Enum.TextXAlignment.Left
subLbl.Parent            = header

-- lista de toggles
local list = Instance.new("Frame")
list.Name              = "List"
list.Size              = UDim2.new(1, 0, 0, 0)
list.Position          = UDim2.new(0, 0, 0, 39)
list.BackgroundTransparency = 1
list.Parent            = main

local layout = Instance.new("UIListLayout")
layout.Padding         = UDim.new(0, 1)
layout.FillDirection   = Enum.FillDirection.Vertical
layout.Parent          = list

-- helper: fila de toggle
local function makeToggle(labelText, getState, onToggle, keybind)
    local row = Instance.new("Frame")
    row.Size              = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3  = CFG.GUI_Panel
    row.BorderSizePixel   = 0
    row.Parent            = list

    local lbl = Instance.new("TextLabel")
    lbl.Size             = UDim2.new(0.6, 0, 1, 0)
    lbl.Position         = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text             = labelText
    lbl.TextColor3       = CFG.GUI_Text
    lbl.Font             = Enum.Font.GothamSemibold
    lbl.TextSize         = 11
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.Parent           = row

    local kb = Instance.new("TextLabel")
    kb.Size              = UDim2.new(0, 28, 0, 16)
    kb.Position          = UDim2.new(1, -68, 0.5, -8)
    kb.BackgroundColor3  = Color3.fromRGB(30, 30, 30)
    kb.BorderSizePixel   = 0
    kb.Text              = keybind
    kb.TextColor3        = CFG.GUI_Muted
    kb.Font              = Enum.Font.Gotham
    kb.TextSize          = 9
    kb.TextXAlignment    = Enum.TextXAlignment.Center
    kb.Parent            = row
    Instance.new("UICorner", kb).CornerRadius = UDim.new(0, 4)

    -- pill toggle
    local pill = Instance.new("Frame")
    pill.Size            = UDim2.new(0, 34, 0, 16)
    pill.Position        = UDim2.new(1, -44, 0.5, -8)
    pill.BorderSizePixel = 0
    pill.Parent          = row
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

    local dot = Instance.new("Frame")
    dot.Size             = UDim2.new(0, 12, 0, 12)
    dot.Position         = UDim2.new(0, 2, 0.5, -6)
    dot.BorderSizePixel  = 0
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.Parent           = pill
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local function refresh()
        local on = getState()
        local goal = on and CFG.GUI_AccentColor or Color3.fromRGB(50, 50, 50)
        TweenService:Create(pill, TweenInfo.new(0.15), { BackgroundColor3 = goal }):Play()
        TweenService:Create(dot,  TweenInfo.new(0.15), {
            Position = on
                and UDim2.new(1, -14, 0.5, -6)
                or  UDim2.new(0, 2,   0.5, -6)
        }):Play()
    end
    refresh()

    local btn = Instance.new("TextButton")
    btn.Size               = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text               = ""
    btn.Parent             = row
    btn.MouseButton1Click:Connect(function()
        onToggle()
        refresh()
    end)

    return refresh
end

local refreshTBot = makeToggle(
    "Triggerbot  (hold Q)", function() return CFG.TBot_Enabled end,
    function()
        CFG.TBot_Enabled = not CFG.TBot_Enabled
        print("[SimplyGodd] TBot:", CFG.TBot_Enabled and "ON" or "OFF")
    end, "F1"
)

local refreshHB = makeToggle(
    "Hitbox ×" .. CFG.HB_Multiplier, function() return CFG.HB_Enabled end,
    function()
        CFG.HB_Enabled = not CFG.HB_Enabled
        if CFG.HB_Enabled then applyHitboxes() else clearHitboxes() end
        print("[SimplyGodd] Hitbox:", CFG.HB_Enabled and "ON" or "OFF")
    end, "F2"
)

local refreshVis = makeToggle(
    "HB Visual (rojo)", function() return CFG.HB_Visible end,
    function()
        CFG.HB_Visible = not CFG.HB_Visible
        applyHitboxes()
        print("[SimplyGodd] HB Vis:", CFG.HB_Visible and "ON" or "OFF")
    end, "F3"
)

-- separador + watermark
local sep = Instance.new("Frame")
sep.Size             = UDim2.new(1, -20, 0, 1)
sep.Position         = UDim2.new(0, 10, 0, 0)
sep.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
sep.BorderSizePixel  = 0
sep.Parent           = list

local wm = Instance.new("Frame")
wm.Size              = UDim2.new(1, 0, 0, 24)
wm.BackgroundTransparency = 1
wm.Parent            = list

local wmLbl = Instance.new("TextLabel")
wmLbl.Size           = UDim2.new(1, 0, 1, 0)
wmLbl.BackgroundTransparency = 1
wmLbl.Text           = "by Simplygodd  •  " .. META.version
wmLbl.TextColor3     = CFG.GUI_Muted
wmLbl.Font           = Enum.Font.Gotham
wmLbl.TextSize       = 9
wmLbl.TextXAlignment = Enum.TextXAlignment.Center
wmLbl.Parent         = wm

-- altura dinámica
task.wait()
main.Size = UDim2.new(0, 240, 0, 39 + layout.AbsoluteContentSize.Y + 4)

-- ============================================================
--  KEYBINDS globales
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == CFG.Key_ToggleTBot then
        CFG.TBot_Enabled = not CFG.TBot_Enabled
        refreshTBot()
        print("[SimplyGodd] TBot:", CFG.TBot_Enabled and "ON" or "OFF")

    elseif input.KeyCode == CFG.Key_ToggleHB then
        CFG.HB_Enabled = not CFG.HB_Enabled
        if CFG.HB_Enabled then applyHitboxes() else clearHitboxes() end
        refreshHB()
        print("[SimplyGodd] Hitbox:", CFG.HB_Enabled and "ON" or "OFF")

    elseif input.KeyCode == CFG.Key_ToggleVis then
        CFG.HB_Visible = not CFG.HB_Visible
        applyHitboxes()
        refreshVis()
        print("[SimplyGodd] HB Vis:", CFG.HB_Visible and "ON" or "OFF")

    elseif input.KeyCode == CFG.Key_ToggleGUI then
        State.guiOpen = not State.guiOpen
        main.Visible  = State.guiOpen
    end
end)

-- ============================================================
print(string.format("[%s %s] loaded clean — RCtrl toggle GUI", META.name, META.version))
-- ============================================================