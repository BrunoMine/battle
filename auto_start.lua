--[[
	Mod Battle para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Inicio automatico de partidas
  ]]

battle.auto_start_check = function()
	
	-- Verifica se ainda está ativo
	if battle.auto_start == false then
		return
	end

	-- Verifica se está rodando uma partida
	if battle.game_status == true then
		minetest.after(10, battle.auto_start_check)
		return
	end
	
	-- Verifica se é possivel iniciar batalha
	local gm = battle.modes[battle.selec_mode]
	
	-- Verifica limite mínimo de jogadores
	if battle.c.count_tb(battle.ingame) < gm.min_players then
		minetest.after(10, battle.auto_start_check)
		return
	end
	
	-- Inicia batalha
	local r, msg = battle.start()
	if r == false then
		minetest.chat_send_player(name, "ERRO. Impossivel inicar partida. "..msg)
		return
	end
	minetest.chat_send_all("Partida iniciada")
		
	-- Para o proximo loop
	minetest.after(20, battle.auto_start_check)
end

-- Verifica se o recurso já está ativo
if battle.auto_start == true then
	battle.auto_start_check()
end
