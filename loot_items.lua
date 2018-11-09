--[[
	Mod Battle para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Loots
  ]]

-- Status do sistema de loot
battle.loot_status = false
if minetest.settings:get("battle_enable_loot") == "true" then
	battle.loot_status = true
end


-- Variavel de controle de loot atual
battle.loot_number_control = tonumber(minetest.settings:get("battle_loot_number_control") or "1")


-- Redefinr numero do loot atual
battle.reset_loot = function()
	battle.loot_number_control = battle.loot_number_control + 1
	minetest.settings:set("battle_loot_number_control", battle.loot_number_control)
	minetest.settings:write()
end

-- Verifica se mod treasurer está ativo para continuar
if battle.loot_status == true and not minetest.get_modpath("treasurer") then
	minetest.log("error", "[Battle] Sistema de loot ativado mas inoperante por falta do mod treasurer")
	return 
end

-- Pega configuração fornecida pelo arquivo minetest.conf para editar itens especificos registrados por padrão
-- Exemplo: battle_set_item_loot_farming_bread = 0.600 4 1-10 nil
local get_loot_item_settings = function(name)
	local st = minetest.settings:get("battle_set_item_loot_"..string.gsub(name, ":", "_"))
	if not st then return false end
	if st == "disable" then return true end
	local d = st:split" "
	d = {
		["1"] = tonumber(d[1]),
		["2"] = tonumber(d[2]),
		["3"] = d[3],
		["4"] = d[4]
	}
	if d["3"] ~= "nil" then 
		d["3"] = d["3"]:split"-"
		d["3"][1] = tonumber(d["3"][1])
		d["3"][2] = tonumber(d["3"][2])
	else
		d["3"] = nil
	end
	if d["4"] ~= "nil" then 
		d["4"] = d["4"]:split"-"
		d["4"][1] = tonumber(d["4"][1])
		d["4"][2] = tonumber(d["4"][2])
	else
		d["4"] = nil
	end
	treasurer.register_treasure(name, d["1"], d["2"], d["3"], d["4"])
	return true
end

-- Carregar tesouros padrões
if minetest.settings:get("battle_load_default_loot_itens") ~= "false" then
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
		local d_set = get_loot_item_settings(d[1])
		if d_set == nil then
			treasurer.register_treasure(unpack(d))
		end
	end
end

-- Carrega armaduras
-- Verifica se mod treasurer está ativo para continuar
if minetest.get_modpath("3d_armor") 
	and minetest.settings:get("battle_load_armor_loot_itens") ~= "false" 
then
	for _,d in ipairs({
	--	itemstring				raridade	preciosidade	qtd min e max	desgaste para ferramentas min e max
	--	"modname:item"				0.001 ~ 1.000	1 ~ 10		1 ~ 99		0 ~ 65535
		{"3d_armor:helmet_wood",		0.700,		1,		nil,		{1000,65000}	},
		{"3d_armor:chestplate_wood",		0.700,		1,		nil,		{1000,65000}	},
		{"3d_armor:leggings_wood",		0.700,		1,		nil,		{1000,65000}	},
		{"3d_armor:boots_wood",			0.700,		1,		nil,		{1000,65000}	},
		
		{"3d_armor:helmet_cactus",		0.600,		1,		nil,		{1000,65000}	},
		{"3d_armor:chestplate_cactus",		0.600,		1,		nil,		{1000,65000}	},
		{"3d_armor:leggings_cactus",		0.600,		1,		nil,		{1000,65000}	},
		{"3d_armor:boots_cactus",		0.600,		1,		nil,		{1000,65000}	},
		
		{"3d_armor:helmet_steel",		0.400,		4,		nil,		{1000,65000}	},
		{"3d_armor:chestplate_steel",		0.400,		4,		nil,		{1000,65000}	},
		{"3d_armor:leggings_steel",		0.400,		4,		nil,		{1000,65000}	},
		{"3d_armor:boots_steel",		0.400,		4,		nil,		{1000,65000}	},
		
		{"3d_armor:helmet_bronze",		0.200,		7,		nil,		{1000,65000}	},
		{"3d_armor:chestplate_bronze",		0.200,		7,		nil,		{1000,65000}	},
		{"3d_armor:leggings_bronze",		0.200,		7,		nil,		{1000,65000}	},
		{"3d_armor:boots_bronze",		0.200,		7,		nil,		{1000,65000}	},
		
		{"3d_armor:helmet_diamond",		0.100,		10,		nil,		{1000,65000}	},
		{"3d_armor:chestplate_diamond",		0.100,		10,		nil,		{1000,65000}	},
		{"3d_armor:leggings_diamond",		0.100,		10,		nil,		{1000,65000}	},
		{"3d_armor:boots_diamond",		0.100,		10,		nil,		{1000,65000}	},
		
		{"3d_armor:helmet_gold",		0.100,		9,		nil,		{1000,65000}	},
		{"3d_armor:chestplate_gold",		0.100,		9,		nil,		{1000,65000}	},
		{"3d_armor:leggings_gold",		0.100,		9,		nil,		{1000,65000}	},
		{"3d_armor:boots_gold",			0.100,		9,		nil,		{1000,65000}	},
		
		{"3d_armor:helmet_mithril",		0.100,		10,		nil,		{1000,65000}	},
		{"3d_armor:chestplate_mithril",		0.100,		10,		nil,		{1000,65000}	},
		{"3d_armor:leggings_mithril",		0.100,		10,		nil,		{1000,65000}	},
		{"3d_armor:boots_mithril",		0.100,		10,		nil,		{1000,65000}	},
		
		{"3d_armor:helmet_crystal",		0.100,		10,		nil,		{1000,65000}	},
		{"3d_armor:chestplate_crystal",		0.100,		10,		nil,		{1000,65000}	},
		{"3d_armor:leggings_crystal",		0.100,		10,		nil,		{1000,65000}	},
		{"3d_armor:boots_crystal",		0.100,		10,		nil,		{1000,65000}	},
		
		{"shields:shield_wood",			0.700,		10,		nil,		{1000,65000}	},
		{"shields:shield_enhanced_wood",	0.600,		10,		nil,		{1000,65000}	},
		{"shields:shield_cactus",		0.700,		10,		nil,		{1000,65000}	},
		{"shields:shield_enhanced_cactus",	0.600,		10,		nil,		{1000,65000}	},
		{"shields:shield_steel",		0.400,		10,		nil,		{1000,65000}	},
		{"shields:shield_bronze",		0.200,		10,		nil,		{1000,65000}	},
		{"shields:shield_diamond",		0.100,		10,		nil,		{1000,65000}	},
		{"shields:shield_gold",			0.100,		9,		nil,		{1000,65000}	},
		{"shields:shield_mithril",		0.100,		10,		nil,		{1000,65000}	},
		{"shields:shield_crystal",		0.100,		10,		nil,		{1000,65000}	},
	}) do
		if minetest.registered_tools[d[1]] then
			local d_set = get_loot_item_settings(d[1])
			if d_set == false then
				treasurer.register_treasure(unpack(d))
			end
		end
	end
end

-- Função para colocar loots
local loot_nodes = {
	["default:chest"] = {
		status = true,
		qtd = {5, 10},
		valor = {1,10},
		list_name = "main",
	},
}

-- Altera on_rightclick
local old_on_rightclick = {}
for nn,loot in pairs(loot_nodes) do
	if battle.loot_status == true then
		old_on_rightclick[nn] = minetest.registered_nodes[nn].on_rightclick
		minetest.override_item(nn, {
			on_rightclick = function(pos, node, player, itemstack, pointed_thing)
				local meta = minetest.get_meta(pos)
				-- Verifica se ja foi carregado
				if tonumber(meta:get_string("battle:loot_number")) ~= battle.loot_number_control then
					-- Verifica se existe esse tipo de node na tabela de loots
					local amount = math.random(loot.qtd[1], loot.qtd[2])

					local treasures = treasurer.select_random_treasures(amount, loot.valor[1], loot.valor[2])

					local meta = minetest.get_meta(pos)
					local inv = meta:get_inventory()
					
					for i=1,#treasures do
						inv:set_stack(loot.list_name, i, treasures[i])
					end
					
					-- Salva como carregado
					meta:set_string("battle:loot_number", battle.loot_number_control)
				end
				if old_on_rightclick[nn] then
					return old_on_rightclick[nn](pos, node, player, itemstack, pointed_thing)
				end
			end
		})
	end
end

