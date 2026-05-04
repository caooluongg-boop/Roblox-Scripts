local p = game.Players.LocalPlayer
local n = false
local sg = Instance.new("ScreenGui", p.PlayerGui)
local f = Instance.new("Frame", sg)
local b = Instance.new("TextButton", f)
local t = Instance.new("TextLabel", f)

-- UI DECOR (Đẹp + Có Tag)
f.Size, f.Position, f.BackgroundColor3 = UDim2.new(0,150,0,65), UDim2.new(0.1,0,0.5,0), Color3.new(0,0,0)
f.Active, f.Draggable = true, true
Instance.new("UICorner", f)
local s = Instance.new("UIStroke", f) s.Color, s.Thickness = Color3.new(1,0,0), 2

b.Size, b.Position, b.Text = UDim2.new(1,-20,0,30), UDim2.new(0,10,0,8), "NOCLIP: OFF"
b.BackgroundColor3, b.TextColor3, b.Font = Color3.new(0.5,0,0), Color3.new(1,1,1), "GothamBold"
Instance.new("UICorner", b)

t.Size, t.Position, t.Text = UDim2.new(1,0,0,20), UDim2.new(0,0,1,-20), "@truongcaoluong288"
t.TextColor3, t.BackgroundTransparency, t.TextSize = Color3.new(1,1,1), 1, 10

-- LOGIC CHUẨN (Bấm OFF là cứng ngay)
b.MouseButton1Click:Connect(function()
    n = not n
    b.Text = n and "NOCLIP: ON" or "NOCLIP: OFF"
    b.BackgroundColor3 = n and Color3.new(0,0.5,0) or Color3.new(0.5,0,0)
    s.Color = n and Color3.new(0,1,0) or Color3.new(1,0,0)
end)

game:GetService("RunService").Stepped:Connect(function()
    if p.Character then
        for _, v in pairs(p.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = not n end
        end
    end
end)
