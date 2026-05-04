local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

local targetPlayer = nil
local isFollowing = false
local isSky = false
local antiBanActive = false

-- 1. GIAO DIỆN (BẢN FIX KÉO THẢ)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Name = "JokerMenu_V12"
Main.Size = UDim2.new(0, 130, 0, 180)
Main.Position = UDim2.new(0.85, 0, 0.35, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(0, 255, 150)
Main.Active = true -- Phải để true để nhận sự kiện chuột

-- --- HÀM KÉO THẢ SIÊU MƯỢT (CUSTOM DRAG) ---
local dragging, dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Main.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Main.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

Main.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)
-- ------------------------------------------

local function CreateBtn(name, pos, color)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = pos
    btn.Text = name
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local LockBtn = CreateBtn("KHÓA MỤC TIÊU", UDim2.new(0.05, 0, 0, 10), Color3.fromRGB(120, 0, 0))
local SkyBtn = CreateBtn("KÉO LÊN TRỜI", UDim2.new(0.05, 0, 0, 55), Color3.fromRGB(0, 80, 150))
local AntiBtn = CreateBtn("ANTI-BAN: OFF", UDim2.new(0.05, 0, 0, 100), Color3.fromRGB(50, 50, 50))
local NextBtn = CreateBtn("ĐỔI NGƯỜI ⏭️", UDim2.new(0.05, 0, 0, 145), Color3.fromRGB(30, 30, 30))

-- 2. HỆ THỐNG ANTI-BAN
local function ActivateAntiBan()
    local g = getgenv and getgenv() or _G
    local old; old = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if self == lp and (method == "Kick" or method == "kick") then return nil end
        return old(self, ...)
    end)
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    end
end

-- 3. HÀM QUÉT MỤC TIÊU
local function findWeakest()
    local weakest = nil
    local minHealth = math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            if p.Character.Humanoid.Health < minHealth then
                minHealth = p.Character.Humanoid.Health
                weakest = p
            end
        end
    end
    return weakest
end

-- 4. LOGIC BAY & BÁM
RunService.Heartbeat:Connect(function()
    local myChar = lp.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    if isFollowing then
        if not targetPlayer or not targetPlayer.Character or targetPlayer.Character.Humanoid.Health <= 0 then
            targetPlayer = findWeakest()
        end
    end
    if isFollowing and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local tPart = targetPlayer.Character.HumanoidRootPart
        myChar.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        tPart.Velocity = Vector3.new(0, 0, 0)
        if isSky then
            local SkyPos = CFrame.new(tPart.Position.X, 40, tPart.Position.Z)
            tPart.CFrame = SkyPos
            myChar.HumanoidRootPart.CFrame = SkyPos * CFrame.new(0, 0, -1.2)
        else
            myChar.HumanoidRootPart.CFrame = tPart.CFrame * CFrame.new(0, -2.5, 1.1)
        end
    end
end)

-- 5. SỰ KIỆN NÚT BẤM
LockBtn.MouseButton1Click:Connect(function()
    isFollowing = not isFollowing
    LockBtn.Text = isFollowing and "ĐANG KHÓA ✅" or "KHÓA MỤC TIÊU"
end)
SkyBtn.MouseButton1Click:Connect(function()
    if targetPlayer then isSky = not isSky SkyBtn.Text = isSky and "HẠ CÁNH ⚓" or "KÉO LÊN TRỜI" end
end)
AntiBtn.MouseButton1Click:Connect(function()
    if not antiBanActive then antiBanActive = true ActivateAntiBan() AntiBtn.Text = "ANTI-BAN: ON ✅" AntiBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80) end
end)
NextBtn.MouseButton1Click:Connect(function() targetPlayer = findWeakest() end)
