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
	
	local formspec = "size[10,8]"
		..default.gui_bg
		..default.gui_bg_img
		.."dropdown[0,1.1;10.5,1;modo;"..game_modes_st..";"..ac.modo.."]"
		.."dropdown[0,0.1;7,1;arena;"..arenas_st..";"..ac.arena.."]"
		.."button_exit[6.9,0;3,1;criar;Criar Arena]"
		.."textlist[4.75,2;5,6;param;"..game_mode_params[ac.modo].st..";"..ac.param.."]"
	
	-- Painel de edição de parâmetro
	local dados_param = game_mode_params[ac.modo].dados[game_mode_params[ac.modo].tbn[ac.param]]
	formspec = formspec 
		.."label[0,2;"..dados_param.name.."]"
	
	
	minetest.show_formspec(name, "battle:arena_editor", formspec)
end


-- Receptor de campos
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "battle:arena_editor" then
		local name = player:get_player_name()
		minetest.chat_send_all(dump(fields))
		
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
		
		minetest.after(0.8, acessar, user)
	end,
})
