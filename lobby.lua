--[[
	Mod Battle para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Lobby dos jogadores
  ]]

-- Tradutor de texto
local S = battle.S

-- Tabela de participantes
battle.ingame = {}

-- Status de jogo
battle.game_status = false
battle.game_number = 0

-- Inicio automatico da batalha
battle.auto_start = false
if minetest.settings:get("battle_enable_auto_start") == "true" then
	battle.auto_start = true
end

-- Modo de jogo selecionado
battle.selec_mode = minetest.settings:get("battle_game_mode") or "shg"

-- Arena selecionada
battle.selec_arena = minetest.settings:get("battle_arena") or ""

-- Desativa carregamento forçado de barras do hudbars
if minetest.get_modpath("hudbars") then
	hb.settings.forceload_default_hudbars = false
end

-- Spawn
battle.get_lobby_pos = function()
	local lobby_pos = minetest.string_to_pos(minetest.settings:get("static_spawnpoint") or "0 20 0")
	if battle.selec_arena ~= "" 
		and battle.arena.tb[battle.selec_arena]
		and battle.arena.tb[battle.selec_arena].lobby_pos
	then
		lobby_pos = battle.arena.tb[battle.selec_arena].lobby_pos
	end
	return lobby_pos
end

-- Registra modelo de lobby
player_api.register_model("lobby.obj", {
	animation_speed = 30,
	textures = {"lobby.png"},
	animations = {
		-- Standard animations.
		stand     = {x = 0,   y = 1},
		lay       = {x = 0,   y = 1},
		walk      = {x = 0,   y = 1},
		mine      = {x = 0,   y = 1},
		walk_mine = {x = 0,   y = 1},
		sit       = {x = 0,   y = 1},
	},
	collisionbox = {-0.001, -0.001, -0.001, 0.001, 0.001, 0.001},
	stepheight = 0.1,
	eye_height = 0.1,
})

-- Chamada ao resetar atributos
local registered_on_reset_bars = {}
battle.register_on_reset_bars = function(func)
	table.insert(registered_on_reset_bars, func)
end

battle.reset_bars = function(name)
	-- Verifica se jogador está em jogo
	if battle.game_status == true and battle.ingame[name] then return end
	local player = minetest.get_player_by_name(name)
	if not player then return end
	
	-- Restaura atributos
	if player:get_hp() < 20 then player:set_hp(20) end
	if player:get_breath() < 10 then player:set_breath(10) end
	
	-- Executa chamadas registradas
	for _,func in ipairs(registered_on_reset_bars) do
		func(name)
	end
	
	minetest.after(15, battle.reset_bars, name)
end

-- Chamada ao entrar no lobby
local registered_on_join_lobby = {}
battle.register_on_join_lobby = function(func)
	table.insert(registered_on_join_lobby, func)
end

-- Colocar jogador no lobby
battle.join_lobby = function(player)
	local name = player:get_player_name()
	
	-- Executa chamadas registradas
	for _,func in ipairs(registered_on_join_lobby) do
		func(player)
	end
	
	-- Define modelo de animação
	player_api.set_model(player, "lobby.obj")
	
	-- Da privilegio de voô e mantem voando
	battle.c.grant_privs(name, {fly=true, fast=true, noclip=true})
	
	-- Oculta nome
	player:set_nametag_attributes({color = {a = 0, r = 255, g = 255, b = 255}})
	
	-- Inventario e privilegios 
	if minetest.check_player_privs(name, {server=true}) == false then
		battle.set_normal_lobby_inv(player)
		battle.c.revoke_privs(name, {interact=true})
	end
	
	-- Inscreve para a proxima partida automaticamente se definido
	if battle.auto_join == true 
		and battle.game_status == false
		and minetest.check_player_privs(name, {server=true}) == false 
	then
		battle.ingame[name] = player
	end
	
	-- Inicia loop que impede atributos alterarem
	minetest.after(1.5, battle.reset_bars, name)
	
	-- Coordenada
	player:setpos(battle.get_lobby_pos())
end

-- Tirar jogador do lobby
battle.leave_lobby = function(player)
	local name = player:get_player_name()
	
	-- Restaura caracteristicas do jogador comum
	battle.player.reset(player)
	
	-- Exibe nome
	player:set_nametag_attributes({color = {a = 255, r = 255, g = 255, b = 255}})
	
	-- Remove privilegios do lobby
	battle.c.revoke_privs(name, {fly=true, fast=true, noclip=true})
	battle.c.grant_privs(name, {interact=true})
end

-- Direciona o jogador ao entrar no servidor
minetest.register_on_joinplayer(function(player)
	if not player then return end
	local name = player:get_player_name()
	
	-- Verifica se está em jogo
	if battle.ingame[name] then
		return 
		
	-- Não está fazendo nada
	else
		battle.join_lobby(player)
	end
	
end)

-- Iniciar jogo
battle.start = function()
	-- Modo de jogo
	local gm = battle.modes[battle.selec_mode]
	
	-- Limpa objetos
	minetest.chat_send_all(S("Limpando arena"))
	minetest.clear_objects("full")
	
	-- Verifica jogo e arena escolhidos
	if battle.selec_arena == nil or battle.selec_mode == nil then
		return false, S("Escolha o modo e a arena")
	end
	
	-- Verifica limite de jogadores
	if battle.c.count_tb(battle.ingame) < gm.min_players then
		return false, S("Poucos jogadores")
	end
	if battle.c.count_tb(battle.ingame) > gm.max_players then
		return false, S("Excesso jogadores")
	end
	
	-- Inicia jogo
	local r, msg = gm.start()
	if r == false then
		return false, msg
	end
	
	-- Troca loot dos nodes do mod treasures_loot_nodes
	if battle.loot_status == true then
		battle.reset_loot()
	end
	
	return true
end

-- Encerra batalha
battle.finish = function()
	
	battle.game_status = false
	battle.set_pvp(false)
	
	-- Inscreve todos jogadores que estao aguardando
	if battle.auto_join == true then
		for _,player in ipairs(minetest.get_connected_players()) do
			local name = player:get_player_name()
			if minetest.check_player_privs(name, {server=true}) == false then
				battle.ingame[name] = player
			end
		end
	end
end


minetest.register_chatcommand("start", {
	params = "",
	description = S("Inicia a partida"),
	func = function(name, param)
		local r, msg = battle.start()
		if r == false then
			minetest.chat_send_player(name, S("Impossivel inicar partida. @1", msg))
			return
		end
		minetest.chat_send_all(S("Partida iniciada"))
	end,
})

-- Receptor de campos
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.play_battle then
		local name = player:get_player_name()
		
		-- Partida ja em curso
		if battle.game_status == true then
			minetest.chat_send_player(name, S("Aguarde o final da partida atual"))
			return
		end
		
		local gm = battle.modes[battle.selec_mode]
		
		-- Verifica se tem vagas
		if battle.c.count_tb(battle.ingame) > gm.max_players then
			minetest.chat_send_player(name, S("Todas as vagas dessa batalha ja foram preenchidas"))
			return
		end
		
		-- Inscreve
		battle.ingame[name] = player
		minetest.chat_send_player(name, S("Foste inscrito para a proxima batalha, aguarde"))
		return
	end
	
end)

-- Ajuste no sfinv para evitar retorno normal
local old_cmd = sfinv.set_player_inventory_formspec
sfinv.set_player_inventory_formspec = function(player, context)
	-- Verifica se está com inventario de lobby
	if minetest.check_player_privs(player:get_player_name(), {server=true}) == false
		and battle.game_status == true and battle.ingame[player:get_player_name()]
	then
		return old_cmd(player, context)
	else
		battle.set_normal_lobby_inv(player)
	end
end
