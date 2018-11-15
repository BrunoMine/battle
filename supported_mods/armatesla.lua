--[[
	Mod Battle para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Suporte para mod armatesla
  ]]

-- Carregar tesouros padrões
if minetest.get_modpath("treasurer") 
	and minetest.settings:get("battle_load_armatesla_loot_itens") ~= "false" then
	for _,d in ipairs({
	--	itemstring			raridade	preciosidade	qtd min e max	desgaste para ferramentas min e max
	--	"modname:item"			0.001 ~ 1.000	1 ~ 10		1 ~ 99		0 ~ 65535
		{"armatesla:antitesla",		0.300,		4,		{1,10},		nil	},
	}) do
		local d_set = battle.get_loot_item_settings(d[1])
		if d_set == false then
			treasurer.register_treasure(unpack(d))
		end
	end
end
