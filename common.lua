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

-- Copiar tabela
battle.c.copy_tb = function(tb)
	return minetest.deserialize(minetest.serialize(tb))
end

-- Limpar inventario
battle.c.clear_inv = function(inv, listname)
	for i=1, inv:get_size(listname) do
		inv:set_stack(listname, i, '')
	end
end

-- Adicionar privilegios
battle.c.grant_privs = function(name, privs)
	local p = minetest.get_player_privs(name)
	for n,d in pairs(privs) do
		p[n] = true
	end
	minetest.set_player_privs(name, p)
end

-- Remove privilegios
battle.c.revoke_privs = function(name, privs)
	local p = minetest.get_player_privs(name)
	for n,d in pairs(privs) do
		p[n] = nil
	end
	minetest.set_player_privs(name, p)
end
