--[[
	Mod Battle para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Modo de jogo: Simple Hungry Games (jogos vorazes simples)
	
	Descrição:
	Nesse modo os jogadores aparecem num mesmo lugar da arena.
	Após um tempo o PvP é liberado.
	O último vivo ganha.
	Após um tempo a partida pode ser encerrada a força sem ganhadores.
	Se um jogador desconectar perde automaticamente a partida.
	Para poucos jogadores
  ]]

-- Tabela do modo
battle.modes.shg = {}

-- Titulo
battle.modes.shg.titulo = "Jogos Vorazes Simples"

-- Parametros
battle.modes.shg.params = {
	-- Coordenada do Spawn da Arena
	{
		name = "Spawn da Partida",
		format = "pos",
		desc = "Coordenada onde os jogadores vão surgir no inicio da partida",
		index_name = "spawn",
	},
}

-- Limites de jogadores
battle.modes.shg.min_players = 2
battle.modes.shg.max_players = 8

-- Verificar arena
battle.modes.shg.check_arena = function(arena)
	local tb = battle.arena.tb[arena]
	
	-- Coordenada de spawn da arena
	if not tb.spawn then
		return false, "Faltou o spawn da arena"
	end
	
	return true
end

-- Retorna jogadores para o lobby
local send_all_to_lobby = function()
	for name,player in pairs(battle.ingame) do
		battle.ingame[name] = nil -- Desinscreve jogador
		battle.join_lobby(player)
	end
end

-- Verificar vitoria
local check_win = function()
	-- Verifica se resta apenas 1 vivo
	if battle.c.count_tb(battle.ingame) > 1 then return end
	
	-- Encerra batalha
	for name, winner in pairs(battle.ingame) do
		battle.ingame[name] = nil
		battle.join_lobby(winner)
		minetest.chat_send_all(name.." venceu a batalha")
	end
	
	battle.finish()
end

-- Verificar da partida
battle.modes.shg.check_game = function(game_number, tempo)
	
	-- Verifica se partida está ativa para controle
	if battle.game_status == false or battle.game_number ~= game_number then
		return
	end
	
	-- Encerra partida por tempo esgotado
	if tempo >= 30 then
		send_all_to_lobby()
		minetest.chat_send_all("Partida encerrada por tempo esgotado")
		battle.finish()
		return
	end
	
	-- Continua loop
	minetest.after(30, battle.modes.shg.check_game, battle.game_number, tempo+30)
end

-- Iniciar batalha
battle.modes.shg.start = function()

	-- Verificar arena
	do
		local c, msg = battle.modes.shg.check_arena(battle.selec_arena)
		if c == false then return false, msg end
	end
	
	-- Arena
	local arena = battle.arena.tb[battle.selec_arena]
	
	-- Prepara jogadores para iniciar jogo
	for name,player in pairs(battle.ingame) do
	
		-- Retira do lobby
		battle.leave_lobby(player)
		
		-- Teleporta para spawn da arena
		player:setpos(arena.spawn)
		
	end
	
	battle.game_status = true
	battle.game_number = battle.game_number + 1
	
	-- Iniciar loop de checagem
	minetest.after(30, battle.modes.shg.check_game, battle.game_number, 30)
	
	return true
end

-- Se desconectar sai do jogo atual
minetest.register_on_leaveplayer(function(player)
	
	if battle.selec_mode == "shg" and battle.game_status == true then
		local name = player:get_player_name()
		battle.ingame[name] = nil
		
		-- Verificar vitoria
		check_win()
	end
	
end)

-- Verificar mortes
minetest.register_on_dieplayer(function(player, reason)
	if not player then return end
		
	-- Remove jogador do ingame
	battle.ingame[player:get_player_name()] = nil
	battle.join_lobby(player)
	
	-- Verificar vitoria
	check_win()
end)

