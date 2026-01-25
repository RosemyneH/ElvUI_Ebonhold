local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EB = E:NewModule("Ebonhold")

-- Lua functions
local _G = _G
local hooksecurefunc = hooksecurefunc

-- ʕ •ᴥ•ʔ✿ Apply Scale ✿ ʕ •ᴥ•ʔ
function EB:UpdateSkin()
	if not E.private.ebonhold or not E.private.ebonhold.enable then return end

	local frame = _G.ProjectEbonholdPlayerRunFrame
	-- We use the global directly since the user verified it has :SetScale
	if not frame or not frame.SetScale then return end

	local db = E.db.ebonhold
	if not db or not db.scale then return end

	-- ʕ ● ᴥ ●ʔ✿ Forced Scaling ✿ ʕ ● ᴥ ●ʔ
	if not frame.isSettingScale then
		frame.isSettingScale = true
		frame:SetScale(db.scale)
		frame.isSettingScale = nil
	end
end

-- ʕ •ᴥ•ʔ✿ Search for the frame until found ✿ ʕ •ᴥ•ʔ
local attempts = 0
function EB:InitializeSkin()
	local frame = _G.ProjectEbonholdPlayerRunFrame
	
	if frame and frame.SetScale then
		-- Found it! Hook SetScale to ensure the addon doesn't override our value
		if not self.hooked then
			hooksecurefunc(frame, "SetScale", function(f, scale)
				if f.isSettingScale then return end
				local targetScale = (E.db.ebonhold and E.db.ebonhold.scale) or 1
				if scale ~= targetScale then
					f.isSettingScale = true
					f:SetScale(targetScale)
					f.isSettingScale = nil
				end
			end)
			self.hooked = true
		end

		-- Apply initial scale
		self:UpdateSkin()

		-- Addons often reset their scale during the first few seconds of loading.
		-- We keep forcing our scale for 10 seconds to ensure it "sticks".
		attempts = attempts + 1
		if attempts < 10 then
			E:Delay(1, function() self:InitializeSkin() end)
		end
	else
		-- Not found yet, retry every second
		E:Delay(1, function() self:InitializeSkin() end)
	end
end

function EB:Initialize()
	if not E.private.ebonhold or not E.private.ebonhold.enable then return end
	
	-- ʕ ● ᴥ ●ʔ✿ Start the search process ✿ ʕ ● ᴥ ●ʔ
	self:InitializeSkin()
end

E:RegisterModule(EB:GetName(), function() EB:Initialize() end)
