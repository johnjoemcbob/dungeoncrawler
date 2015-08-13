-- Matthew Cormack (@johnjoemcbob)
-- 13/08/15
-- Spell generation and storage clientside logic
-- Actual spells are defined as separate lua files inside gamemode/spells

-- Initialization of this message is contained within sv_spell.lua
net.Receive( "DC_Client_LootedSpells", function( len )
	LocalPlayer().LootedSpells = net.ReadTable()

	-- Send received confirmation
	net.Start( "DC_Client_LootedSpells" )
		net.WriteTable( {} )
	net.SendToServer()
end )