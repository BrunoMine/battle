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
if not minetest.get_modpath("treasurer") then
	return 
end

-- Carregar tesouros padrões
if minetest.settings:get("battle_load_default_loot_itens") ~= "true" then
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
		treasurer.register_treasure(unpack(d))
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
	if loot.status == true then
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

