--[[
	Mod Battle para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Suporte para mod cannons
  ]]

if minetest.get_modpath("cannons") == nil then return end


-- Altera on_rightclick
local old_on_rightclick = {}
local old_on_punch = {}
for _,nn in ipairs({
		"cannons:ship_stand_with_cannon_steel",
		"cannons:wood_stand_with_cannon_steel",
		"cannons:ship_stand_with_cannon_bronze",
		"cannons:wood_stand_with_cannon_bronze"
	}) do
	if battle.loot_status == true then
		old_on_rightclick[nn] = minetest.registered_nodes[nn].on_rightclick
		old_on_punch[nn] = minetest.registered_nodes[nn].on_punch
		minetest.override_item(nn, {
			on_rightclick = function(pos, node, player, itemstack, pointed_thing)
				local meta = minetest.get_meta(pos)
				-- Verifica se ja foi carregado
				if tonumber(meta:get_string("battle:battle_number")) ~= battle.game_number then
					
					-- Zera munição e polvora
					local inv = meta:get_inventory()
					inv:set_stack("gunpowder", 1, "")
					inv:set_stack("muni", 1, "")
					
					-- Salva como carregado
					meta:set_string("battle:battle_number", battle.game_number)
				end
				if old_on_rightclick[nn] then
					return old_on_rightclick[nn](pos, node, player, itemstack, pointed_thing)
				end
			end,
			on_punch = function(pos, node, puncher)
				local meta = minetest.get_meta(pos)
				-- Verifica se ja foi carregado
				if tonumber(meta:get_string("battle:battle_number")) ~= battle.game_number then
					
					-- Zera munição e polvora
					local inv = meta:get_inventory()
					inv:set_stack("gunpowder", 1, "")
					inv:set_stack("muni", 1, "")
					
					-- Salva como carregado
					meta:set_string("battle:battle_number", battle.game_number)
				end
				if old_on_punch[nn] then
					return old_on_punch[nn](pos, node, puncher)
				end
			end,
		})
	end
end

-- Carregar armaduras
if minetest.get_modpath("treasurer") 
	and minetest.settings:get("battle_load_cannons_loot_itens") ~= "false" then
	for _,d in ipairs({
	--	itemstring				raridade	preciosidade	qtd min e max	desgaste para ferramentas min e max
	--	"modname:item"				0.001 ~ 1.000	1 ~ 10		1 ~ 99		0 ~ 65535
		{"cannons:ball_wood_stack_1",		0.150,		2,		{1,5},		nil	},
		{"cannons:ball_stone_stack_1",		0.100,		4,		{1,5},		nil	},
		{"cannons:ball_steel_stack_1",		0.050,		6,		{1,5},		nil	},
		{"tnt:gunpowder",			0.200,		2,		{1,5},		nil	},
		
	}) do
		if minetest.registered_items[d[1]] then
			local d_set = battle.get_loot_item_settings(d[1])
			if d_set == false then
				treasurer.register_treasure(unpack(d))
			end
		end
	end
end
