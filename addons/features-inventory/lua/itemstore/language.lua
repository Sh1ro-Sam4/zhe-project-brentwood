itemstore.Language = {}

LANGUAGE = {}
include( "itemstore/languages/" .. (itemstore.config.Language or "ru") .. ".lua" )
if SERVER then AddCSLuaFile( "itemstore/languages/" .. (itemstore.config.Language or "ru") .. ".lua" ) end
itemstore.Language = LANGUAGE
LANGUAGE = nil

assert( itemstore.Language, "[ItemStore] Language not found" )

function itemstore.Translate( trans, ... )
	return string.format( itemstore.Language[ trans ] or trans, ... )
end