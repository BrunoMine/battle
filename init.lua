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

-- Inscrever jogadores automaticamente para a batalha
battle.auto_join = true
if minetest.settings:get("battle_enable_auto_join_battle") == "false" then
	battle.auto_join = false
end

local modpath = minetest.get_modpath("battle")

dofile(modpath.."/common.lua")
dofile(modpath.."/banco_de_dados.lua")
dofile(modpath.."/pvp_control.lua")
dofile(modpath.."/tradutor.lua")

-- Modos de batalhas
battle.modes = {}
dofile(modpath.."/battle_modes/shg.lua")

dofile(modpath.."/loot_items.lua")
dofile(modpath.."/player.lua")
dofile(modpath.."/lobby.lua")
dofile(modpath.."/lobby_inv.lua")
dofile(modpath.."/arena.lua")
dofile(modpath.."/arena_editor.lua")
dofile(modpath.."/auto_start.lua")

-- Mods Suportados
dofile(modpath.."/supported_mods/default.lua")
dofile(modpath.."/supported_mods/hudbars.lua")
dofile(modpath.."/supported_mods/hbhunger.lua")
dofile(modpath.."/supported_mods/3d_armor.lua")

