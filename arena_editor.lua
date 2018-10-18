--[[
	Mod Battle para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Editor de arenas
  ]]

-- Tabela de Acesso
local acessos = {}

-- String e tabela de modos
local game_modes_st = ""
local game_modes_tb = {}
local game_modes_tbn = {}
local game_modes_tbnr = {}

-- Strings e tabela de paremostros de cada modo
local game_mode_params = {}
local update_game_mode_params = function(id, n)
	game_mode_params[n] = {}
	game_mode_params[n].st = ""
	game_mode_params[n].tb = {}
	game_mode_params[n].tbn = {}
	game_mode_params[n].tbnr = {}
	game_mode_params[n].dados = {}
	-- Titulo
	game_mode_params[n].st = "Titulo"
	table.insert(game_mode_params[n].tbn, "Titulo")
	game_mode_params[n].tb["Titulo"] = id
	game_mode_params[n].tbnr["Titulo"] = table.maxn(game_mode_params[n].tbn)
	game_mode_params[n].dados["Titulo"] = {
		name = "Titulo",
		format = "string",
		desc = "Nome exibido ao usuario",
		index_name = "titulo",
	}
	-- Demais parametros
	for id,d in pairs(battle.modes[id].params) do
		game_mode_params[n].st = game_mode_params[n].st .. "," .. d.name
		table.insert(game_mode_params[n].tbn, d.name)
		game_mode_params[n].tb[d.name] = id
		game_mode_params[n].tbnr[d.name] = table.maxn(game_mode_params[n].tbn)
		game_mode_params[n].dados[d.name] = d
	end
end

-- Atualiza listas e tabelas
local update_game_modes = function()
	game_modes_st = ""
	game_modes_tb = {}
	game_modes_tbn = {}
	game_modes_tbnr = {}
	for id,d in pairs(battle.modes) do
		if game_modes_st ~= "" then game_modes_st = game_modes_st .. "," end
		game_modes_st = game_modes_st .. d.titulo
		table.insert(game_modes_tbn, d.titulo)
		game_modes_tb[d.titulo] = id
		game_modes_tbnr[d.titulo] = table.maxn(game_modes_tbn)
		update_game_mode_params(id, table.maxn(game_modes_tbn))
	end
end

-- String e tabela de arenas
local arenas_st = ""
local arenas_tb = {}
local arenas_tbn = {}
local arenas_tbnr = {}
local update_arenas = function()
	arenas_st = ""
	arenas_tb = {}
	arenas_tbn = {}
	arenas_tbnr = {}
	for id,d in pairs(battle.arena.tb) do
		if arenas_st ~= "" then arenas_st = arenas_st .. "," end
		arenas_st = arenas_st .. d.titulo
		table.insert(arenas_tbn, d.titulo)
		arenas_tb[d.titulo] = id
		arenas_tbnr[d.titulo] = table.maxn(arenas_tbn)
	end
end

-- Acessar menu do editor
local acessar = function(player)
	if not player then return end
	local name = player:get_player_name()
	local ac = acessos[name]
	
	-- Atualiza listas
	update_game_modes()
	update_arenas()
	
	-- Redirecionar para arena
	if ac.ver_arena then
		ac.arena = arenas_tbnr[battle.arena.tb[ac.ver_arena].titulo]
		ac.ver_arena = nil
	end
	
	local formspec = "size[10,8]"
		..default.gui_bg
		..default.gui_bg_img
		.."dropdown[0,1.1;10.5,1;modo;"..game_modes_st..";"..ac.modo.."]"
		.."dropdown[0,0.1;5,1;arena;"..arenas_st..";"..ac.arena.."]"
		.."button_exit[4.9,0;2,1;deletar;Deletar]"
		.."button_exit[6.9,0;3,1;criar;Criar Arena]"
		.."textlist[4.75,2;5,6;param;"..game_mode_params[ac.modo].st..";"..ac.param.."]"
	
	-- Painel de edição de parâmetro
	local dados_param = game_mode_params[ac.modo].dados[game_mode_params[ac.modo].tbn[ac.param]]
	local dados_arena = {}
	if table.maxn(arenas_tbn) >= 1 then
		dados_arena = battle.arena.tb[arenas_tb[arenas_tbn[ac.arena]]]
	end
	
	-- Caixa de habilitar jogo
	if dados_arena.modes and dados_arena.modes[battle.selec_mode] == true then
		formspec = formspec .. "checkbox[0,7.4;status_game;Habilitar jogo;true]"
	else
		formspec = formspec .. "checkbox[0,7.4;status_game;Habilitar jogo;false]"
	end
	
	-- String
	if dados_param.format == "string" then
		formspec = formspec
			.."field[0.3,2.8;4.5,1;texto;"..dados_param.name..";"..(dados_arena.titulo or "-").."]"
			.."button[0,3.4;4.5,1;salvar_string;Salvar]"
			.."textarea[0.3,4.4;4.5,3.5;;"..dados_param.desc..";]"
			
	-- Int
	elseif dados_param.format == "int" then
		formspec = formspec 
			.."field[0.3,2.8;4.5,1;numero;"..dados_param.name..";"..(dados_arena.titulo or "-").."]"
			.."button[0,3.4;4.5,1;salvar_int;Salvar]"
			.."textarea[0.3,4.4;4.5,3.5;;"..dados_param.desc..";]"
	
	-- Coordenada
	elseif dados_param.format == "pos" then
		local stpos = dados_arena[dados_param.index_name] or "-"
		if stpos ~= "-" then
			stpos = minetest.pos_to_string(stpos)
		end
		formspec = formspec 
			.."label[0,2;"..dados_param.name.."]"
			.."label[0,2.7;"..stpos.."]"
			.."button_exit[0,3.4;2.5,1;redefinir_pos;Redefinir]"
			.."button[2.5,3.4;2,1;teleportar;Teleportar]"
			.."textarea[0.3,4.4;4.5,3.5;;"..dados_param.desc..";]"
		
		-- Salva coordenada para teleportar
		ac.pos_vista = dados_arena[dados_param.index_name]
	end
	
	
	minetest.show_formspec(name, "battle:arena_editor", formspec)
end


-- Receptor de campos
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "battle:arena_editor" then
		local name = player:get_player_name()
		
		-- Escolher arena	
		if fields.arena and fields.arena ~= "" and acessos[name].arena ~= arenas_tbnr[fields.arena] then
			acessos[name].arena = arenas_tbnr[fields.arena]
			acessos[name].modo = 1
			acessos[name].param = 1
			acessar(player)
			return
		end
		
		-- Escolher modo
		if fields.modo and acessos[name].modo ~= game_modes_tbnr[fields.modo] then
			acessos[name].modo = game_modes_tbnr[fields.modo]
			acessos[name].param = 1
			acessar(player)
			return
		end
		
		-- Escolher param
		if fields.param then
			local n = string.split(fields.param, ":")
			acessos[name].param = tonumber(n[2])
			acessar(player)
			return
		end
		
		-- Teleportar para coordenada
		if fields.teleportar and acessos[name].pos_vista then
			player:setpos(acessos[name].pos_vista)
			return
		end
		
		-- Salvar string
		if fields.salvar_string and fields.texto ~= "" and table.maxn(arenas_tbn) >= 1 then
			local ac = acessos[name]
			local dados_param = game_mode_params[ac.modo].dados[game_mode_params[ac.modo].tbn[ac.param]]
			if dados_param.index_name == "titulo" and arenas_tb[fields.texto] ~= nil then
				minetest.chat_send_player(name, "Esse titulo de arena ja foi usado")
				acessar(player)
				return
			end
			-- Redireciona para novo titulo
			if dados_param.index_name == "titulo" then
				ac.ver_arena = arenas_tb[arenas_tbn[ac.arena]]
			end
			battle.arena.tb[arenas_tb[arenas_tbn[ac.arena]]][dados_param.index_name] = fields.texto
			battle.arena.salvar_bd()
			acessar(player)
			return
		end
		
		-- Salvar int
		if fields.salvar_int and tonumber(fields.numero) and table.maxn(arenas_tbn) >= 1 then
			local ac = acessos[name]
			local dados_param = game_mode_params[ac.modo].dados[game_mode_params[ac.modo].tbn[ac.param]]
			battle.arena.tb[arenas_tb[arenas_tbn[ac.arena]]][dados_param.index_name] = tonumber(fields.texto)
			battle.arena.salvar_bd()
			acessar(player)
			return
		end
		
		-- Habilitar modo de jogo
		if fields.status_game then
			if table.maxn(arenas_tbn) == 0 then
				acessar(player)
				return
			end
			local ac = acessos[name]
			local dados_param = game_mode_params[ac.modo].dados[game_mode_params[ac.modo].tbn[ac.param]]
			local v = false
			if fields.status_game == "true" then v = true end
			if not battle.arena.tb[arenas_tb[arenas_tbn[ac.arena]]].modes then
				battle.arena.tb[arenas_tb[arenas_tbn[ac.arena]]].modes = {}
			end
			battle.arena.tb[arenas_tb[arenas_tbn[ac.arena]]].modes[game_modes_tb[game_modes_tbn[ac.modo]]] = v
			battle.arena.salvar_bd()
			acessar(player)
			return
		end
		
		-- Redefinir pos
		if fields.redefinir_pos and table.maxn(arenas_tbn) >= 1 then
			local ac = acessos[name]
			local dados_param = game_mode_params[ac.modo].dados[game_mode_params[ac.modo].tbn[ac.param]]
			ac.find_pos_param = dados_param.index_name
			return
		end
		
		-- Criar arena
		if fields.criar then
			acessos[name].new_pos1 = true
			minetest.chat_send_player(name, "Bata no primeiro limite da arena")
			return
		end
		
		-- Deletar arena
		if fields.deletar then
			battle.deletar_arena(arenas_tb[arenas_tbn[acessos[name].arena]])
			minetest.chat_send_player(name, "Arena Deletada")
			acessos[name] = nil
			return
		end
	end
end)

-- Editor de Arena
minetest.register_craftitem("battle:arena_editor", {
	description = "Editor de Arena",
	stack_max = 1,
	inventory_image = "battle_arena_editor.png",
	on_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		
		-- Verificar privilegio de acesso
		if minetest.check_player_privs(name, {server=true}) ~= true then
			minetest.chat_send_player(name, "Acesso negado.")
			return
		end
		
		-- Estabelecer acesso
		if not acessos[name] then
			acessos[name] = {
				modo = 1,
				param = 1,
				arena = 1,
			}
		end
		
		-- Verifica se estava redefinindo algum parametro
		if acessos[name].find_pos_param then
			if pointed_thing.under then
				battle.arena.tb[arenas_tb[arenas_tbn[acessos[name].arena]]][acessos[name].find_pos_param] = battle.c.copy_tb(pointed_thing.under)
				acessos[name].find_pos_param = nil
				minetest.chat_send_player(name, "Parametro de coordenada definido")
				battle.arena.salvar_bd()
				return
			else
				minetest.chat_send_player(name, "Precisa bater num bloco na coordenada desejada")
				return			
			end
		end
		
		-- Verifica se está definindo 
		if acessos[name].new_pos1 == true then
			if pointed_thing.under then
				acessos[name].new_pos1 = battle.c.copy_tb(pointed_thing.under)
				acessos[name].new_pos2 = true
				minetest.chat_send_player(name, "Primeiro limite definido. Bata no segundo limite da arena")
				return
			else
				minetest.chat_send_player(name, "Precisa bater num bloco na coordenada desejada")
				return
			end
		end
		if acessos[name].new_pos2 == true then
			if pointed_thing.under then
				acessos[name].new_pos2 = battle.c.copy_tb(pointed_thing.under)
				battle.registrar_arena(acessos[name].new_pos1, acessos[name].new_pos2)
				minetest.chat_send_player(name, "Arena "..battle.arena.total.." criada. Acesse o Editor para ajustar parametros")
				return
			else
				minetest.chat_send_player(name, "Precisa bater num bloco na coordenada desejada")
				return
			end
		end
		
		minetest.after(0.8, acessar, user)
	end,
})
