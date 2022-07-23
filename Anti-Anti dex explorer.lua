--[[
	Note:
	
	This script does not guarantee you 100% that you will not be detected. There are a LOT of unknown methods Dex Explorer detections (e.g. newproxy detection), I am trying my best to bypass all known detection methods, thanks for listening to me
	Thanks e621 for helping me ( I knew this detection, I was just too lazy to fix it. ).
	
	Put this script in your autoexec folder.
]]


coroutine.resume(coroutine.create(function()

	repeat wait() until game:IsLoaded() 

	local OldGcInfo = gcinfo()
	local RandomValue = 0

	game:GetService("RunService").Stepped:Connect(function()
		RandomValue = math.random(-150,150)
	end)

	local old; old = hookfunction(getrenv().gcinfo, function(...)
		if not checkcaller() then
			return OldGcInfo + RandomValue
		end
		return old(...)
	end)

	local _; _ = hookfunction(getrenv().collectgarbage, function(...)
		if not checkcaller() and ({...})[1] == "collect" then
			return OldGcInfo + RandomValue
		end
		return _(...)
	end)

end))

--Anti InstanceCount detection


local function GetExploitInstances()

	local RobloxInstances = {"DevConsoleMaster", "BubbleChat", "ThemeProvider", "HeadsetDisconnectedDialog", "PurchasePrompt", "RobloxNetworkPauseNotification", "PlayerList", "RobloxLoadingGui", "RobloxPromptGui", "TeleportGui", "CoreScriptLocalization", "RobloxGui"}

	local ExploitInstances = 0
	for i,v in pairs(game:GetService("CoreGui"):GetChildren()) do
		if not table.find(RobloxInstances, v.Name) then
			ExploitInstances = ExploitInstances + #v:GetDescendants() + 1
		end
	end
	return ExploitInstances
end

local Stats = game:GetService("Stats")

--Synapse already has this antidetection but who cares L
local old3; old3 = hookmetamethod(game, "__index", function(self, index, ...)
	if not checkcaller() and self == Stats and index == "InstanceCount" then
		return old3(self, index, ...) - GetExploitInstances()
	end

	return old3(self, index, ...)
end)



--Anti DescendantAdded/Removing check
--GETCONNECTIONS IS UNSTABLE GETCONNECTIONS IS UNSTABLE GETCONNECTIONS IS UNSTABLE GETCONNECTIONS IS UNSTABLE GETCONNECTIONS IS UNSTABLE GETCONNECTIONS IS UNSTABLE
local DescendantAdded = Instance.new("BindableEvent")
local DescendantRemoving = Instance.new("BindableEvent")

local OldDescendantAdded = game.DescendantAdded
local OldDescendantRemoving = game.DescendantRemoving

game.DescendantAdded:Connect(function(obj)
	if not obj:IsDescendantOf(game:GetService("CoreGui")) then
		DescendantAdded:Fire(obj)
	end
end)

game.DescendantRemoving:Connect(function(obj)
	if not obj:IsDescendantOf(game:GetService("CoreGui")) then
		DescendantRemoving:Fire(obj)
	end
end)

local old4; old4 = hookmetamethod(game, "__index", function(self, index, ...)
	if not checkcaller() and self == game then
		if index == "DescendantAdded" then
			return DescendantAdded.Event
		elseif index == "DescendantRemoving" then
			return  DescendantRemoving.Event
		end
	end

	return old4(self, index, ...)
end)

local old5; old5 = hookfunction((getrenv().typeof and getrenv().tostring), function(arg1,...)
	if not checkcaller() then
		if arg1 == DescendantAdded.Event then
			return old5(OldDescendantAdded,...)
		elseif arg1 == DescendantRemoving then
			return old5(OldDescendantRemoving,...)
		end
	end
	return old5(arg1, ...)
end)

local OldAssert; OldAssert = hookfunction(getrenv().assert, function(...)
	if checkcaller() then return OldAssert(...) end

	local tb = {}
	for i,v in pairs({...}) do
		if v == DescendantAdded.Event then
			table.insert(tb, OldDescendantAdded)
		elseif v == DescendantRemoving.Event then
			table.insert(tb, OldDescendantRemoving)
		else 
			table.insert(tb, v)
		end	
	end

	return OldAssert(table.unpack(tb))
end)

--Anti GetFocusedTextBox Check
local _IsDescendantOf = game.IsDescendantOf
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local old7; old7 = hookmetamethod(game, "__namecall", function(self,...)
	--YES I KNOW ABOUT UserInputService.TextBoxFocusReleased & TextBoxFocused EVENTS, IM NOT STUPID
	if self == UserInputService and getnamecallmethod() == "GetFocusedTextBox" then
		local Value = old7(self,...)
		if Value and typeof(Value) == "Instance" then 
			if _IsDescendantOf(Value, CoreGui) then
				return nil    
			end    
		end
	end 
	return old7(self,...)
end)


--Anti newproxy check
local TableNumbaor001 = {}

local SomethingOld; SomethingOld = hookfunction(getrenv().newproxy, function(...)
	local proxy = SomethingOld(...)
	table.insert(TableNumbaor001, proxy)
	return proxy
end)

game:GetService("RunService").Stepped:Connect(function()
	for i,v in pairs(TableNumbaor001) do
		if v == nil then 
        		--[[
				Lmao, this is the most retarded and at the same time genius bypass.
				Just checking if its nil or not. This works because it checks the opcodes for the newproxy, if there are no opcodes, the newproxy will be nil.
				I will update this script when I get enough sleep.
				(:
			--]]
		end
	end    
end)
