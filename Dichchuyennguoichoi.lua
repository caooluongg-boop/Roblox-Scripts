local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

-- 1. TẠO GIAO DIỆN
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MiniJoker_Draggable"
local success, err = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not success then ScreenGui.Parent = lp:WaitForChild("PlayerGui") end

-- KHUNG CHỨA CHÍNH (Để kéo cả nút và menu cùng lúc)
local MainHolder = Instance.new("Frame")
MainHolder.Size = UDim2.new(0, 45, 0, 45)
MainHolder.Position = UDim2.new(0.02, 0, 0.1, 0)
MainHolder.BackgroundTransparency = 1
MainHolder.Parent = ScreenGui

-- NÚT 😎 (NHỎ GỌN)
local MenuBtn = Instance.new("TextButton")
MenuBtn.Size = UDim2.new(1, 0, 1, 0)
MenuBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MenuBtn.Text = "😎"
MenuBtn.TextSize = 25
MenuBtn.BorderSizePixel = 2
MenuBtn.BorderColor3 = Color3.fromRGB(255, 100, 0)
MenuBtn.Parent = MainHolder

-- KHUNG DANH SÁCH (FULL ĐEN)
local ListFrame = Instance.new("ScrollingFrame")
ListFrame.Size = UDim2.new(0, 160, 0, 220)
ListFrame.Position = UDim2.new(0, 55, 0, 0) -- Luôn đi theo nút 😎
ListFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ListFrame.Visible = false
ListFrame.ScrollBarThickness = 3
ListFrame.Parent = MainHolder

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 3)
Layout.Parent = ListFrame

-- 2. LOGIC KÉO THẢ (DRAGGABLE)
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainHolder.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MenuBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainHolder.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MenuBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- 3. LOGIC BẬT/TẮT
MenuBtn.MouseButton1Click:Connect(function()
    if not dragging then -- Chỉ bật/tắt nếu không phải đang kéo
        ListFrame.Visible = not ListFrame.Visible
    end
end)

-- 4. CẬP NHẬT DANH SÁCH + AVATAR
local function updateList()
    for _, child in pairs(ListFrame:GetChildren()) do
        if child:IsA("ImageButton") then child:Destroy() end
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp then
            local pBtn = Instance.new("ImageButton")
            pBtn.Size = UDim2.new(1, -5, 0, 40)
            pBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            pBtn.BorderSizePixel = 0
            
            local Avatar = Instance.new("ImageLabel")
            Avatar.Size = UDim2.new(0, 34, 0, 34)
            Avatar.Position = UDim2.new(0, 3, 0.5, -17)
            Avatar.BackgroundTransparency = 1
            pcall(function()
                Avatar.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            end)
            Avatar.Parent = pBtn
            
            local pName = Instance.new("TextLabel")
            pName.Size = UDim2.new(1, -45, 1, 0)
            pName.Position = UDim2.new(0, 42, 0, 0)
            pName.BackgroundTransparency = 1
            pName.Text = p.Name
            pName.TextSize = 11
            pName.TextColor3 = Color3.fromRGB(255, 255, 255)
            pName.TextXAlignment = Enum.TextXAlignment.Left
            pName.Parent = pBtn

            pBtn.Parent = ListFrame
            pBtn.MouseButton1Click:Connect(function()
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    lp.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
                end
            end)
        end
    end
    ListFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
end

Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)
updateList()
