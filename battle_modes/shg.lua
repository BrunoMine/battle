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

-- Iniciar batalha
battle.modes.shg.start = function()

	-- Verificar arena
	do
		local c, msg = battle.modes.shg.check_arena(battle.selec_arena)
		if c == false then return false, msg end
	end
	
	return true
end
