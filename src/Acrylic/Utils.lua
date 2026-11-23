local function map(value, inMin, inMax, outMin, outMax)
	return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
end

local function viewportPointToWorld(location, distance)
	local camera = workspace.CurrentCamera
	if not camera then
		return Vector3.zero
	end
	local unitRay = camera:ScreenPointToRay(location.X, location.Y)
	return unitRay.Origin + unitRay.Direction * distance
end

local function getOffset()
	local camera = workspace.CurrentCamera
	local viewportSizeY = camera and camera.ViewportSize.Y or 1080
	return map(viewportSizeY, 0, 2560, 8, 56)
end

return { viewportPointToWorld, getOffset }
