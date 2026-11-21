-- triggerbot.lua
-- ============================================================
-- ██████ ██ ███ ███ ██████ ██ ██ ██ ██████ ██████ ██████
-- ██ ██ ████ ████ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██
-- ███████ ██ ██ ████ ██ ██████ ██ ████ ██ ███ ██ ██ ██ ██
-- ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██
-- ███████ ██ ██ ██ ██ ███████ ██ ██████ ██████ ██████
-- ============================================================
-- Author  : Simplygodd
-- Version : v1.3
-- Executor: Xeno | Bootstrap: Voidstrap | Platform: PC
-- Games   : Rivals, Arsenal, Duels, Universal
-- Discord : discord.gg/8xav7hPyF
-- ============================================================

-- ============================================================
-- SERVICES
-- ============================================================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local Camera           = workspace.CurrentCamera
local lp               = Players.LocalPlayer
local mouse            = lp:GetMouse()

-- ============================================================
-- META
-- ============================================================
local META = {
    name     = "SimplyGodd",
    version  = "v1.3",
    author   = "Simplygodd",
    executor = "Xeno / Voidstrap",
    discord  = "discord.gg/8xav7hPyF",
}

-- ============================================================
-- CONFIG DEFAULT — valores base, se sobreescriben con el save
-- ============================================================
local CFG = {
    -- [ TRIGGERBOT ]
    TBot_Enabled  = true,
    TBot_Key      = Enum.KeyCode.Q,
    TBot_Delay    = 0.08,
    TBot_AutoFire = true,

    -- [ HITBOX ]
    HB_Enabled      = true,
    HB_Multiplier   = 3,
    HB_Visible      = false,
    HB_Color        = Color3.fromRGB(255, 40, 40),
    HB_Transparency = 0.55,

    -- [ KEYBINDS ]
    Key_ToggleTBot = Enum.KeyCode.F1,
    Key_ToggleHB   = Enum.KeyCode.F2,
    Key_ToggleVis  = Enum.KeyCode.F3,
    Key_ToggleGUI  = Enum.KeyCode.RightControl,

    -- [ GUI ]
    GUI_AccentColor = Color3.fromRGB(220, 50, 50),
    GUI_BG          = Color3.fromRGB(12, 12, 12),
    GUI_Panel       = Color3.fromRGB(20, 20, 20),
    GUI_Text        = Color3.fromRGB(210, 210, 210),
    GUI_Muted       = Color3.fromRGB(90, 90, 90),
}

-- defaults para reset
local DEFAULT_BINDS = {
    TBot_Key       = "Q",
    Key_ToggleTBot = "F1",
    Key_ToggleHB   = "F2",
    Key_ToggleVis  = "F3",
    Key_ToggleGUI  = "RightControl",
}

-- ============================================================
-- STATE
-- ============================================================
local State = {
    lastFire    = 0,
    hbParts     = {},
    ticking     = true,
    guiOpen     = true,
    activeTab   = "main",   -- "main" | "binds"
}

local BindState = {
    listening   = false,
    activeSlot  = nil,
    labels      = {},
}

-- burst protection
local BURST_MAX_CPS = 8
local BURST_WINDOW  = {}

-- raycast params (una sola instancia)
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

-- ============================================================
-- CONFIG PERSISTENTE — writefile/readfile (Xeno/Synapse/Fluxus)
-- ============================================================
local CONFIG_FILE = "simplygodd_config.json"

local function saveConfig()
    if not writefile then return end
    local data = {
        TBot_Key       = CFG.TBot_Key.Name,
        Key_ToggleTBot = CFG.Key_ToggleTBot.Name,
        Key_ToggleHB   = CFG.Key_ToggleHB.Name,
        Key_ToggleVis  = CFG.Key_ToggleVis.Name,
        Key_ToggleGUI  = CFG.Key_ToggleGUI.Name,
        TBot_Delay     = CFG.TBot_Delay,
        HB_Multiplier  = CFG.HB_Multiplier,
        TBot_Enabled   = CFG.TBot_Enabled,
        HB_Enabled     = CFG.HB_Enabled,
        HB_Visible     = CFG.HB_Visible,
    }
    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode(data))
    end)
end

local function loadConfig()
    if not readfile or not isfile then return end
    if not isfile(CONFIG_FILE) then return end
    local ok, raw = pcall(readfile, CONFIG_FILE)
    if not ok or not raw then return end
    local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not ok2 or type(data) ~= "table" then return end

    local function toKey(name)
        if not name then return nil end
        local ok3, k = pcall(function() return Enum.KeyCode[name] end)
        return (ok3 and k) or nil
    end

    CFG.TBot_Key       = toKey(data.TBot_Key)       or CFG.TBot_Key
    CFG.Key_ToggleTBot = toKey(data.Key_ToggleTBot) or CFG.Key_ToggleTBot
    CFG.Key_ToggleHB   = toKey(data.Key_ToggleHB)   or CFG.Key_ToggleHB
    CFG.Key_ToggleVis  = toKey(data.Key_ToggleVis)  or CFG.Key_ToggleVis
    CFG.Key_ToggleGUI  = toKey(data.Key_ToggleGUI)  or CFG.Key_ToggleGUI

    if type(data.TBot_Delay)    == "number" then CFG.TBot_Delay    = data.TBot_Delay    end
    if type(data.HB_Multiplier) == "number" then CFG.HB_Multiplier = data.HB_Multiplier end
    if type(data.TBot_Enabled)  == "boolean" then CFG.TBot_Enabled = data.TBot_Enabled  end
    if type(data.HB_Enabled)    == "boolean" then CFG.HB_Enabled   = data.HB_Enabled    end
    if type(data.HB_Visible)    == "boolean" then CFG.HB_Visible   = data.HB_Visible    end
end

loadConfig()

-- ============================================================
-- BANNER
-- ============================================================
local function banner()
    print("\n")
    print(" ╔══════════════════════════════════════╗")
    print(string.format(" ║  %s %-6s │ %s", META.name, META.version, META.executor))
    print(" ║  by " .. META.author .. " • " .. META.discord)
    print(" ╠══════════════════════════════════════╣")
    print(" ║  F1 → TBot      F2 → Hitbox")
    print(" ║  F3 → HB Vis    RCtrl → GUI")
    print(" ║  Hold Q → fire  Binds: tab en GUI")
    print(" ╚══════════════════════════════════════╝\n")
end
banner()

-- ============================================================
-- UTILS
-- ============================================================
local function isAlive(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function isEnemy(plr)
    if plr == lp then return false end
    -- descomenta si el juego usa Teams:
    -- if lp.Team and plr.Team and lp.Team == plr.Team then return false end
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

local function keyName(enumKey)
    local s = tostring(enumKey)
    return s:match("KeyCode%.(.+)") or s
end

-- ============================================================
-- ANTICHEAT — humanización
-- ============================================================
local function humanDelay()
    local jitter = (math.random() - 0.5) * 0.04
    return math.max(0.03, CFG.TBot_Delay + jitter)
end

local function canFire()
    local now    = tick()
    local cutoff = now - 1
    local fresh  = {}
    for _, t in ipairs(BURST_WINDOW) do
        if t > cutoff then table.insert(fresh, t) end
    end
    BURST_WINDOW = fresh
    if #BURST_WINDOW >= BURST_MAX_CPS then return false end
    table.insert(BURST_WINDOW, now)
    return true
end

local function humanClick()
    task.spawn(function()
        if mouse1press   then mouse1press()   end
        task.wait(0.04 + math.random() * 0.05)
        if mouse1release then
            mouse1release()
        elseif mouse1click then
            mouse1click()
        else
            pcall(function()
                local vim = game:GetService("VirtualInputManager")
                vim:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true,  game, 0)
                task.wait(0.03)
                vim:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 0)
            end)
        end
    end)
end

-- ============================================================
-- HITBOX EXPANDER
-- ============================================================
local function clearHitboxes()
    for _, d in ipairs(State.hbParts) do
        if d.conn then d.conn:Disconnect() end
        if d.box and d.box.Parent then d.box:Destroy() end
    end
    State.hbParts = {}
end

local function buildBox(part)
    local box = Instance.new("Part")
    box.Name         = "__SG_HB"
    box.Anchored     = false
    box.CanCollide   = false
    box.CanTouch     = false
    box.CanQuery     = true
    box.Massless     = true
    box.CastShadow   = false
    box.Material     = Enum.Material.SmoothPlastic
    box.Color        = CFG.HB_Color
    box.Transparency = CFG.HB_Visible and CFG.HB_Transparency or 1
    box.Size         = part.Size * CFG.HB_Multiplier
    box.CFrame       = part.CFrame
    box.Parent       = workspace

    local w    = Instance.new("WeldConstraint")
    w.Part0    = part
    w.Part1    = box
    w.Parent   = box

    -- lock al cliente para que el server no lo vea
    pcall(function() box:SetNetworkOwner(nil) end)

    local conn = RunService.RenderStepped:Connect(function()
        if not box.Parent or not part.Parent then return end
        box.Transparency = CFG.HB_Visible and CFG.HB_Transparency or 1
    end)

    return box, conn
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
                        local box, conn = buildBox(part)
                        table.insert(State.hbParts, { part = part, box = box, conn = conn })
                    end
                end
            end
        end
    end
end

local function hookPlayer(plr)
    if not isEnemy(plr) then return end
    plr.CharacterAdded:Connect(function()
        task.wait(1)
        applyHitboxes()
    end)
    if plr.Character then
        task.spawn(function() task.wait(0.5) applyHitboxes() end)
    end
end

for _, p in ipairs(Players:GetPlayers()) do hookPlayer(p) end
Players.PlayerAdded:Connect(hookPlayer)
Players.PlayerRemoving:Connect(function() task.wait(0.1) applyHitboxes() end)
applyHitboxes()

-- ============================================================
-- TRIGGERBOT — raycast con noise AC
-- ============================================================
local OFFSET_RANGE = 2

local function getTarget()
    rayParams.FilterDescendantsInstances = lp.Character
        and { lp.Character } or {}
    local ox = (math.random() - 0.5) * OFFSET_RANGE
    local oy = (math.random() - 0.5) * OFFSET_RANGE
    local unitRay = Camera:ScreenPointToRay(mouse.X + ox, mouse.Y + oy)
    local result  = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, rayParams)
    return result and result.Instance or nil
end

RunService.Heartbeat:Connect(function()
    if not State.ticking then return end
    if not CFG.TBot_Enabled then return end
    if not UserInputService:IsKeyDown(CFG.TBot_Key) then return end
    if tick() - State.lastFire < humanDelay() then return end

    local part  = getTarget()
    local owner = getCharOwner(part)

    if owner and isEnemy(owner) and isAlive(owner.Character) then
        if canFire() then
            State.lastFire = tick()
            if CFG.TBot_AutoFire then humanClick() end
        end
    end
end)

-- ============================================================
-- GUI
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name           = "SimplyGodd_" .. META.version
gui.ResetOnSpawn   = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true

pcall(function()
    gui.Parent = gethui and gethui() or game:GetService("CoreGui")
end)
if not gui.Parent then
    gui.Parent = lp:WaitForChild("PlayerGui")
end

-- ventana principal
local main = Instance.new("Frame")
main.Name             = "Main"
main.Size             = UDim2.new(0, 250, 0, 300)
main.Position         = UDim2.new(0, 24, 0.38, 0)
main.BackgroundColor3 = CFG.GUI_BG
main.BorderSizePixel  = 0
main.Active           = true
main.Draggable        = true
main.ClipsDescendants = true
main.Parent           = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

-- barra acento
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
titleLbl.Size               = UDim2.new(1, -10, 0, 18)
titleLbl.Position           = UDim2.new(0, 10, 0, 4)
titleLbl.BackgroundTransparency = 1
titleLbl.Text               = META.name .. " " .. META.version
titleLbl.TextColor3         = CFG.GUI_Text
titleLbl.Font               = Enum.Font.GothamBold
titleLbl.TextSize           = 13
titleLbl.TextXAlignment     = Enum.TextXAlignment.Left
titleLbl.Parent             = header

local subLbl = Instance.new("TextLabel")
subLbl.Size               = UDim2.new(1, -10, 0, 12)
subLbl.Position           = UDim2.new(0, 10, 0, 22)
subLbl.BackgroundTransparency = 1
subLbl.Text               = META.discord
subLbl.TextColor3         = CFG.GUI_AccentColor
subLbl.Font               = Enum.Font.Gotham
subLbl.TextSize           = 9
subLbl.TextXAlignment     = Enum.TextXAlignment.Left
subLbl.Parent             = header

-- ============================================================
-- TAB BAR — Main | Binds
-- ============================================================
local tabBar = Instance.new("Frame")
tabBar.Size             = UDim2.new(1, 0, 0, 28)
tabBar.Position         = UDim2.new(0, 0, 0, 39)
tabBar.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
tabBar.BorderSizePixel  = 0
tabBar.Parent           = main

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding       = UDim.new(0, 1)
tabLayout.Parent        = tabBar

-- contenido de tabs
local tabContent = Instance.new("Frame")
tabContent.Name               = "TabContent"
tabContent.Size               = UDim2.new(1, 0, 1, -67)
tabContent.Position           = UDim2.new(0, 0, 0, 67)
tabContent.BackgroundTransparency = 1
tabContent.BorderSizePixel    = 0
tabContent.ClipsDescendants   = true
tabContent.Parent             = main

-- helper tab button
local function makeTabBtn(label, tabKey)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(0.5, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    btn.BorderSizePixel  = 0
    btn.Text             = label
    btn.TextColor3       = CFG.GUI_Muted
    btn.Font             = Enum.Font.GothamSemibold
    btn.TextSize         = 11
    btn.Parent           = tabBar

    local underline = Instance.new("Frame")
    underline.Size             = UDim2.new(0.6, 0, 0, 2)
    underline.Position         = UDim2.new(0.2, 0, 1, -2)
    underline.BackgroundColor3 = CFG.GUI_AccentColor
    underline.BorderSizePixel  = 0
    underline.Visible          = false
    underline.Parent           = btn
    Instance.new("UICorner", underline).CornerRadius = UDim.new(1, 0)

    return btn, underline
end

local btnMain,  ulMain  = makeTabBtn("Main",  "main")
local btnBinds, ulBinds = makeTabBtn("Binds", "binds")

-- páginas
local pageMain  = Instance.new("Frame")
pageMain.Size               = UDim2.new(1, 0, 1, 0)
pageMain.BackgroundTransparency = 1
pageMain.BorderSizePixel    = 0
pageMain.Visible            = true
pageMain.Parent             = tabContent

local pageBinds = Instance.new("Frame")
pageBinds.Size              = UDim2.new(1, 0, 1, 0)
pageBinds.BackgroundTransparency = 1
pageBinds.BorderSizePixel   = 0
pageBinds.Visible           = false
pageBinds.Parent            = tabContent

local function switchTab(tabKey)
    State.activeTab    = tabKey
    pageMain.Visible   = tabKey == "main"
    pageBinds.Visible  = tabKey == "binds"
    ulMain.Visible     = tabKey == "main"
    ulBinds.Visible    = tabKey == "binds"
    btnMain.TextColor3  = tabKey == "main"  and CFG.GUI_Text or CFG.GUI_Muted
    btnBinds.TextColor3 = tabKey == "binds" and CFG.GUI_Text or CFG.GUI_Muted
end

btnMain.MouseButton1Click:Connect(function()  switchTab("main")  end)
btnBinds.MouseButton1Click:Connect(function() switchTab("binds") end)
switchTab("main")

-- ============================================================
-- TAB MAIN — toggles
-- ============================================================
local listMain = Instance.new("Frame")
listMain.Size               = UDim2.new(1, 0, 1, 0)
listMain.BackgroundTransparency = 1
listMain.Parent             = pageMain

local layoutMain = Instance.new("UIListLayout")
layoutMain.Padding       = UDim.new(0, 1)
layoutMain.FillDirection = Enum.FillDirection.Vertical
layoutMain.Parent        = listMain

local padMain = Instance.new("UIPadding")
padMain.PaddingTop = UDim.new(0, 4)
padMain.Parent     = listMain

local function makeToggle(parent, layout_, labelText, getState, onToggle, keybind)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = CFG.GUI_Panel
    row.BorderSizePixel  = 0
    row.Parent           = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size               = UDim2.new(0.55, 0, 1, 0)
    lbl.Position           = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text               = labelText
    lbl.TextColor3         = CFG.GUI_Text
    lbl.Font               = Enum.Font.GothamSemibold
    lbl.TextSize           = 11
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.Parent             = row

    local kb = Instance.new("TextLabel")
    kb.Size             = UDim2.new(0, 28, 0, 16)
    kb.Position         = UDim2.new(1, -68, 0.5, -8)
    kb.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    kb.BorderSizePixel  = 0
    kb.Text             = keybind
    kb.TextColor3       = CFG.GUI_Muted
    kb.Font             = Enum.Font.Gotham
    kb.TextSize         = 9
    kb.TextXAlignment   = Enum.TextXAlignment.Center
    kb.Parent           = row
    Instance.new("UICorner", kb).CornerRadius = UDim.new(0, 4)

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
        local on   = getState()
        TweenService:Create(pill, TweenInfo.new(0.15), {
            BackgroundColor3 = on and CFG.GUI_AccentColor or Color3.fromRGB(50, 50, 50)
        }):Play()
        TweenService:Create(dot, TweenInfo.new(0.15), {
            Position = on
                and UDim2.new(1, -14, 0.5, -6)
                or  UDim2.new(0,  2,  0.5, -6)
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
        saveConfig()
    end)

    return refresh, kb
end

local refreshTBot, kbTBot = makeToggle(listMain, layoutMain,
    "Triggerbot", function() return CFG.TBot_Enabled end,
    function()
        CFG.TBot_Enabled = not CFG.TBot_Enabled
        print("[SimplyGodd] TBot:", CFG.TBot_Enabled and "ON" or "OFF")
    end, keyName(CFG.TBot_Key)
)

local refreshHB, kbHB = makeToggle(listMain, layoutMain,
    "Hitbox ×" .. CFG.HB_Multiplier, function() return CFG.HB_Enabled end,
    function()
        CFG.HB_Enabled = not CFG.HB_Enabled
        if CFG.HB_Enabled then applyHitboxes() else clearHitboxes() end
        print("[SimplyGodd] Hitbox:", CFG.HB_Enabled and "ON" or "OFF")
    end, keyName(CFG.Key_ToggleHB)
)

local refreshVis, kbVis = makeToggle(listMain, layoutMain,
    "HB Visual", function() return CFG.HB_Visible end,
    function()
        CFG.HB_Visible = not CFG.HB_Visible
        print("[SimplyGodd] HB Vis:", CFG.HB_Visible and "ON" or "OFF")
    end, keyName(CFG.Key_ToggleVis)
)

-- watermark al fondo del tab main
local wm = Instance.new("TextLabel")
wm.Size               = UDim2.new(1, 0, 0, 20)
wm.AnchorPoint        = Vector2.new(0, 1)
wm.Position           = UDim2.new(0, 0, 1, -2)
wm.BackgroundTransparency = 1
wm.Text               = "by " .. META.author .. " • " .. META.discord
wm.TextColor3         = CFG.GUI_Muted
wm.Font               = Enum.Font.Gotham
wm.TextSize           = 9
wm.TextXAlignment     = Enum.TextXAlignment.Center
wm.Parent             = pageMain

-- ============================================================
-- TAB BINDS — rebind dinámico, cualquier tecla
-- ============================================================
local BIND_SLOTS = {
    { key = "TBot_Key",       label = "Triggerbot (hold)"  },
    { key = "Key_ToggleTBot", label = "Toggle TBot"        },
    { key = "Key_ToggleHB",   label = "Toggle Hitbox"      },
    { key = "Key_ToggleVis",  label = "Toggle HB Visual"   },
    { key = "Key_ToggleGUI",  label = "Toggle GUI"         },
}

local scrollBinds = Instance.new("ScrollingFrame")
scrollBinds.Size                = UDim2.new(1, 0, 1, 0)
scrollBinds.CanvasSize          = UDim2.new(0, 0, 0, 0)
scrollBinds.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollBinds.ScrollBarThickness  = 3
scrollBinds.ScrollBarImageColor3 = CFG.GUI_AccentColor
scrollBinds.BackgroundTransparency = 1
scrollBinds.BorderSizePixel     = 0
scrollBinds.Parent              = pageBinds

local layoutBinds = Instance.new("UIListLayout")
layoutBinds.Padding       = UDim.new(0, 2)
layoutBinds.FillDirection = Enum.FillDirection.Vertical
layoutBinds.Parent        = scrollBinds

local padBinds = Instance.new("UIPadding")
padBinds.PaddingLeft   = UDim.new(0, 8)
padBinds.PaddingRight  = UDim.new(0, 8)
padBinds.PaddingTop    = UDim.new(0, 6)
padBinds.PaddingBottom = UDim.new(0, 6)
padBinds.Parent        = scrollBinds

-- función que refresca los keylabels del tab main cuando se rebindea
local function refreshMainKeylabels()
    if kbTBot then kbTBot.Text = keyName(CFG.TBot_Key)       end
    if kbHB   then kbHB.Text  = keyName(CFG.Key_ToggleHB)   end
    if kbVis  then kbVis.Text = keyName(CFG.Key_ToggleVis)  end
end

for _, slot in ipairs(BIND_SLOTS) do
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, 0, 0, 34)
    row.BackgroundColor3 = CFG.GUI_Panel
    row.BorderSizePixel  = 0
    row.Parent           = scrollBinds
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size               = UDim2.new(0.55, 0, 1, 0)
    lbl.Position           = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text               = slot.label
    lbl.TextColor3         = CFG.GUI_Text
    lbl.Font               = Enum.Font.GothamSemibold
    lbl.TextSize           = 10
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.Parent             = row

    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(0, 72, 0, 20)
    btn.Position         = UDim2.new(1, -78, 0.5, -10)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.BorderSizePixel  = 0
    btn.Text             = keyName(CFG[slot.key])
    btn.TextColor3       = CFG.GUI_AccentColor
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 10
    btn.Parent           = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    BindState.labels[slot.key] = btn

    local localSlot = slot.key
    btn.MouseButton1Click:Connect(function()
        if BindState.listening then return end
        BindState.listening  = true
        BindState.activeSlot = localSlot
        btn.Text             = "[ ... ]"
        btn.TextColor3       = Color3.fromRGB(255, 200, 50)
    end)
end

-- separador
local sep2 = Instance.new("Frame")
sep2.Size             = UDim2.new(1, 0, 0, 1)
sep2.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
sep2.BorderSizePixel  = 0
sep2.Parent           = scrollBinds

-- delay box
local delayRow = Instance.new("Frame")
delayRow.Size             = UDim2.new(1, 0, 0, 34)
delayRow.BackgroundColor3 = CFG.GUI_Panel
delayRow.BorderSizePixel  = 0
delayRow.Parent           = scrollBinds
Instance.new("UICorner", delayRow).CornerRadius = UDim.new(0, 6)

local delayLbl = Instance.new("TextLabel")
delayLbl.Size               = UDim2.new(0.6, 0, 1, 0)
delayLbl.Position           = UDim2.new(0, 10, 0, 0)
delayLbl.BackgroundTransparency = 1
delayLbl.Text               = "Delay (seg)"
delayLbl.TextColor3         = CFG.GUI_Text
delayLbl.Font               = Enum.Font.GothamSemibold
delayLbl.TextSize           = 10
delayLbl.TextXAlignment     = Enum.TextXAlignment.Left
delayLbl.Parent             = delayRow

local delayBox = Instance.new("TextBox")
delayBox.Size             = UDim2.new(0, 56, 0, 20)
delayBox.Position         = UDim2.new(1, -62, 0.5, -10)
delayBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
delayBox.BorderSizePixel  = 0
delayBox.Text             = tostring(CFG.TBot_Delay)
delayBox.TextColor3       = CFG.GUI_AccentColor
delayBox.Font             = Enum.Font.GothamBold
delayBox.TextSize         = 10
delayBox.ClearTextOnFocus = false
delayBox.Parent           = delayRow
Instance.new("UICorner", delayBox).CornerRadius = UDim.new(0, 4)

delayBox.FocusLost:Connect(function()
    local n = tonumber(delayBox.Text)
    if n and n >= 0 and n <= 2 then
        CFG.TBot_Delay = n
        saveConfig()
    else
        delayBox.Text = tostring(CFG.TBot_Delay)
    end
end)

-- reset binds
local resetRow = Instance.new("Frame")
resetRow.Size               = UDim2.new(1, 0, 0, 30)
resetRow.BackgroundTransparency = 1
resetRow.Parent             = scrollBinds

local resetBtn = Instance.new("TextButton")
resetBtn.Size             = UDim2.new(1, 0, 1, 0)
resetBtn.BackgroundColor3 = Color3.fromRGB(70, 15, 15)
resetBtn.BorderSizePixel  = 0
resetBtn.Text             = "Reset keybinds"
resetBtn.TextColor3       = Color3.fromRGB(255, 90, 90)
resetBtn.Font             = Enum.Font.GothamBold
resetBtn.TextSize         = 10
resetBtn.Parent           = resetRow
Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 6)

resetBtn.MouseButton1Click:Connect(function()
    for k, v in pairs(DEFAULT_BINDS) do
        local ok, enumKey = pcall(function() return Enum.KeyCode[v] end)
        if ok and enumKey then
            CFG[k] = enumKey
            if BindState.labels[k] then
                BindState.labels[k].Text       = v
                BindState.labels[k].TextColor3 = CFG.GUI_AccentColor
            end
        end
    end
    refreshMainKeylabels()
    saveConfig()
    print("[SimplyGodd] Keybinds reseteadas")
end)

-- ============================================================
-- INPUT GLOBAL — rebind + keybinds normales
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gp)

    -- REBIND LISTENER — prioridad máxima, ignora gameProcessed
    if BindState.listening and BindState.activeSlot then
        local kc = input.KeyCode
        if kc == Enum.KeyCode.Unknown then return end

        if kc == Enum.KeyCode.Escape then
            -- cancela el rebind
            local slot = BindState.activeSlot
            BindState.listening  = false
            BindState.activeSlot = nil
            if BindState.labels[slot] then
                BindState.labels[slot].Text       = keyName(CFG[slot])
                BindState.labels[slot].TextColor3 = CFG.GUI_AccentColor
            end
            return
        end

        -- aplica el bind
        CFG[BindState.activeSlot] = kc
        if BindState.labels[BindState.activeSlot] then
            BindState.labels[BindState.activeSlot].Text       = keyName(kc)
            BindState.labels[BindState.activeSlot].TextColor3 = CFG.GUI_AccentColor
        end
        refreshMainKeylabels()
        saveConfig()
        print("[SimplyGodd] Rebind:", BindState.activeSlot, "→", keyName(kc))

        BindState.listening  = false
        BindState.activeSlot = nil
        return
    end

    if gp then return end

    -- KEYBINDS NORMALES
    if input.KeyCode == CFG.Key_ToggleTBot then
        CFG.TBot_Enabled = not CFG.TBot_Enabled
        refreshTBot()
        saveConfig()
        print("[SimplyGodd] TBot:", CFG.TBot_Enabled and "ON" or "OFF")

    elseif input.KeyCode == CFG.Key_ToggleHB then
        CFG.HB_Enabled = not CFG.HB_Enabled
        if CFG.HB_Enabled then applyHitboxes() else clearHitboxes() end
        refreshHB()
        saveConfig()
        print("[SimplyGodd] Hitbox:", CFG.HB_Enabled and "ON" or "OFF")

    elseif input.KeyCode == CFG.Key_ToggleVis then
        CFG.HB_Visible = not CFG.HB_Visible
        refreshVis()
        saveConfig()
        print("[SimplyGodd] HB Vis:", CFG.HB_Visible and "ON" or "OFF")

    elseif input.KeyCode == CFG.Key_ToggleGUI then
        State.guiOpen = not State.guiOpen
        main.Visible  = State.guiOpen
    end
end)

-- ============================================================
print(string.format("[%s %s] loaded — discord: %s", META.name, META.version, META.discord))
-- ============================================================
