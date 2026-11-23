local UserInputService = game:GetService("UserInputService")

local Root = script.Parent.Parent
local Creator = require(Root.Creator)

local New = Creator.New
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "Keybind"

function Element:New(Idx, Config)
	local Library = self.Library
	assert(Config.Title, "KeyBind - Missing Title")
	assert(Config.Default, "KeyBind - Missing default value.")

	local Keybind = {
		Value = Config.Default,
		Toggled = false,
		Mode = Config.Mode or "Toggle",
		Type = "Keybind",
		Callback = Config.Callback or function(Value) end,
		ChangedCallback = Config.ChangedCallback or function(New) end,
	}

	local Picking = false
	local armed = false
	local owned = {}
	local function listen(signal, fn)
		table.insert(owned, Creator.AddSignal(signal, fn))
	end

	local KeybindFrame = require(Components.Element)(Config.Title, Config.Description, self.Container, true)

	Keybind.SetTitle = KeybindFrame.SetTitle
	Keybind.SetDesc = KeybindFrame.SetDesc

	local KeybindDisplayLabel = New("TextLabel", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
		Text = Config.Default,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(0, 0, 0, 14),
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	local KeybindDisplayFrame = New("TextButton", {
		Size = UDim2.fromOffset(0, 30),
		Position = UDim2.new(1, -10, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 0.9,
		Parent = KeybindFrame.Frame,
		AutomaticSize = Enum.AutomaticSize.X,
		ThemeTag = {
			BackgroundColor3 = "Keybind",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 5),
		}),
		New("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
		}),
		New("UIStroke", {
			Transparency = 0.5,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeTag = {
				Color = "InElementBorder",
			},
		}),
		KeybindDisplayLabel,
	})

	function Keybind:GetState()
		if UserInputService:GetFocusedTextBox() and Keybind.Mode ~= "Always" then
			return false
		end

		if Keybind.Mode == "Always" then
			return true
		elseif Keybind.Mode == "Hold" then
			if Keybind.Value == "None" then
				return false
			end

			local Key = Keybind.Value

			if Key == "MouseLeft" or Key == "MouseRight" then
				return Key == "MouseLeft" and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
					or Key == "MouseRight"
						and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
			else
				local ok, code = pcall(function()
					return Enum.KeyCode[Keybind.Value]
				end)
				if not ok or not code then
					return false
				end
				return UserInputService:IsKeyDown(code)
			end
		else
			return Keybind.Toggled
		end
	end

	function Keybind:SetValue(Key, Mode)
		if Key == nil then
			Key = Keybind.Value or "None"
		end
		if Mode == nil then
			Mode = Keybind.Mode
		end

		Keybind.Value = Key
		Keybind.Mode = Mode
		KeybindDisplayLabel.Text = tostring(Key)
	end

	function Keybind:OnClick(Callback)
		Keybind.Clicked = Callback
	end

	function Keybind:OnChanged(Callback)
		Keybind.Changed = Callback
		Callback(Keybind.Value)
	end

	function Keybind:DoClick()
		Library:SafeCallback(Keybind.Callback, Keybind.Toggled)
		Library:SafeCallback(Keybind.Clicked, Keybind.Toggled)
	end

	function Keybind:Destroy()
		Picking = false
		for _, connection in ipairs(owned) do
			Creator.DisconnectSignal(connection)
		end
		KeybindFrame:Destroy()
		Library.Options[Idx] = nil
	end

	local function isPrimary(input)
		return input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
	end

	listen(KeybindDisplayFrame.InputBegan, function(Input)
		if isPrimary(Input) then
			Picking = true
			armed = false
			KeybindDisplayLabel.Text = "..."
		end
	end)

	listen(UserInputService.InputEnded, function(Input)
		if Picking and not armed and isPrimary(Input) then
			armed = true
		end
	end)

	listen(UserInputService.InputBegan, function(Input)
		if Picking then
			if not armed then
				return
			end

			local Key
			if Input.UserInputType == Enum.UserInputType.Keyboard then
				if Input.KeyCode == Enum.KeyCode.Escape then
					Picking = false
					armed = false
					KeybindDisplayLabel.Text = tostring(Keybind.Value)
					return
				end
				Key = Input.KeyCode.Name
			elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
				Key = "MouseLeft"
			elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
				Key = "MouseRight"
			else
				return
			end

			Picking = false
			armed = false
			Keybind:SetValue(Key, Keybind.Mode)
			Library:SafeCallback(Keybind.ChangedCallback, Input.KeyCode or Input.UserInputType)
			Library:SafeCallback(Keybind.Changed, Input.KeyCode or Input.UserInputType)
			return
		end

		if not UserInputService:GetFocusedTextBox() then
			if Keybind.Mode == "Toggle" then
				local Key = Keybind.Value

				if Key == "MouseLeft" or Key == "MouseRight" then
					if
						Key == "MouseLeft" and Input.UserInputType == Enum.UserInputType.MouseButton1
						or Key == "MouseRight" and Input.UserInputType == Enum.UserInputType.MouseButton2
					then
						Keybind.Toggled = not Keybind.Toggled
						Keybind:DoClick()
					end
				elseif Input.UserInputType == Enum.UserInputType.Keyboard then
					if Input.KeyCode.Name == Key then
						Keybind.Toggled = not Keybind.Toggled
						Keybind:DoClick()
					end
				end
			end
		end
	end)

	Library.Options[Idx] = Keybind
	return Keybind
end

return Element
