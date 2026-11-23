local Acrylic = {
	AcrylicBlur = require(script.AcrylicBlur),
	CreateAcrylic = require(script.CreateAcrylic),
	AcrylicPaint = require(script.AcrylicPaint),
}

local started = false
local baseEffect
local depthOfFieldDefaults = {}

function Acrylic.Enable()
	for effect in pairs(depthOfFieldDefaults) do
		if effect.Parent then
			effect.Enabled = false
		end
	end
	if baseEffect then
		baseEffect.Parent = game:GetService("Lighting")
	end
end

function Acrylic.Disable()
	for effect, wasEnabled in pairs(depthOfFieldDefaults) do
		if effect.Parent then
			effect.Enabled = wasEnabled
		end
	end
	if baseEffect then
		baseEffect.Parent = nil
	end
end

function Acrylic.init()
	if started then
		Acrylic.Enable()
		return
	end
	started = true

	baseEffect = Instance.new("DepthOfFieldEffect")
	baseEffect.Name = "FluentBlur"
	baseEffect.FarIntensity = 0
	baseEffect.InFocusRadius = 0.1
	baseEffect.NearIntensity = 1

	local function registerDefaults()
		local function register(object)
			if object:IsA("DepthOfFieldEffect") and object ~= baseEffect then
				depthOfFieldDefaults[object] = object.Enabled
			end
		end

		for _, child in pairs(game:GetService("Lighting"):GetChildren()) do
			register(child)
		end

		if game:GetService("Workspace").CurrentCamera then
			for _, child in pairs(game:GetService("Workspace").CurrentCamera:GetChildren()) do
				register(child)
			end
		end
	end

	registerDefaults()
	Acrylic.Enable()
end

return Acrylic
