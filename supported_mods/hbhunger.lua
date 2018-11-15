--[[
	Mod Battle para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Suporte para mod hbhunger
  ]]

if minetest.get_modpath("hbhunger") == nil then return end

battle.register_on_reset_bars(function(player)
	local name = player:get_player_name()
	-- Restaura saciedade
	hbhunger.hunger[name] = 30
	-- Oculta barras
	hb.hide_hudbar(player, "satiation")
end)

battle.register_on_player_reset(function(player)
	hb.unhide_hudbar(player, "satiation")
end)
