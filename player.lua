--[[
	Mod Battle para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Gerencia recursos de jogo nos jogadores
  ]]

-- Tabela de metodos
battle.player = {}

-- Resetar jogador
battle.player.reset = function(player)
	
	-- Limpa inventario
	local inv = player:get_inventory()
	battle.c.clear_inv(inv, "main")
	battle.c.clear_inv(inv, "craft")
	
	-- Restaura saúde
	player:set_hp(20)
	-- Restaura folego
	player:set_breath(11)
	
	-- Restaura inventario comum
	sfinv.set_player_inventory_formspec(player)
	
	-- Restaura modelo de animação
	player_api.set_model(player, "character.b3d")
	
end
