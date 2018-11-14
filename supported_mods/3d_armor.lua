--[[
	Mod Battle para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Suporte para mod 3d_armor
  ]]

if minetest.get_modpath("3d_armor") == nil then return end

battle.register_on_join_lobby(function(player)
	local nm, armor_inv = armor:get_valid_player(player, "[join_lobby]")
	if nm then
		for i=1, armor_inv:get_size("armor") do
			local stack = armor_inv:get_stack("armor", i)
			if stack:get_count() > 0 then
				armor:run_callbacks("on_unequip", player, i, stack)
				armor_inv:set_stack("armor", i, nil)
			end
		end
		armor:save_armor_inventory(player)
		armor:set_player_armor(player)
	end
end)

battle.register_on_player_reset(function(player)
	default.player_set_model(player, "3d_armor_character.b3d")
end)

-- Carregar armaduras
if minetest.get_modpath("treasurer") 
	and minetest.settings:get("battle_load_armor_loot_itens") ~= "false" then
	for _,d in ipairs({
	--	itemstring				raridade	preciosidade	qtd min e max	desgaste para ferramentas min e max
	--	"modname:item"				0.001 ~ 1.000	1 ~ 10		1 ~ 99		0 ~ 65535
		{"3d_armor:helmet_wood",		0.200,		1,		nil,		{1000,65000}	},
		{"3d_armor:chestplate_wood",		0.200,		1,		nil,		{1000,65000}	},
		{"3d_armor:leggings_wood",		0.200,		1,		nil,		{1000,65000}	},
		{"3d_armor:boots_wood",			0.200,		1,		nil,		{1000,65000}	},
		
		{"3d_armor:helmet_cactus",		0.180,		1,		nil,		{1000,65000}	},
		{"3d_armor:chestplate_cactus",		0.180,		1,		nil,		{1000,65000}	},
		{"3d_armor:leggings_cactus",		0.180,		1,		nil,		{1000,65000}	},
		{"3d_armor:boots_cactus",		0.180,		1,		nil,		{1000,65000}	},
		
		{"3d_armor:helmet_steel",		0.100,		4,		nil,		{1000,65000}	},
		{"3d_armor:chestplate_steel",		0.100,		4,		nil,		{1000,65000}	},
		{"3d_armor:leggings_steel",		0.100,		4,		nil,		{1000,65000}	},
		{"3d_armor:boots_steel",		0.100,		4,		nil,		{1000,65000}	},
		
		{"3d_armor:helmet_bronze",		0.050,		7,		nil,		{1000,65000}	},
		{"3d_armor:chestplate_bronze",		0.050,		7,		nil,		{1000,65000}	},
		{"3d_armor:leggings_bronze",		0.050,		7,		nil,		{1000,65000}	},
		{"3d_armor:boots_bronze",		0.050,		7,		nil,		{1000,65000}	},
		
		{"3d_armor:helmet_diamond",		0.025,		10,		nil,		{1000,65000}	},
		{"3d_armor:chestplate_diamond",		0.025,		10,		nil,		{1000,65000}	},
		{"3d_armor:leggings_diamond",		0.025,		10,		nil,		{1000,65000}	},
		{"3d_armor:boots_diamond",		0.025,		10,		nil,		{1000,65000}	},
		
		{"3d_armor:helmet_gold",		0.015,		9,		nil,		{1000,65000}	},
		{"3d_armor:chestplate_gold",		0.015,		9,		nil,		{1000,65000}	},
		{"3d_armor:leggings_gold",		0.015,		9,		nil,		{1000,65000}	},
		{"3d_armor:boots_gold",			0.015,		9,		nil,		{1000,65000}	},
		
		{"3d_armor:helmet_mithril",		0.015,		10,		nil,		{1000,65000}	},
		{"3d_armor:chestplate_mithril",		0.015,		10,		nil,		{1000,65000}	},
		{"3d_armor:leggings_mithril",		0.015,		10,		nil,		{1000,65000}	},
		{"3d_armor:boots_mithril",		0.015,		10,		nil,		{1000,65000}	},
		
		{"3d_armor:helmet_crystal",		0.015,		10,		nil,		{1000,65000}	},
		{"3d_armor:chestplate_crystal",		0.015,		10,		nil,		{1000,65000}	},
		{"3d_armor:leggings_crystal",		0.015,		10,		nil,		{1000,65000}	},
		{"3d_armor:boots_crystal",		0.015,		10,		nil,		{1000,65000}	},
		
		{"shields:shield_wood",			0.200,		10,		nil,		{1000,65000}	},
		{"shields:shield_enhanced_wood",	0.180,		10,		nil,		{1000,65000}	},
		{"shields:shield_cactus",		0.200,		10,		nil,		{1000,65000}	},
		{"shields:shield_enhanced_cactus",	0.180,		10,		nil,		{1000,65000}	},
		{"shields:shield_steel",		0.100,		10,		nil,		{1000,65000}	},
		{"shields:shield_bronze",		0.050,		10,		nil,		{1000,65000}	},
		{"shields:shield_diamond",		0.015,		10,		nil,		{1000,65000}	},
		{"shields:shield_gold",			0.015,		9,		nil,		{1000,65000}	},
		{"shields:shield_mithril",		0.015,		10,		nil,		{1000,65000}	},
		{"shields:shield_crystal",		0.015,		10,		nil,		{1000,65000}	},
	}) do
		if minetest.registered_tools[d[1]] then
			local d_set = battle.get_loot_item_settings(d[1])
			if d_set == false then
				treasurer.register_treasure(unpack(d))
			end
		end
	end
end
