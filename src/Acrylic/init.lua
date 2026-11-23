local Lighting = game:GetService("Lighting")

local Acrylic = {
	AcrylicBlur = require(script.AcrylicBlur),
	CreateAcrylic = require(script.CreateAcrylic),
	AcrylicPaint = require(script.AcrylicPaint),
	BlurSize = 20,
}

local blurEffect
local savedBlurs = {}

local function rememberBlurs()
	for _, child in ipairs(Lighting:GetChildren()) do
		if child:IsA("BlurEffect") and child ~= blurEffect and savedBlurs[child] == nil then
			savedBlurs[child] = child.Enabled
		end
	end
end

function Acrylic.Enable()
	if not blurEffect then
		return
	end
	rememberBlurs()
	for effect in pairs(savedBlurs) do
		if effect.Parent then
			effect.Enabled = false
		end
	end
	blurEffect.Size = Acrylic.BlurSize
	blurEffect.Enabled = true
	blurEffect.Parent = Lighting
end

function Acrylic.Disable()
	if blurEffect then
		blurEffect.Enabled = false
		blurEffect.Parent = nil
	end
	for effect, wasEnabled in pairs(savedBlurs) do
		if effect.Parent then
			effect.Enabled = wasEnabled
		end
	end
end

function Acrylic.init()
	if not blurEffect then
		blurEffect = Instance.new("BlurEffect")
		blurEffect.Name = "FluentAcrylic"
		blurEffect.Size = Acrylic.BlurSize
		blurEffect.Enabled = false
	end
	Acrylic.Enable()
end

return Acrylic
