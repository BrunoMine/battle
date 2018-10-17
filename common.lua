--[[
	Mod Battle para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Lobby dos jogadores
  ]]

-- Tabela de metodos
battle.c = {}

-- Contar tabela
battle.c.count_tb = function(tb)
	local n = 0
	for _,d in pairs(tb) do
		n = n + 1
	end
	return n
end
