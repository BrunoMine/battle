--[[
	Mod Battle para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Arena de batalha
  ]]

-- Tabela de arena
battle.arena = {}

-- Tabela de arenas salvas
battle.arena.tb = {}

-- Carrega arenas salvas
if battle.bd.verif("arenas", "tb") == true then
	battle.arena.tb = battle.bd.pegar("arenas", "tb")
end

-- Registrar arena
--[[
	["nome_arena"] = {
		titulo = "Titulo",
		tipo = "nome_tipo",
		pos1 = <pos1>,
		pos2 = <pos2>,
	}
  ]]
battle.registrar_arena = function(name, def)
	battle.arena.tb[name] = def
	-- Salvar no banco de dados permanente
	battle.bd.salvar("arenas", "tb", battle.arena.tb)
end
