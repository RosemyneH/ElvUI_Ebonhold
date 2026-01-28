local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local EB = E:GetModule("Ebonhold")

E.Options.args.ebonhold = {
	order = 10,
	type = "group",
	name = "Ebonhold",
	childGroups = "tab",
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["Ebonhold addon UI skinning options."],
		},
		enable = {
			order = 2,
			type = "toggle",
			name = L["Enable"],
			get = function(info) return E.private.ebonhold.enable end,
			set = function(info, value) E.private.ebonhold.enable = value E:StaticPopup_Show("PRIVATE_RL") end,
		},
		general = {
			order = 3,
			type = "group",
			name = L["General Options"],
			guiInline = true,
			get = function(info) return E.db.ebonhold[info[#info]] end,
			set = function(info, value) E.db.ebonhold[info[#info]] = value EB:UpdateSkin() end,
			disabled = function() return not E.private.ebonhold.enable end,
			args = {
				scale = {
					order = 1,
					type = "range",
					name = L["Scale"],
					min = 0.5, max = 2, step = 0.01,
					isPercent = true,
				},
				blockServerAddon = {
					order = 2,
					type = "toggle",
					name = "Follow ElvUI Microbar",
					desc = "Prevents the Project Ebonhold server addon from interfering with the ElvUI microbar positioning and visibility.",
				},
			},
		},
		perkHideButton = {
			order = 4,
			type = "group",
			name = "Perk Hide Button",
			guiInline = true,
			get = function(info) return E.db.ebonhold.perkHideButton[info[#info]] end,
			set = function(info, value) E.db.ebonhold.perkHideButton[info[#info]] = value EB:UpdateSkin() end,
			disabled = function() return not E.private.ebonhold.enable end,
			args = {
				scale = {
					order = 1,
					type = "range",
					name = L["Scale"],
					desc = "Use Toggle Anchors to move this frame",
					min = 0.5, max = 2, step = 0.01,
					isPercent = true,
				},
			},
		},
		perkChoice1 = {
			order = 5,
			type = "group",
			name = "Perk Choice 1",
			guiInline = true,
			get = function(info) return E.db.ebonhold.perkChoice1[info[#info]] end,
			set = function(info, value) E.db.ebonhold.perkChoice1[info[#info]] = value EB:UpdateSkin() end,
			disabled = function() return not E.private.ebonhold.enable end,
			args = {
				scale = {
					order = 1,
					type = "range",
					name = L["Scale"],
					desc = "Use Toggle Anchors to move this frame",
					min = 0.5, max = 2, step = 0.01,
					isPercent = true,
				},
			},
		},
		perkChoice2 = {
			order = 6,
			type = "group",
			name = "Perk Choice 2",
			guiInline = true,
			get = function(info) return E.db.ebonhold.perkChoice2[info[#info]] end,
			set = function(info, value) E.db.ebonhold.perkChoice2[info[#info]] = value EB:UpdateSkin() end,
			disabled = function() return not E.private.ebonhold.enable end,
			args = {
				scale = {
					order = 1,
					type = "range",
					name = L["Scale"],
					desc = "Use Toggle Anchors to move this frame",
					min = 0.5, max = 2, step = 0.01,
					isPercent = true,
				},
			},
		},
		perkChoice3 = {
			order = 7,
			type = "group",
			name = "Perk Choice 3",
			guiInline = true,
			get = function(info) return E.db.ebonhold.perkChoice3[info[#info]] end,
			set = function(info, value) E.db.ebonhold.perkChoice3[info[#info]] = value EB:UpdateSkin() end,
			disabled = function() return not E.private.ebonhold.enable end,
			args = {
				scale = {
					order = 1,
					type = "range",
					name = L["Scale"],
					desc = "Use Toggle Anchors to move this frame",
					min = 0.5, max = 2, step = 0.01,
					isPercent = true,
				},
			},
		},
	},
}
