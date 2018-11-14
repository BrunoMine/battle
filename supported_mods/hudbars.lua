--[[
	Mod Battle para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Suporte para mod hudbars
  ]]

if minetest.get_modpath("hudbars") == nil then return end

battle.register_on_reset_bars(function(name)
	hb.hide_hudbar(player, "health")
	hb.hide_hudbar(player, "breath")
end)
