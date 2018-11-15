--[[
	Mod Battle para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Controle de PVP
  ]]

-- Status do PVP
battle.pvp_status = false

-- Mudar PVP
battle.set_pvp = function(status)
	battle.pvp_status = status
end


-- Ao reduzir saude
minetest.register_on_player_hpchange(function(player, hp_change)
	-- Caso o PVP esteja desativado
	if hp_change < 0 then
		if battle.pvp_status == false then return 0 end
		
		-- Jogadores no lobby durante partida
		if battle.game_status == true and battle.ingame[player:get_player_name()] == nil then
			return 0
		end
	end
	return hp_change
end, true)
