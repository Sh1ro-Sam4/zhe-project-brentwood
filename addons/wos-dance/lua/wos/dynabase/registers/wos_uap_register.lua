wOS.DynaBase:RegisterSource({
	Name = "Ultimate Animation Pack - TF2",
	Type = WOS_DYNABASE.EXTENSION,
	Shared = "models/player/wiltos/wos_uap_tf2.mdl",
})

hook.Add( "PreLoadAnimations", "wOS.DynaBase.MountUAPTF2", function( gender )
	if gender != WOS_DYNABASE.SHARED then return end
	IncludeModel( "models/player/wiltos/wos_uap_tf2.mdl" )
end )

wOS.DynaBase:RegisterSource({
	Name = "Ultimate Animation Pack - Fortnite (Part 1)",
	Type = WOS_DYNABASE.EXTENSION,
	Shared = "models/player/wiltos/wos_uap_fortnite_1.mdl",
})

hook.Add( "PreLoadAnimations", "wOS.DynaBase.MountUAPFortnite1", function( gender )
	if gender != WOS_DYNABASE.SHARED then return end
	IncludeModel( "models/player/wiltos/wos_uap_fortnite_1.mdl" )
end )

wOS.DynaBase:RegisterSource({
	Name = "Ultimate Animation Pack - Fortnite (Part 2)",
	Type = WOS_DYNABASE.EXTENSION,
	Shared = "models/player/wiltos/wos_uap_fortnite_2.mdl",
})

hook.Add( "PreLoadAnimations", "wOS.DynaBase.MountUAPFortnite2", function( gender )
	if gender != WOS_DYNABASE.SHARED then return end
	IncludeModel( "models/player/wiltos/wos_uap_fortnite_2.mdl" )
end )

wOS.DynaBase:RegisterSource({
	Name = "Ultimate Animation Pack - Fortnite (Part 3)",
	Type = WOS_DYNABASE.EXTENSION,
	Shared = "models/player/wiltos/wos_uap_fortnite_3.mdl",
})

hook.Add( "PreLoadAnimations", "wOS.DynaBase.MountUAPFortnite3", function( gender )
	if gender != WOS_DYNABASE.SHARED then return end
	IncludeModel( "models/player/wiltos/wos_uap_fortnite_3.mdl" )
end )

wOS.DynaBase:RegisterSource({
	Name = "Ultimate Animation Pack - MoCap",
	Type = WOS_DYNABASE.EXTENSION,
	Shared = "models/player/wiltos/wos_uap_mocap.mdl",
})

hook.Add( "PreLoadAnimations", "wOS.DynaBase.MountUAPMoCap", function( gender )
	if gender != WOS_DYNABASE.SHARED then return end
	IncludeModel( "models/player/wiltos/wos_uap_mocap.mdl" )
end )

wOS.DynaBase:RegisterSource({
	Name = "Ultimate Animation Pack - Other (Part 1)",
	Type = WOS_DYNABASE.EXTENSION,
	Shared = "models/player/wiltos/wos_uap_other_1.mdl",
})

hook.Add( "PreLoadAnimations", "wOS.DynaBase.MountUAPOther1", function( gender )
	if gender != WOS_DYNABASE.SHARED then return end
	IncludeModel( "models/player/wiltos/wos_uap_other_1.mdl" )
end )

wOS.DynaBase:RegisterSource({
	Name = "Ultimate Animation Pack - Other (Part 2)",
	Type = WOS_DYNABASE.EXTENSION,
	Shared = "models/player/wiltos/wos_uap_other_2.mdl",
})

hook.Add( "PreLoadAnimations", "wOS.DynaBase.MountUAPOther2", function( gender )
	if gender != WOS_DYNABASE.SHARED then return end
	IncludeModel( "models/player/wiltos/wos_uap_other_2.mdl" )
end )

wOS.DynaBase:RegisterSource({
	Name = "Ultimate Animation Pack - Other (Part 3)",
	Type = WOS_DYNABASE.EXTENSION,
	Shared = "models/player/wiltos/wos_uap_other_3.mdl",
})

hook.Add( "PreLoadAnimations", "wOS.DynaBase.MountUAPOther3", function( gender )
	if gender != WOS_DYNABASE.SHARED then return end
	IncludeModel( "models/player/wiltos/wos_uap_other_3.mdl" )
end )