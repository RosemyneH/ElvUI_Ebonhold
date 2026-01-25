local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule("ActionBars")

--Lua functions
local _G = _G
local unpack = unpack
local gsub, match = string.gsub, string.match
--WoW API / Variables
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local RegisterStateDriver = RegisterStateDriver

local MICRO_BUTTONS = {
	"CharacterMicroButton",
	"SpellbookMicroButton",
	"TalentMicroButton",
	"AchievementMicroButton",
	"QuestLogMicroButton",
	"SocialsMicroButton",
	"PVPMicroButton",
	"LFDMicroButton",
	"MainMenuMicroButton",
	"HelpMicroButton",
	"SkillTreeMicroButton"
}

-- ʕ •ᴥ•ʔ✿ Added SkillTreeMicroButton for Ebonhold ✿ ʕ •ᴥ•ʔ

local function onEnter(button)
	if AB.db.microbar.mouseover then
		E:UIFrameFadeIn(ElvUI_MicroBar, 0.2, ElvUI_MicroBar:GetAlpha(), AB.db.microbar.alpha)
	end

	if button and button ~= ElvUI_MicroBar and button.backdrop then
		button.backdrop:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
	end
end

local function onLeave(button)
	if AB.db.microbar.mouseover then
		E:UIFrameFadeOut(ElvUI_MicroBar, 0.2, ElvUI_MicroBar:GetAlpha(), 0)
	end

	if button and button ~= ElvUI_MicroBar and button.backdrop then
		button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end
end

function AB:HandleMicroButton(button)
	if not button then return end

	button:SetParent(ElvUI_MicroBar)

	-- ʕ •ᴥ•ʔ✿ If it's already skinned by ElvUI, we're done ✿ ʕ •ᴥ•ʔ
	if button.isElvUISkinned then return end

	local pushed = button:GetPushedTexture()
	local normal = button:GetNormalTexture()
	local disabled = button:GetDisabledTexture()

	if not button.backdrop then
		local f = CreateFrame("Frame", nil, button)
		f:SetFrameLevel(button:GetFrameLevel() - 1)
		f:SetTemplate("Default", true)
		f:SetOutside(button)
		button.backdrop = f
	end

	if button.GetHighlightTexture and button:GetHighlightTexture() then
		button:GetHighlightTexture():Kill()
	end
	button:HookScript("OnEnter", onEnter)
	button:HookScript("OnLeave", onLeave)
	button:SetHitRectInsets(0, 0, 0, 0)
	button:Show()

	if pushed then
		pushed:SetTexCoord(0.17, 0.87, 0.5, 0.908)
		pushed:SetInside(button.backdrop)
	end

	if normal then
		normal:SetTexCoord(0.17, 0.87, 0.5, 0.908)
		normal:SetInside(button.backdrop)
	end

	if disabled then
		disabled:SetTexCoord(0.17, 0.87, 0.5, 0.908)
		disabled:SetInside(button.backdrop)
	end

	button.isElvUISkinned = true
	button.isSkinned = true
end

function AB:UpdateMicroButtonsParent()
	if not ElvUI_MicroBar then return end

	for i = 1, #MICRO_BUTTONS do
		local button = _G[MICRO_BUTTONS[i]]
		if button then
			if button:GetParent() ~= ElvUI_MicroBar then
				button:SetParent(ElvUI_MicroBar)
			end
			if not button.isElvUISkinned then
				self:HandleMicroButton(button)
			end
		end
	end

	AB:UpdateMicroPositionDimensions()
end

function AB:PLAYER_ENTERING_WORLD()
	self:UpdateMicroButtonsParent()
end

function AB:UpdateMicroBarVisibility()
	if InCombatLockdown() then
		AB.NeedsUpdateMicroBarVisibility = true
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	local visibility = self.db.microbar.visibility
	if visibility and match(visibility, "[\n\r]") then
		visibility = gsub(visibility, "[\n\r]", "")
	end

	RegisterStateDriver(ElvUI_MicroBar.visibility, "visibility", (self.db.microbar.enabled and visibility) or "hide")
end

function AB:UpdateMicroPositionDimensions()
	if not ElvUI_MicroBar then return end

	local numRows = 1
	local prevButton = ElvUI_MicroBar
	local offset = E:Scale(E.PixelMode and 1 or 3)
	local spacing = E:Scale(offset + self.db.microbar.buttonSpacing)

	local buttons = {}
	for i = 1, #MICRO_BUTTONS do
		local button = _G[MICRO_BUTTONS[i]]
		if button then
			buttons[#buttons + 1] = button
		end
	end

	for i = 1, #buttons do
		local button = buttons[i]
		local lastColumnButton = i - self.db.microbar.buttonsPerRow
		lastColumnButton = buttons[lastColumnButton]

		button:Size(self.db.microbar.buttonSize, self.db.microbar.buttonSize * 1.4)
		button:ClearAllPoints()

		if prevButton == ElvUI_MicroBar then
			button:Point("TOPLEFT", prevButton, "TOPLEFT", offset, -offset)
		elseif (i - 1) % self.db.microbar.buttonsPerRow == 0 then
			button:Point("TOP", lastColumnButton, "BOTTOM", 0, -spacing)
			numRows = numRows + 1
		else
			button:Point("LEFT", prevButton, "RIGHT", spacing, 0)
		end

		prevButton = button
	end

	if AB.db.microbar.mouseover and not ElvUI_MicroBar:IsMouseOver() then
		ElvUI_MicroBar:SetAlpha(0)
	else
		ElvUI_MicroBar:SetAlpha(self.db.microbar.alpha)
	end

	local numButtons = #buttons
	if numButtons == 0 then
		ElvUI_MicroBar:Size(0, 0)
		return
	end

	local buttonsPerRow = self.db.microbar.buttonsPerRow
	local numColumns = (numRows > 1) and buttonsPerRow or numButtons
	local buttonWidth = self.db.microbar.buttonSize
	local buttonHeight = buttonWidth * 1.4

	AB.MicroWidth = (((buttonWidth + spacing) * numColumns) - spacing) + (offset * 2)
	AB.MicroHeight = (((buttonHeight + spacing) * numRows) - spacing) + (offset * 2)
	ElvUI_MicroBar:Size(AB.MicroWidth, AB.MicroHeight)

	if ElvUI_MicroBar.mover then
		ElvUI_MicroBar.mover:Size(ElvUI_MicroBar:GetSize())

		if not InCombatLockdown() then
			ElvUI_MicroBar:ClearAllPoints()
			ElvUI_MicroBar:Point("TOPLEFT", ElvUI_MicroBar.mover, "TOPLEFT")
		end
	end

	if ElvUI_MicroBar.mover then
		if self.db.microbar.enabled then
			E:EnableMover(ElvUI_MicroBar.mover:GetName())
		else
			E:DisableMover(ElvUI_MicroBar.mover:GetName())
		end
	end

	self:UpdateMicroBarVisibility()
end

function AB:SetupMicroBar()
	if ElvUI_MicroBar then return end

	local microBar = CreateFrame("Frame", "ElvUI_MicroBar", E.UIParent)
	microBar:Point("TOPLEFT", E.UIParent, "TOPLEFT", 4, -48)
	microBar:SetFrameStrata("LOW")
	microBar:EnableMouse(true)
	microBar:SetClampedToScreen(true)
	microBar:SetScript("OnEnter", onEnter)
	microBar:SetScript("OnLeave", onLeave)

	microBar.visibility = CreateFrame("Frame", nil, E.UIParent, "SecureHandlerStateTemplate")
	microBar.visibility:SetScript("OnShow", function() microBar:Show() end)
	microBar.visibility:SetScript("OnHide", function() microBar:Hide() end)

	for i = 1, #MICRO_BUTTONS do
		local button = _G[MICRO_BUTTONS[i]]
		if button then
			self:HandleMicroButton(button)
		end
	end

	MicroButtonPortrait:SetAllPoints()

	-- PvP Micro Button
	PVPMicroButtonTexture:SetAllPoints()
	PVPMicroButtonTexture:SetTexture([[Interface\AddOns\ElvUI\Media\Textures\PVP-Icons]])

	if E.myfaction == "Alliance" then
		PVPMicroButtonTexture:SetTexCoord(0.545, 0.935, 0.070, 0.940)
	else
		PVPMicroButtonTexture:SetTexCoord(0.100, 0.475, 0.070, 0.940)
	end

	self:SecureHook("VehicleMenuBar_MoveMicroButtons", "UpdateMicroButtonsParent")
	if _G.MoveMicroButtons then
		self:SecureHook("MoveMicroButtons", "UpdateMicroButtonsParent")
	end
	if _G.UpdateMicroButtons then
		self:SecureHook("UpdateMicroButtons", "UpdateMicroButtonsParent")
	end

	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	-- ʕ •ᴥ•ʔ✿ Delay updates to catch late-loading server buttons and override other addons ✿ ʕ •ᴥ•ʔ
	E:Delay(1, AB.UpdateMicroButtonsParent, AB)
	E:Delay(5, AB.UpdateMicroButtonsParent, AB)

	self:UpdateMicroPositionDimensions()
	MainMenuBarPerformanceBar:Kill()

	E:CreateMover(microBar, "MicrobarMover", L["Micro Bar"], nil, nil, nil, "ALL,ACTIONBARS", nil, "actionbar,microbar")
end