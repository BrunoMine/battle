--[[
	Mod Battle para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Lobby dos jogadores
  ]]

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

-- Spawn
local lobby_pos = minetest.string_to_pos(minetest.settings:get("static_spawnpoint") or "0 20 0")

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


-- Colocar jogador no lobby
battle.join_lobby = function(player)
	local name = player:get_player_name()
	
	-- Remove armaduras
	if armor then
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
	end
	
	-- Define modelo de animação
	player_api.set_model(player, "lobby.obj")
	
	-- Da privilegio de voô e mantem voando
	battle.c.grant_privs(name, {fly=true, noclip=true})
	
	-- Oculta nome
	player:set_nametag_attributes({color = {a = 0, r = 255, g = 255, b = 255}})
	
	-- Inventario e privilegios 
	-- Moderador
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
	
	-- Coordenada
	player:setpos(lobby_pos)
end

-- Tirar jogador do lobby
battle.leave_lobby = function(player)
	local name = player:get_player_name()
	
	-- Restaura caracteristicas do jogador comum
	battle.player.reset(player)
	
	-- Exibe nome
	player:set_nametag_attributes({color = {a = 255, r = 255, g = 255, b = 255}})
	
	-- Remove privilegios do lobby
	battle.c.revoke_privs(name, {fly=true, noclip=true})
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
	
	-- Verifica jogo e arena escolhidos
	if battle.selec_arena == nil or battle.selec_mode == nil then
		return false, "Escolha o modo e a arena"
	end
	
	-- Verifica limite de jogadores
	if battle.c.count_tb(battle.ingame) < gm.min_players then
		return false, "Poucos jogadores"
	end
	if battle.c.count_tb(battle.ingame) > gm.max_players then
		return false, "Excesso jogadores"
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
	description = "Inicia a partida",
	func = function(name, param)
		local r, msg = battle.start()
		if r == false then
			minetest.chat_send_player(name, "Impossivel inicar partida. "..msg)
			return
		end
		minetest.chat_send_all("Partida iniciada")
	end,
})

-- Receptor de campos
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.play_battle then
		local name = player:get_player_name()
		
		-- Partida ja em curso
		if battle.game_status == true then
			minetest.chat_send_player(name, "Aguarde o final da partida atual")
			return
		end
		
		local gm = battle.modes[battle.selec_mode]
		
		-- Verifica se tem vagas
		if battle.c.count_tb(battle.ingame) > gm.max_players then
			minetest.chat_send_player(name, "Todas as vagas dessa batalha ja foram preenchidas")
			return
		end
		
		-- Inscreve
		battle.ingame[name] = player
		minetest.chat_send_player(name, "Foste inscrito para a proxima batalha, aguarde")
		return
	end
end)
