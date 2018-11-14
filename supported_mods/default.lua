--[[
	Mod Battle para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Suporte para mod default
  ]]

-- Carregar tesouros padrões
if minetest.get_modpath("treasurer") 
	and minetest.settings:get("battle_load_default_loot_itens") ~= "false" then
	for _,d in ipairs({
	--	itemstring			raridade	preciosidade	qtd min e max	desgaste para ferramentas min e max
	--	"modname:item"			0.001 ~ 1.000	1 ~ 10		1 ~ 99		0 ~ 65535
		{"farming:bread",		0.600,		4,		{1,10},		nil	},
		{"default:apple",		0.900,		2,		{1,25},		nil	},
		{"default:sword_wood",		0.800,		1,		nil,		{1000,65000}	},
		{"default:sword_stone",		0.600,		2,		nil,		{1000,65000}	},
		{"default:sword_steel",		0.400,		4,		nil,		{1000,65000}	},
		{"default:sword_bronze",	0.200,		6,		nil,		{1000,65000}	},
		{"default:sword_mese",		0.080,		8,		nil,		{1000,65000}	},
		{"default:sword_diamond",	0.020,		10,		nil,		{1000,65000}	},
	}) do
		local d_set = battle.get_loot_item_settings(d[1])
		if d_set == false then
			treasurer.register_treasure(unpack(d))
		end
	end
end
