--[[
	Mod Battle para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Inventario dos jogadores no Lobby
  ]]

-- Tradutor de texto
local S = battle.S

-- Formspec de jogador normal
battle.set_normal_lobby_inv = function(player)
	local formspec = ""
	if battle.auto_join == false then 
		formspec = "size[3,1]"
			..default.gui_bg
			..default.gui_bg_img
			.."button_exit[0,0;3,1;play_battle;"..S("Jogar").."]"
	else
		formspec = "size[7,1]"
			..default.gui_bg
			..default.gui_bg_img
			.."label[0,0;"..S("Aguarde a proxima partida").."]"
	end
	player:set_inventory_formspec(formspec)
end

-- Formspec de moderador
battle.set_staff_lobby_inv = function(player)
	return
end

-- String e tabela de arenas
local arenas_st = ""
local arenas_tb = {}
local arenas_tbn = {}
local arenas_tbnr = {}
local arenas_i = {}
local update_arenas = function()
	arenas_st = ""
	arenas_tb = {}
	arenas_tbn = {}
	arenas_tbnr = {}
	arenas_i = {}
	local i = 0
	for id,d in pairs(battle.arena.tb) do
		if arenas_st ~= "" then arenas_st = arenas_st .. "," end
		arenas_st = arenas_st .. d.titulo
		table.insert(arenas_tbn, d.titulo)
		arenas_tb[d.titulo] = id
		arenas_tbnr[d.titulo] = table.maxn(arenas_tbn)
		i = i + 1
		arenas_i[id] = i
	end
end

-- String e tabela de modos
local game_modes_st = ""
local game_modes_tb = {}
local game_modes_tbn = {}
local game_modes_tbnr = {}
local game_modes_i = {}
-- Atualiza listas e tabelas
local update_game_modes = function()
	game_modes_st = ""
	game_modes_tb = {}
	game_modes_tbn = {}
	game_modes_tbnr = {}
	game_modes_i = {}
	local i = 0
	for id,d in pairs(battle.modes) do
		if game_modes_st ~= "" then game_modes_st = game_modes_st .. "," end
		game_modes_st = game_modes_st .. d.titulo
		table.insert(game_modes_tbn, d.titulo)
		game_modes_tb[d.titulo] = id
		game_modes_tbnr[d.titulo] = table.maxn(game_modes_tbn)
		i = i + 1
		game_modes_i[id] = i
	end
end

-- Aba de gerenciamento das partidas
-- Registrar aba 'battle'
gestor.registrar_aba("battle", {
	titulo = S("Batalhas"),
	get_formspec = function(name)
		
		-- Atualiza listas
		update_game_modes()
		update_arenas()
		
		local formspec = "label[3.5,1;"..S("Batalhas").."]"
			.."dropdown[3.5,2.7;10.5,1;modo;"..game_modes_st..";"..game_modes_i[battle.selec_mode].."]"
		
		-- Seleciona o primeiro se possivel
		if battle.selec_arena == "" and table.maxn(arenas_tbn) > 0 then
			battle.selec_arena = arenas_tb[arenas_tbn[1]]
			minetest.settings:set("battle_arena", battle.selec_arena)
			minetest.settings:write()
		end
		
		if battle.selec_arena ~= "" and arenas_i[battle.selec_arena] then
			formspec = formspec.."dropdown[3.5,1.7;10.5,1;arena;"..arenas_st..";"..arenas_i[battle.selec_arena].."]"
		else
			formspec = formspec.."dropdown[3.5,1.7;10.5,1;arena;"..arenas_st..";]"
		end
		
		-- Caixa de habilitar auto inicio
		if battle.auto_start == true then
			formspec = formspec .. "checkbox[3.5,3.5;auto_start;"..S("Inicio automatico de Batalhas")..";true]"
		else
			formspec = formspec .. "checkbox[3.5,3.5;auto_start;"..S("Inicio automatico de Batalhas")..";false]"
		end
		
		-- Caixa de habilitar auto inscrição
		if battle.auto_join == true then
			formspec = formspec .. "checkbox[3.5,4;auto_join;"..S("Inscrever automaticamente para Batalhas")..";true]"
		else
			formspec = formspec .. "checkbox[3.5,4;auto_join;"..S("Inscrever automaticamente para Batalhas")..";false]"
		end
		
		return formspec
	end,
	on_receive_fields = function(player, fields)
		local name = player:get_player_name()
		
		-- Alterar arena
		if fields.arena and fields.arena ~= "" then
			battle.selec_arena = arenas_tb[fields.arena]
			minetest.settings:set("battle_arena", battle.selec_arena)
			minetest.settings:write()
			gestor.menu_principal(name)
		end
		
		-- Alterar modo
		if fields.modo then
			battle.selec_mode = game_modes_tb[fields.modo]
			minetest.settings:set("battle_game_mode", battle.selec_mode)
			minetest.settings:write()
			gestor.menu_principal(name)
		end
		
		-- Habilitar auto inicio
		if fields.auto_start then
			local v = false
			if fields.auto_start == "true" then 
				v = true 
				battle.auto_start_check()
			end
			battle.auto_start = v
			minetest.settings:set("battle_enable_auto_start", fields.auto_start)
			minetest.settings:write()
			gestor.menu_principal(name)
		end
		
		-- Habilitar auto inscrição
		if fields.auto_join then
			local v = false
			if fields.auto_join == "true" then 
				v = true 
			end
			battle.auto_join = v
			minetest.settings:set("battle_enable_auto_join_battle", fields.auto_join)
			minetest.settings:write()
			gestor.menu_principal(name)
		end
	end,
})
