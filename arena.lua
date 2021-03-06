--[[
	Mod Battle para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Arena de batalha
  ]]

-- Tradutor de texto
local S = battle.S

-- Tabela de arena
battle.arena = {}

-- Tabela de arenas salvas
battle.arena.tb = {}

-- Carrega arenas salvas
if battle.bd.verif("arenas", "tb") == true then
	battle.arena.tb = battle.bd.pegar("arenas", "tb")
end

-- Salvar arenas
battle.arena.salvar_bd = function()
	battle.bd.salvar("arenas", "tb", battle.arena.tb)
	battle.bd.salvar("arenas", "total", battle.arena.total)
end

-- Numero de arenas registradas (independente de já terem sido excluidas)
battle.arena.total = 0
if battle.bd.verif("arenas", "total") == true then
	battle.arena.total = battle.bd.pegar("arenas", "total")
else
	battle.bd.salvar("arenas", "total", battle.arena.total)
end

-- Registrar arena
--[[
	["nome_arena"] = {
		titulo = "Titulo",
	}
  ]]
battle.registrar_arena = function()
	battle.arena.total = battle.arena.total + 1
	local new_id = "arena_"..battle.arena.total
	battle.arena.tb[new_id] = {
		titulo = S("Arena @1", battle.arena.total),
		modes = {},
	}
	-- Salvar no banco de dados permanente
	battle.arena.salvar_bd()
	return new_id
end

-- Deletar registro de arena
battle.deletar_arena = function(id)
	battle.arena.tb[id] = nil
	-- Salvar no banco de dados permanente
	battle.arena.salvar_bd()
end
