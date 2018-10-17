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

-- Modo de jogo selecionado
battle.selec_mode = "shg"

-- Arena selecionada
battle.selec_arena = "default"

-- Spawn
local lobby_pos = minetest.string_to_pos(minetest.settings:get("static_spawnpoint") or "0 20 0")

-- Configura novos jogadores
minetest.register_on_newplayer(function(player)
	if not player then return end
	player:set_attribute("status", "wait")
end)

-- Direciona o jogador ao entrar no servidor
minetest.register_on_joinplayer(function(player)
	if not player then return end
	local status = player:get_attribute("status")
	local name = player:get_player_name()
	
	-- Verifica se está em jogo
	if battle.ingame[name] then
		return 
		
	-- Não está fazendo nada
	else
		player:set_attribute("status", "wait")
		player:setpos(lobby_pos)
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
	
	return true
end


minetest.register_chatcommand("start", {
	params = "",
	description = "Inicia a partida",
	func = function(name, param)
		local r, msg = battle.start()
		if r == false then
			minetest.chat_send_player(name, "Impossivel inicar partida. "..msg)
		end
		minetest.chat_send_player(name, "Partida iniciada")
	end,
})

