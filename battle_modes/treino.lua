--[[
	Mod Battle para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Modo de jogo: Treino
	
	Descrição:
	Nesse modo os jogadores podem ficar jogando livremente 
	para conhecer o mapa e testar armas e recursos.
  ]]

-- Tradutor de texto
local S = battle.S

-- Tabela do modo
battle.modes.treino = {}

-- Titulo
battle.modes.treino.titulo = S("Treinamento")

-- Parametros
battle.modes.treino.params = {
	-- Coordenada do Spawn da Arena
	{
		name = S("Spawn do Treino"),
		format = "pos",
		desc = S("Coordenada onde o jogador aparece no mapa"),
		index_name = "spawn_treino",
	},
}

-- Limites de jogadores
battle.modes.treino.min_players = 1
battle.modes.treino.max_players = 1

-- Verificar arena
battle.modes.treino.check_arena = function(arena)
	local tb = battle.arena.tb[arena]
	
	-- Coordenada de spawn da arena
	if not tb.spawn then
		return false, S("Faltou o spawn do treino")
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
local check_end = function()
	-- Verifica se resta apenas 1 vivo
	if battle.c.count_tb(battle.ingame) == 0 then return end
	
	-- Encerra treino
	minetest.chat_send_all(S("Treino encerrado", name))
	
	battle.finish()
end

-- Verificar da partida
battle.modes.treino.check_game = function(game_number, tempo)
	
	-- Verifica se partida está ativa para controle
	if battle.game_status == false or battle.game_number ~= game_number then
		return
	end
	
	-- Encerra partida por tempo esgotado
	if tempo >= 240 then
		minetest.chat_send_all(S("Tempo de treino esgotado"))
		battle.finish()
		return
	end
	
	-- Continua loop
	minetest.after(30, battle.modes.treino.check_game, battle.game_number, tempo+30)
end

-- Iniciar batalha
battle.modes.treino.start = function()

	-- Verificar arena
	do
		local c, msg = battle.modes.treino.check_arena(battle.selec_arena)
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
	battle.set_pvp(true)
	
	-- Iniciar loop de checagem
	minetest.after(30, battle.modes.treino.check_game, battle.game_number, 30)
	
	minetest.chat_send_all(S("Treino iniciado"))
	return true
end

-- Se desconectar sai do jogo atual
minetest.register_on_leaveplayer(function(player)
	
	if battle.selec_mode == "treino" and battle.game_status == true then
		local name = player:get_player_name()
		battle.ingame[name] = nil
		
		-- Verificar fim
		check_end()
	end
	
end)

-- Verificar mortes
minetest.register_on_dieplayer(function(player, reason)
	if not player then return end
		
	-- Remove jogador do ingame
	battle.ingame[player:get_player_name()] = nil
	battle.join_lobby(player)
	
	-- Verificar fim
	check_end()
end)

