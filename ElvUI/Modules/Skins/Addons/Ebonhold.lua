local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EB = E:NewModule("Ebonhold")

-- Lua functions
local _G = _G
local hooksecurefunc = hooksecurefunc

-- ʕ •ᴥ•ʔ✿ Frame configuration ✿ ʕ •ᴥ•ʔ
local frameConfigs = {
	{name = "ProjectEbonholdPlayerRunFrame", dbKey = nil, moverName = nil},
	{name = "PerkHideButton", dbKey = "perkHideButton", moverName = "ElvUI_PerkHideButtonMover", moverText = "Perk Hide Button", defaultX = 0, defaultY = -436},
	{name = "PerkChoice1", dbKey = "perkChoice1", moverName = "ElvUI_PerkChoice1Mover", moverText = "Perk Choice 1", defaultX = -250, defaultY = 0},
	{name = "PerkChoice2", dbKey = "perkChoice2", moverName = "ElvUI_PerkChoice2Mover", moverText = "Perk Choice 2", defaultX = 0, defaultY = 0},
	{name = "PerkChoice3", dbKey = "perkChoice3", moverName = "ElvUI_PerkChoice3Mover", moverText = "Perk Choice 3", defaultX = 250, defaultY = 0},
}

-- ʕ •ᴥ•ʔ✿ Apply scale to a frame ✿ ʕ •ᴥ•ʔ
local function ApplyFrameScale(frame, scale)
	if not frame or not frame.SetScale then return end
	
	if not frame.isSettingScale then
		frame.isSettingScale = true
		frame:SetScale(scale or 1)
		frame.isSettingScale = nil
	end
end

-- ʕ •ᴥ•ʔ✿ Position frame to mover ✿ ʕ •ᴥ•ʔ
local function PositionFrameToMover(frame)
	if not frame or not frame.mover then return end
	
	if not frame.isSettingPosition then
		frame.isSettingPosition = true
		frame:ClearAllPoints()
		frame:SetPoint("CENTER", frame.mover, "CENTER")
		frame.isSettingPosition = nil
	end
end

-- ʕ •ᴥ•ʔ✿ Apply Scale and Position ✿ ʕ •ᴥ•ʔ
function EB:UpdateSkin()
	if not E.private.ebonhold or not E.private.ebonhold.enable then return end

	local db = E.db.ebonhold
	if not db then return end

	for _, config in pairs(frameConfigs) do
		local frame = _G[config.name]
		if frame then
			if config.dbKey then
				local settings = db[config.dbKey]
				if settings then
					ApplyFrameScale(frame, settings.scale)
					PositionFrameToMover(frame)
				end
			else
				ApplyFrameScale(frame, db.scale)
			end
		end
	end
end

-- ʕ •ᴥ•ʔ✿ Hook a frame to prevent overrides ✿ ʕ •ᴥ•ʔ
local function HookFrame(frame, dbKey)
	if not frame or not frame.SetScale then return end
	
	hooksecurefunc(frame, "SetScale", function(f, scale)
		if f.isSettingScale then return end
		local db = E.db.ebonhold
		if not db then return end
		
		local targetScale
		if dbKey then
			targetScale = (db[dbKey] and db[dbKey].scale) or 1
		else
			targetScale = db.scale or 1
		end
		
		if scale ~= targetScale then
			f.isSettingScale = true
			f:SetScale(targetScale)
			f.isSettingScale = nil
		end
	end)
	
	if frame.SetPoint and frame.mover then
		hooksecurefunc(frame, "SetPoint", function(f, ...)
			if f.isSettingPosition then return end
			PositionFrameToMover(f)
		end)
	end
end

-- ʕ •ᴥ•ʔ✿ Create mover for frame ✿ ʕ •ᴥ•ʔ
local function CreateMoverForFrame(frame, config)
	if not frame or not config.moverName then return end
	if frame.mover then return end
	
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", E.UIParent, "CENTER", config.defaultX or 0, config.defaultY or 0)
	
	E:CreateMover(frame, config.moverName, config.moverText, nil, nil, nil, "ALL,GENERAL", nil, "ebonhold")
	
	frame.mover = _G[config.moverName]
	PositionFrameToMover(frame)
end

-- ʕ •ᴥ•ʔ✿ Search for frames until found ✿ ʕ •ᴥ•ʔ
local attempts = 0
function EB:InitializeSkin()
	local allFound = true
	
	for _, config in pairs(frameConfigs) do
		local frame = _G[config.name]
		if frame then
			if not self.hookedFrames then
				self.hookedFrames = {}
			end
			
			if not self.hookedFrames[config.name] then
				CreateMoverForFrame(frame, config)
				HookFrame(frame, config.dbKey)
				self.hookedFrames[config.name] = true
			end
		else
			allFound = false
		end
	end

	self:UpdateSkin()

	attempts = attempts + 1
	if not allFound or attempts < 10 then
		E:Delay(1, function() self:InitializeSkin() end)
	end
end

function EB:Initialize()
	if not E.private.ebonhold or not E.private.ebonhold.enable then return end
	
	-- ʕ ● ᴥ ●ʔ✿ Start the search process ✿ ʕ ● ᴥ ●ʔ
	self:InitializeSkin()
end

E:RegisterModule(EB:GetName(), function() EB:Initialize() end)
