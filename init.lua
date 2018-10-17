--[[
	Mod Battle para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Inicialização de scripts
  ]]

-- Tabela Global
battle = {}

local modpath = minetest.get_modpath("battle")

dofile(modpath.."/common.lua")
dofile(modpath.."/banco_de_dados.lua")
dofile(modpath.."/lobby.lua")
dofile(modpath.."/arena.lua")
dofile(modpath.."/arena_editor.lua")

-- Modos de batalhas
battle.modes = {}
dofile(modpath.."/battle_modes/shg.lua")

--dofile(modpath.."/tradutor.lua")

