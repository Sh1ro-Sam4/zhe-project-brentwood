--- START OF FILE Paste May 27, 2026 - 7:41PM ---

TOOL.Category		= "Набор Строителя"
TOOL.Name			= "Толкатель"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "mode" ]	 			= "1"
TOOL.ClientConVar[ "user" ] 			= "1"

TOOL.ClientConVar[ "freeze" ]	 		= "1"
TOOL.ClientConVar[ "nocollide" ]		= "1"
TOOL.ClientConVar[ "nocollideall" ]		= "0"
TOOL.ClientConVar[ "rotation" ] 		= "15"
TOOL.ClientConVar[ "rotate" ] 			= "1"
TOOL.ClientConVar[ "offset" ]	 		= "0"
TOOL.ClientConVar[ "offsetpercent" ] 	= "1"
TOOL.ClientConVar[ "physdisable" ]		= "0"
TOOL.ClientConVar[ "ShadowDisable" ]	= "0"
TOOL.ClientConVar[ "allowphysgun" ]		= "0"
TOOL.ClientConVar[ "autorotate" ]		= "0"
TOOL.ClientConVar[ "entirecontrap" ]	= "0"
TOOL.ClientConVar[ "nudge" ]			= "25"
TOOL.ClientConVar[ "nudgepercent" ]		= "1"

TOOL.ClientConVar[ "enablefeedback" ]	= "1"
TOOL.ClientConVar[ "chatfeedback" ]		= "1"
TOOL.ClientConVar[ "nudgeundo" ]		= "0"
TOOL.ClientConVar[ "moveundo" ]			= "1"
TOOL.ClientConVar[ "rotateundo" ]		= "1"

function TOOL:DoApply(CurrentEnt, FirstEnt, autorotate, nocollideall, ShadowDisable )
	local CurrentPhys = CurrentEnt:GetPhysicsObject()
	
	if ( autorotate ) then
		if ( CurrentEnt == FirstEnt ) then
			local angle = CurrentPhys:RotateAroundAxis( Vector( 0, 0, 1 ), 0 )
			self.anglechange = Vector( angle.p - (math.Round(angle.p/45))*45, angle.r - (math.Round(angle.r/45))*45, angle.y - (math.Round(angle.y/45))*45 )
			if ( table.Count(self.TaggedEnts) == 1 ) then
				angle.p = (math.Round(angle.p/45))*45
				angle.r = (math.Round(angle.r/45))*45
			end
			angle.y = (math.Round(angle.y/45))*45
			CurrentPhys:SetAngles( angle )
		else
			local distance = math.sqrt(math.pow((CurrentEnt:GetPos().X-FirstEnt:GetPos().X),2)+math.pow((CurrentEnt:GetPos().Y-FirstEnt:GetPos().Y),2))
			local theta = math.atan((CurrentEnt:GetPos().Y-FirstEnt:GetPos().Y) / (CurrentEnt:GetPos().X-FirstEnt:GetPos().X)) - math.rad(self.anglechange.Z)
			if (CurrentEnt:GetPos().X-FirstEnt:GetPos().X) < 0 then
				CurrentEnt:SetPos( Vector( FirstEnt:GetPos().X - (distance*(math.cos(theta))), FirstEnt:GetPos().Y - (distance*(math.sin(theta))), CurrentEnt:GetPos().Z ) )
			else
				CurrentEnt:SetPos( Vector( FirstEnt:GetPos().X + (distance*(math.cos(theta))), FirstEnt:GetPos().Y + (distance*(math.sin(theta))), CurrentEnt:GetPos().Z ) )
			end
			CurrentPhys:SetAngles( CurrentPhys:RotateAroundAxis( Vector( 0, 0, -1 ), self.anglechange.Z ) )
		end
	end

	CurrentPhys:EnableCollisions( !nocollideall )
	CurrentEnt:DrawShadow( !ShadowDisable )
	
	local physdis = util.tobool( self:GetClientNumber( "physdisable", 0 ) )
	local disablephysgun = self:GetClientNumber( "allowphysgun" ) == 0
	
	if physdis then
		CurrentEnt:SetMoveType(MOVETYPE_NONE)
		CurrentEnt.PhysgunDisabled = disablephysgun
		CurrentEnt:SetUnFreezable( disablephysgun )
	else
		CurrentEnt:SetMoveType(MOVETYPE_VPHYSICS)
		CurrentEnt.PhysgunDisabled = false
		CurrentEnt:SetUnFreezable( false )
	end
	CurrentPhys:Wake()
end

function TOOL:CreateUndo(constraint,undoname)
	if (constraint) then
		undo.Create(undoname)
		undo.AddEntity( constraint )
		undo.SetPlayer( self:GetOwner() )
		undo.Finish()
		self:GetOwner():AddCleanup( "constraints", constraint )
	end
end

function TOOL:DoConstraint(mode)
	self:SetStage(0)
	local Ent1,  Ent2  = self:GetEnt(1),    self:GetEnt(2)

	if ( !Ent1:IsValid() || CLIENT ) then
		self:ClearObjects()
		return false
	end

	local freeze		= util.tobool( self:GetClientNumber( "freeze", 1 ) )
	local nocollide		= self:GetClientNumber( "nocollide", 0 )
	local nocollideall	= util.tobool( self:GetClientNumber( "nocollideall", 0 ) )
	local ShadowDisable = util.tobool( self:GetClientNumber( "ShadowDisable", 0 ) )
	local autorotate 	= util.tobool(self:GetClientNumber( "autorotate",1 ))

	local Bone2 = nil
	if ( Ent2 && (Ent2:IsValid() || Ent2:IsWorld()) ) then
		Bone2 = self:GetBone(2)
	end
	
	local NumApp = 0

	for key,CurrentEnt in pairs(self.TaggedEnts) do
		if ( CurrentEnt and CurrentEnt:IsValid() ) then
			if !(CurrentEnt == Ent2 ) then
				local CurrentPhys = CurrentEnt:GetPhysicsObject()
				if ( CurrentPhys:IsValid() && !CurrentEnt:GetParent():IsValid() ) then
					if ( CurrentEnt:GetPhysicsObjectCount() < 2 ) then 
						if (  util.tobool( nocollide ) && (mode == 1 || mode == 3)) then
							constraint.NoCollide(CurrentEnt, Ent2, 0, Bone2)
						end
						if ( mode == 1 ) then
							self:DoApply( CurrentEnt, Ent1, autorotate, nocollideall, ShadowDisable )
						end
						
						CurrentPhys:EnableMotion( !freeze )
						CurrentPhys:Wake()
					end
				end
			end
		end
		NumApp = NumApp + 1
	end
	
	if ( mode == 1 ) then
		self:SendMessage( "Объектов применено: " .. NumApp )
	elseif ( mode == 2 ) then
		self:SendMessage( "Объектов повернуто: " .. NumApp )
	elseif ( mode == 3 ) then
		self:SendMessage( "Объектов перемещено: " .. NumApp )
	end
	
	self:ClearSelection()
	self:ClearObjects()
end

function TOOL:SendMessage( message )
	if ( self:GetClientNumber( "enablefeedback" ) == 0 ) then return end
	if ( self:GetClientNumber( "chatfeedback" ) == 1 ) then
		self:GetOwner():PrintMessage( HUD_PRINTTALK, "Инструмент: " .. message )
	else
		self:GetOwner():PrintMessage( HUD_PRINTCENTER, message )
	end
end

function TOOL:TargetValidity ( trace, Phys ) 
	if ( SERVER && (!util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) || !Phys:IsValid()) ) then
		local mode = self:GetClientNumber( "mode" )
		if ( trace.Entity:GetParent():IsValid() ) then
			return 2
		else
			return 0
		end
	elseif ( trace.Entity:IsPlayer() ) then
		return 0
	elseif ( trace.HitWorld ) then
		return 1
	else
		return 3
	end
end

function TOOL:StartRotate()
	local Ent = self:GetEnt(1)
	local Phys = self:GetPhys(1)
	local oldposu = Ent:GetPos()
	local oldangles = Ent:GetAngles()

	local function MoveUndo( Undo, Entity, oldposu, oldangles )
		if Entity:IsValid() then
			Entity:SetAngles( oldangles )
			Entity:SetPos( oldposu )
		end
	end
	
	if ( self:GetClientNumber( "rotateundo" )) then
		if SERVER then
			undo.Create("Поворот (Толкатель)")
				undo.SetPlayer(self:GetOwner())
				undo.AddFunction( MoveUndo, Ent, oldposu, oldangles )
			undo.Finish()
		end
	end
	
	if IsValid( Phys ) then
		Phys:EnableMotion( false ) 
	end
	
	local rotation = self:GetClientNumber( "rotation" )
	if ( rotation < 0.02 ) then rotation = 0.02 end
	self.axis = self:GetNormal(1)
	self.axisY = self.axis:Cross(Ent:GetUp())
	if self:WithinABit( self.axisY, Vector(0,0,0) ) then
		self.axisY = self.axis:Cross(Ent:GetForward())
	end
	self.axisZ = self.axisY:Cross(self.axis)
	self.realdegrees = 0
	self.lastdegrees = -((rotation/2) % rotation)
	self.realdegreesY = 0
	self.lastdegreesY = -((rotation/2) % rotation)
	self.realdegreesZ = 0
	self.lastdegreesZ = -((rotation/2) % rotation)
	self.OldPos = self:GetPos(1)
end

function TOOL:DoMove()
	local Norm1, Norm2 = self:GetNormal(1),   self:GetNormal(2)
	local Phys1, Phys2 = self:GetPhys(1),     self:GetPhys(2)
	
	local Ang1, Ang2 = Norm1:Angle(), (Norm2 * -1):Angle()
	if self:GetClientNumber( "autorotate" ) == 1 then
		Ang2.p = (math.Round(Ang2.p/45))*45
		Ang2.r = (math.Round(Ang2.r/45))*45
		Ang2.y = (math.Round(Ang2.y/45))*45
		Norm2 = Ang2:Forward() * -1
	end

	local oldposu = self:GetEnt(1):GetPos()
	local oldangles = self:GetEnt(1):GetAngles()

	local function MoveUndo( Undo, Entity, oldposu, oldangles )
		if Entity:IsValid() then
			Entity:SetAngles( oldangles )
			Entity:SetPos( oldposu )
		end
	end
	if self:GetClientNumber( "moveundo" ) == 1 then
	undo.Create("Перемещение (Толкатель)")
		undo.SetPlayer(self:GetOwner())
		undo.AddFunction( MoveUndo, self:GetEnt(1), oldposu, oldangles )
	undo.Finish()
	end

	local rotation = self:GetClientNumber( "rotation" )
	local mode = self:GetClientNumber( "mode" )
	
	if ( rotation < 0.02 ) then rotation = 0.02 end
	if ( (self:GetClientNumber( "rotate" ) == 1 && mode != 1) || mode == 2) then
		self.axis = Norm2
		self.axisY = self.axis:Cross(Vector(0,1,0))
		if self:WithinABit( self.axisY, Vector(0,0,0) ) then
			self.axisY = self.axis:Cross(Vector(0,0,1))
		end
		self.axisY:Normalize()
		self.axisZ = self.axisY:Cross(self.axis)
		self.axisZ:Normalize()
		self.realdegrees = 0
		self.lastdegrees = -((rotation/2) % rotation)
		self.realdegreesY = 0
		self.lastdegreesY = -((rotation/2) % rotation)
		self.realdegreesZ = 0
		self.lastdegreesZ = -((rotation/2) % rotation)
	else
		self.axis = Norm2
		self.axisY = self.axis:Cross(Vector(0,1,0))
		if self:WithinABit( self.axisY, Vector(0,0,0) ) then
			self.axisY = self.axis:Cross(Vector(0,0,1))
		end
		self.axisY:Normalize()
		self.axisZ = self.axisY:Cross(self.axis)
		self.axisZ:Normalize()
	end

	local TargetAngle = Phys1:AlignAngles( Ang1, Ang2 )

	if self:GetClientNumber( "autorotate" ) == 1 then
		TargetAngle.p = (math.Round(TargetAngle.p/45))*45
		TargetAngle.r = (math.Round(TargetAngle.r/45))*45
		TargetAngle.y = (math.Round(TargetAngle.y/45))*45
	end

	Phys1:SetAngles( TargetAngle )

	local NewOffset = math.Clamp( self:GetClientNumber( "offset" ), -5000, 5000 )
	local offsetpercent		= self:GetClientNumber( "offsetpercent" ) == 1
	if ( offsetpercent ) then
		local  Ent2  = self:GetEnt(2)
		local glower = Ent2:OBBMins()
		local gupper = Ent2:OBBMaxs()
		local height = math.abs(gupper.z - glower.z) -0.5
		if self:WithinABit(Norm2,Ent2:GetForward()) then
			height = math.abs(gupper.x - glower.x)-0.5
		elseif self:WithinABit(Norm2,Ent2:GetRight()) then
			height = math.abs(gupper.y - glower.y)-0.5
		end
		NewOffset = NewOffset / 100
		NewOffset = NewOffset * height
	end
	Norm2 = Norm2 * (-0.0625 + NewOffset)
	local TargetPos = self:GetPos(2) + (Phys1:GetPos() - self:GetPos(1)) + (Norm2)

	Phys1:SetPos( TargetPos )
	Phys1:EnableMotion( false )
	Phys1:Wake()
end

function TOOL:ToggleColor( CurrentEnt )
	color = CurrentEnt:GetColor()
	color["a"] = color["a"] - 128
	if ( color["a"] < 0 ) then
		color["a"] = color["a"] + 256
	end
	color["r"] = color["r"] - 128
	if ( color["r"] < 0 ) then
		color["r"] = color["r"] + 256
	end
	color["g"] = color["g"] - 128
	if ( color["g"] < 0 ) then
		color["g"] = color["g"] + 256
	end
	color["b"] = color["b"] - 128
	if ( color["b"] < 0 ) then
		color["b"] = color["b"] + 256
	end
	CurrentEnt:SetColor( color )
	if ( color["a"] == 255 ) then
		CurrentEnt:SetRenderMode( 0 )
	else
		CurrentEnt:SetRenderMode( 1 )
	end
end

function TOOL:ClearSelection()
	if ( self.TaggedEnts ) then
		local color
		for key,CurrentEnt in pairs(self.TaggedEnts) do
			if ( CurrentEnt and CurrentEnt:IsValid() ) then
				local CurrentPhys = CurrentEnt:GetPhysicsObject()
				if ( CurrentPhys:IsValid() ) then
					self:ToggleColor(CurrentEnt)
				end
			end
		end
	end
	self.TaggedEnts = {}
end

function TOOL:SelectEnts(StartEnt, AllConnected)
	self:ClearSelection()
	if ( CLIENT ) then return end
	local color
	if ( AllConnected == 1 ) then
		local NumApp = 0
		EntsTab = {}
		ConstsTab = {}
		GetAllEnts(StartEnt, self.TaggedEnts, EntsTab, ConstsTab)
		for key,CurrentEnt in pairs(self.TaggedEnts) do
			if ( CurrentEnt and CurrentEnt:IsValid() ) then
				local CurrentPhys = CurrentEnt:GetPhysicsObject()
				if ( CurrentPhys:IsValid() ) then
					self:ToggleColor(CurrentEnt)
				end
			end
			NumApp = NumApp + 1
		end
		self:SendMessage( "Объектов выбрано: " .. NumApp )
	else
		if ( StartEnt and StartEnt:IsValid() ) then
			local CurrentPhys = StartEnt:GetPhysicsObject()
			if ( CurrentPhys:IsValid() ) then
				table.insert(self.TaggedEnts, StartEnt)
				self:ToggleColor(StartEnt)
			end
		end
	end
end

function TOOL:LeftClick( trace )
	local stage = self:GetStage()
	local mode = self:GetClientNumber( "mode" )
	local moving = ( mode == 3 )
	local rotating = ( self:GetClientNumber( "rotate" ) == 1 )
	local Phys = trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone )
	
	if ( stage == 0 ) then
		if ( self:TargetValidity(trace, Phys) <= 1 ) then
			return false
		end
		self:SetObject( 1, trace.Entity, trace.HitPos, Phys, trace.PhysicsBone, trace.HitNormal )
		
		if (self:GetClientNumber( "entirecontrap" ) == 1) then
			self:SelectEnts(trace.Entity,1)
		else
			self:SelectEnts(trace.Entity,0)
		end
		if ( mode == 1 ) then 
			self:DoConstraint(mode)
		else
			if ( moving ) then
				self:StartGhostEntity( trace.Entity )
				self:SetStage(1)
			elseif ( mode == 2 ) then
				self:StartRotate()
				self:SetStage(2)
			else
				self:SetStage(1)
			end
		end
	elseif ( stage == 1 ) then
		self:SetObject( 2, trace.Entity, trace.HitPos, Phys, trace.PhysicsBone, trace.HitNormal )
		
		if ( self:GetEnt(1) == self:GetEnt(2) ) then
			SavedPos = self:GetPos(2)
		end
		
		if ( moving ) then
			if ( CLIENT ) then
				self:ReleaseGhostEntity()
				return true
			end
			if ( SERVER && !game.SinglePlayer() ) then
				self:ReleaseGhostEntity()
			end
			self:DoMove()
		end
		if ( rotating ) then
			self:StartRotate()
			self:SetStage(2)
		else
			self:DoConstraint(mode)
		end
	elseif ( stage == 2 ) then
		self:DoConstraint(mode)
	end
	return true
end

function TOOL:WithinABit( v1, v2 )
	local tol = 0.1
	local da = v1.x-v2.x
	local db = v1.y-v2.y
	local dc = v1.z-v2.z
	if da < tol && da > -tol && db < tol && db > -tol && dc < tol && dc > -tol then
		return true
	else
		da = v1.x+v2.x
		db = v1.y+v2.y
		dc = v1.z+v2.z
		if da < tol && da > -tol && db < tol && db > -tol && dc < tol && dc > -tol then
			return true
		else
			return false
		end
	end
end

if ( SERVER ) then
	function GetAllEnts( Ent, OrderedEntList, EntsTab, ConstsTab )
		if ( Ent and Ent:IsValid() ) and ( !EntsTab[ Ent:EntIndex() ] ) then
			EntsTab[ Ent:EntIndex() ] = Ent
			table.insert(OrderedEntList, Ent)
			if ( !constraint.HasConstraints( Ent ) ) then return OrderedEntList end
			for key, ConstraintEntity in pairs( Ent.Constraints ) do
				if ( !ConstsTab[ ConstraintEntity ] ) then
					ConstsTab[ ConstraintEntity ] = true
					local ConstTable = ConstraintEntity:GetTable()
					for i=1, 6 do
						local e = ConstTable[ "Ent"..i ]
						if ( e and e:IsValid() ) and ( !EntsTab[ e:EntIndex() ] ) then
							GetAllEnts( e, OrderedEntList, EntsTab, ConstsTab )
						end
					end
				end
			end
		end
		return OrderedEntList
	end
	
	function GetAllConstraints( EntsTab )
		local ConstsTab = {}
		for key, Ent in pairs( EntsTab ) do
			if ( Ent and Ent:IsValid() ) then
				local MyTable = constraint.GetTable( Ent )
				for key, Constraint in pairs( MyTable ) do
					if ( !ConstsTab[ Constraint.Constraint ] ) then
						ConstsTab[ Constraint.Constraint ] = Constraint
					end
				end
			end
		end
		return ConstsTab
	end
end

function TOOL:UpdateCustomGhost( ghost, player, offset )
	if (ghost == nil) then return end
	if (!ghost:IsValid()) then ghost = nil return end

	local tr = util.GetPlayerTrace( player, player:GetAimVector() )
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end

	local Ang1, Ang2 = self:GetNormal(1):Angle(), (trace.HitNormal * -1):Angle()
	local TargetAngle = self:GetEnt(1):AlignAngles( Ang1, Ang2 )

	self.GhostEntity:SetPos( self:GetEnt(1):GetPos() )
	
	if self:GetClientNumber( "autorotate" ) == 1 then
		TargetAngle.p = (math.Round(TargetAngle.p/45))*45
		TargetAngle.r = (math.Round(TargetAngle.r/45))*45
		TargetAngle.y = (math.Round(TargetAngle.y/45))*45
	end
	self.GhostEntity:SetAngles( TargetAngle )

	local TraceNormal = trace.HitNormal

	local offsetpercent		= self:GetClientNumber( "offsetpercent" ) == 1
	local NewOffset = offset
	if ( offsetpercent ) then
		local glower = trace.Entity:OBBMins()
		local gupper = trace.Entity:OBBMaxs()
		local height = math.abs(gupper.z - glower.z) -0.5
		if self:WithinABit(TraceNormal,trace.Entity:GetForward()) then
			height = math.abs(gupper.x - glower.x) -0.5
		elseif self:WithinABit(TraceNormal,trace.Entity:GetRight()) then
			height = math.abs(gupper.y - glower.y) -0.5
		end
		NewOffset = NewOffset / 100
		NewOffset = NewOffset * height
	end

	local TranslatedPos = ghost:LocalToWorld( self:GetLocalPos(1) )
	local TargetPos = trace.HitPos + (self:GetEnt(1):GetPos() - TranslatedPos) + (TraceNormal*NewOffset)

	self.GhostEntity:SetPos( TargetPos )
end

function TOOL:Think()
	local pl = self:GetOwner()
	local wep = pl:GetActiveWeapon()
	if not wep:IsValid() or wep:GetClass() != "gmod_tool" or pl:GetInfo("gmod_toolmode") != "precision" then return end
		
	if (self:NumObjects() < 1) then return end
	local Ent1 = self:GetEnt(1)
	if ( SERVER ) then
		if ( !Ent1:IsValid() ) then
			self:ClearObjects()
			return
		end
	end
	local mode = self:GetClientNumber( "mode" )

	if self:NumObjects() == 1 && mode != 2 then
		if ( mode == 3 ) then
			local offset = math.Clamp( self:GetClientNumber( "offset" ), -5000, 5000 )
			self:UpdateCustomGhost( self.GhostEntity, self:GetOwner(), offset )
		end
	else
		local rotate = (self:GetClientNumber( "rotate" ) == 1 && mode != 1) || mode == 2
		if ( SERVER && rotate ) then
			local offset = math.Clamp( self:GetClientNumber( "offset" ), -5000, 5000 )

			local Phys1 = self:GetPhys(1)

			local cmd = self:GetOwner():GetCurrentCommand()

			local rotation		= self:GetClientNumber( "rotation" )
			if ( rotation < 0.02 ) then rotation = 0.02 end
			local degrees = cmd:GetMouseX() * 0.02

			local newdegrees = 0
			local changedegrees = 0

			local angle = 0
			if( self:GetOwner():KeyDown( IN_RELOAD ) ) then
				self.realdegreesY = self.realdegreesY + degrees
				newdegrees =  self.realdegreesY - ((self.realdegreesY + (rotation/2)) % rotation)
				changedegrees = self.lastdegreesY - newdegrees
				self.lastdegreesY = newdegrees
				angle = Phys1:RotateAroundAxis( self.axisY , changedegrees )
			elseif( self:GetOwner():KeyDown( IN_ATTACK2 ) ) then
				self.realdegreesZ = self.realdegreesZ + degrees
				newdegrees =  self.realdegreesZ - ((self.realdegreesZ + (rotation/2)) % rotation)
				changedegrees = self.lastdegreesZ - newdegrees
				self.lastdegreesZ = newdegrees
				angle = Phys1:RotateAroundAxis( self.axisZ , changedegrees )
			else
				self.realdegrees = self.realdegrees + degrees
				newdegrees =  self.realdegrees - ((self.realdegrees + (rotation/2)) % rotation)
				changedegrees = self.lastdegrees - newdegrees
				self.lastdegrees = newdegrees
				angle = Phys1:RotateAroundAxis( self.axis , changedegrees )
			end
			Phys1:SetAngles( angle )

			if ( mode == 3 ) then
				local WPos2 = self:GetPos(2)
				local Ent2 = self:GetEnt(2)
				local Norm2 = self:GetNormal(2)

				local NewOffset = offset
				local offsetpercent	= self:GetClientNumber( "offsetpercent" ) == 1
				if ( offsetpercent ) then
					local glower = Ent2:OBBMins()
					local gupper = Ent2:OBBMaxs()
					local height = math.abs(gupper.z - glower.z) -0.5
					if self:WithinABit(Norm2,Ent2:GetForward()) then
						height = math.abs(gupper.x - glower.x) -0.5
					elseif self:WithinABit(Norm2,Ent2:GetRight()) then
						height = math.abs(gupper.y - glower.y) -0.5
					end
					NewOffset = NewOffset / 100
					NewOffset = NewOffset * height
				end

				Norm2 = Norm2 * (-0.0625 + NewOffset)
				local TargetPos = Vector(0,0,0)
				if ( self:GetEnt(1) == self:GetEnt(2) ) then
					TargetPos = SavedPos + (Phys1:GetPos() - self:GetPos(1)) + (Norm2)
				else
					TargetPos = WPos2 + (Phys1:GetPos() - self:GetPos(1)) + (Norm2)
				end
				Phys1:SetPos( TargetPos )
			else
				local TargetPos = (Phys1:GetPos() - self:GetPos(1)) + self.OldPos
				Phys1:SetPos( TargetPos )
			end
			Phys1:Wake()
		end
	end
end

function TOOL:Nudge( trace, direction )
	if (!trace.Entity:IsValid() || trace.Entity:IsPlayer() ) then return false end
	local Phys1 = trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone )
	local offsetpercent		= self:GetClientNumber( "nudgepercent" ) == 1
	local offset		= self:GetClientNumber( "nudge", 100 )
	local max = 8192
	if ( offsetpercent != 1 ) then
		if ( offset > max ) then
			offset = max
		elseif ( offset < -max ) then
			offset = -max
		end
	end
	
	local NewOffset = offset
	if ( offsetpercent ) then
		local glower = trace.Entity:OBBMins()
		local gupper = trace.Entity:OBBMaxs()
		local height = math.abs(gupper.z - glower.z) -0.5
		if self:WithinABit(trace.HitNormal,trace.Entity:GetForward()) then
			height = math.abs(gupper.x - glower.x)-0.5
		elseif self:WithinABit(trace.HitNormal,trace.Entity:GetRight()) then
			height = math.abs(gupper.y - glower.y)-0.5
		end
		NewOffset = NewOffset / 100
		local cap = math.floor(max / height)
		if ( NewOffset > cap ) then
			NewOffset = cap
		elseif ( NewOffset < -cap ) then
			NewOffset = -cap
		end
		NewOffset = NewOffset * height
	end

	if ( self:GetClientNumber( "entirecontrap" ) == 1 ) then
		local NumApp = 0
		local TargetEnts = {}
		local EntsTab = {}
		local ConstsTab = {}
		GetAllEnts(trace.Entity, TargetEnts, EntsTab, ConstsTab)
		for key,CurrentEnt in pairs(TargetEnts) do
			if ( CurrentEnt and CurrentEnt:IsValid() ) then
				local CurrentPhys = CurrentEnt:GetPhysicsObject()
				if ( CurrentPhys:IsValid() ) then
					local TargetPos = CurrentPhys:GetPos() + trace.HitNormal * NewOffset * direction
					CurrentPhys:SetPos( TargetPos )
					CurrentPhys:Wake()
					if (CurrentEnt:GetMoveType() == 0 ) then 
						CurrentEnt:SetPos( TargetPos )
					end

				end
			end
			NumApp = NumApp + 1
		end
		if ( direction == -1 ) then
			self:SendMessage( "Объектов оттолкнуто: " .. NumApp )
		elseif ( direction == 1 ) then
			self:SendMessage( "Объектов притянуто: " .. NumApp )
		else
			self:SendMessage( "Объектов сдвинуто: " .. NumApp )
		end
	else
		if ( self:GetClientNumber( "nudgeundo" ) == 1 ) then
			local oldpos = Phys1:GetPos()
			local function NudgeUndo( Undo, Entity, oldpos )
				if trace.Entity:IsValid() then
					trace.Entity:SetPos( oldpos )
				end
			end
			undo.Create("Толчок/Притяжение (Толкатель)")
				undo.SetPlayer(self:GetOwner())
				undo.AddFunction( NudgeUndo, trace.Entity, oldpos )
			undo.Finish()
		end
		local TargetPos = Phys1:GetPos() + trace.HitNormal * NewOffset * direction
		Phys1:SetPos( TargetPos )
		Phys1:Wake()
		if ( trace.Entity:GetMoveType() == 0 ) then
			trace.Entity:SetPos( TargetPos )
		end
		if ( direction == -1 ) then
			self:SendMessage( "Цель оттолкнута." )
		elseif ( direction == 1 ) then
			self:SendMessage( "Цель притянута." )
		else
			self:SendMessage( "Цель сдвинута." )
		end
	end
	return true
end

function TOOL:RightClick( trace )
	local rotate = self:GetClientNumber( "rotate" ) == 1
	local mode = self:GetClientNumber( "mode" )
	if ( (mode == 2 && self:NumObjects() == 1) || (rotate && self:NumObjects() == 2 ) ) then
		if ( CLIENT ) then return false end
	else
		if ( CLIENT ) then return true end
		return self:Nudge( trace, -1 )
	end
end

function TOOL:Reload( trace )
	local rotate = self:GetClientNumber( "rotate" ) == 1
	local mode = self:GetClientNumber( "mode" )
	if ( (mode == 2 && self:NumObjects() == 1) || (rotate && self:NumObjects() == 2 ) ) then
		if ( CLIENT ) then return false end
	else
		if ( CLIENT ) then return true end
		return self:Nudge( trace, 1 )
	end
end

if CLIENT then
	language.Add( "Tool.precision.name", "Толкатель (Упрощенный)" )
	language.Add( "Tool.precision.desc", "Точно перемещает объекты и применяет к ним настройки" )
	language.Add( "Tool.precision.0", "ЛКМ: Переместить/Применить | ПКМ: Оттолкнуть | Перезарядка: Притянуть" )
	language.Add( "Tool.precision.1", "Выберите второй объект. Если включено, первый объект прикрепится ко второму. (Смена оружия для отмены)" )
	language.Add( "Tool.precision.2", "Включен поворот: Поворачивайте мышь влево/вправо (Удерживайте Перезарядку или ПКМ для поворота по другим осям!)" )

	language.Add("Undone.precision", "Действие Толкателя отменено")
	language.Add("Undone.precision.nudge", "Толчок/Притяжение отменено")
	language.Add("Undone.precision.rotate", "Поворот отменен")
	language.Add("Undone.precision.move", "Перемещение отменено")

	local showgenmenu = 0

	local function AddDefControls( Panel )
		Panel:ClearControls()

		Panel:AddControl("ComboBox",
		{
			Label = "#Presets",
			MenuButton = 1,
			Folder = "precision",
			Options = {},
			CVars =
			{
				[0] = "precision_offset",
				[1] = "precision_freeze",
				[2] = "precision_nocollide",
				[3] = "precision_nocollideall",
				[4] = "precision_rotation",
				[5] = "precision_rotate",
				[6] = "precision_mode",
				[7] = "precision_offsetpercent",
				[8] = "precision_physdisable",
				[9] = "precision_ShadowDisable",
				[10] = "precision_allowphysgun",
				[11] = "precision_autorotate",
				[12] = "precision_massmode",
				[13] = "precision_nudge",
				[14] = "precision_nudgepercent"
			}
		})

		Panel:AddControl( "Slider",  { Label	= "Сила толчка/притяжения",
					Type	= "Float",
					Min		= 1,
					Max		= 100,
					Command = "precision_nudge",
					Description = "Дистанция сдвига пропов при нажатии ПКМ/Перезарядки"}	 ):SetDecimals( 4 )

		Panel:AddControl( "Checkbox", { Label = "Толкать/притягивать в процентах (%) от размера цели", Command = "precision_nudgepercent", Description = "Выкл = Точные юниты, Вкл = % от ширины пропа при сдвиге" } )

		local user = LocalPlayer():GetInfoNum( "precision_user", 0 )
		local mode = LocalPlayer():GetInfoNum( "precision_mode", 0 )

		local list = vgui.Create("DListView")

		local height = 65 
		
		list:SetSize(30,height)
		list:AddColumn("Режим работы")
		list:SetMultiSelect(false)
		function list:OnRowSelected(LineID, line)
			if not (mode == LineID) then
				RunConsoleCommand("precision_setmode", LineID)
			end
		end

		if ( mode == 1 ) then
			list:AddLine(" 1 ->Применить<- (Применяет настройки к цели)")
		else
			list:AddLine(" 1   Применить   (Применяет настройки к цели)")
		end
		if ( mode == 2 ) then
			list:AddLine(" 2 ->Повернуть<- (Вращает объект на месте)")
		else
			list:AddLine(" 2   Повернуть   (Вращает объект на месте)")
		end
		if ( mode == 3 ) then
			list:AddLine(" 3 ->Переместить<- (Примагничивает объекты - Идеально для стройки!)")
		else
			list:AddLine(" 3   Переместить   (Примагничивает объекты - Идеально для стройки!)")
		end

		list:SortByColumn(1)
		Panel:AddItem(list)

		if ( mode == 3 ) then
			Panel:AddControl( "Checkbox", { Label = "Поворачивать цель? (Вращение после перемещения)", Command = "precision_rotate", Description = "Выключите, чтобы убрать лишний клик для вращения. Удобно для быстрой стройки." } )
			Panel:AddControl( "Slider",  { Label	= "Дистанция стыковки",
					Type	= "Float",
					Min		= 0,
					Max		= 10,
					Command = "precision_offset",
					Description = "Зазор между соединенными пропами. Введите отрицательное число для вдавливания."}	 )
			Panel:AddControl( "Checkbox", { Label = "Зазор в процентах (%) от размера второй цели", Command = "precision_offsetpercent", Description = "Выкл = Точные юниты, Вкл = % от толщины второго пропа" } )
		end
		if ( mode == 2 || mode == 3 ) then
			Panel:AddControl( "Slider",  { Label	= "Шаг поворота (Градусы)",
					Type	= "Float",
					Min		= 0.02,
					Max		= 90,
					Command = "precision_rotation",
					Description = "Привязка поворота к этому значению. Мин: 0.02 градуса "}	 ):SetDecimals( 4 )
		end
		
		Panel:AddControl( "Checkbox", { Label = "Заморозить цель", Command = "precision_freeze", Description = "Замораживает пропы после применения инструмента" } )

		if ( mode == 3 ) then
			Panel:AddControl( "Checkbox", { Label = "Отключить коллизию между целями", Command = "precision_nocollide", Description = "Делает два пропа прозрачными друг для друга."  } )
		end

		if ( user >= 2 || mode == 1 ) then
			if ( mode == 3 || mode == 1 ) then
				Panel:AddControl( "Checkbox", { Label = "Авто-выравнивание по миру (ближайшие 45 градусов)", Command = "precision_autorotate", Description = "Выравнивает проп по осям карты (как при удержании Shift+E физганом)"  } )
			end

			if ( mode == 1 ) then
				Panel:AddControl( "Checkbox", { Label = "Отключить тень цели", Command = "precision_ShadowDisable", Description = "Отключает отбрасывание тени от пропа"  } )
			end
		end

		if ( user >= 3 ) then
			if ( mode == 1 ) then 
				Panel:AddControl( "Checkbox", { Label = "Коллизия только с игроками", Command = "precision_nocollideall", Description = "Убирает коллизию пропа с миром и объектами (но игроки могут ходить по нему). Внимание: проп может провалиться сквозь карту."  } )
				Panel:AddControl( "Checkbox", { Label = "Отключить физику (Сделать статической)", Command = "precision_physdisable", Description = "Полностью отключает физику пропа (гравитация, выстрелы и т.д. не влияют)"  } )
				Panel:AddControl( "Checkbox", { Label = "Adv: Разрешить брать физганом пропы без физики", Command = "precision_allowphysgun", Description = "Выключите во избежание случайностей. Включение позволит таскать статические объекты."  } )
			end
		end
		if ( user >= 2 ) then
			if ( mode != 2 && mode != 3 ) then 
				Panel:AddControl( "Checkbox", { Label = "Вся конструкция! (Все соединенные объекты)", Command = "precision_entirecontrap", Description = "Для массового применения настроек, сдвига или вращения всей постройки."  } )
			end
		end

		if ( showgenmenu == 1 ) then
			Panel:AddControl( "Button", { Label = "\\/ Общие настройки инструмента \\/", Command = "precision_generalmenu", Description = "Свернуть меню"  } )

		local params = {Label = "Уровень пользователя",Description = "Показывает настройки в зависимости от опыта игрока", MenuButton = "0", Height = 67, Options = {}}
		if ( user == 1 ) then
			params.Options[" 1 ->Новичок<-"] = { precision_setuser = "1" }
		else
			params.Options[" 1   Новичок"] = { precision_setuser = "1" }
		end
		if ( user == 2 ) then
			params.Options[" 2 ->Продвинутый<-"] = { precision_setuser = "2" }
		else
			params.Options[" 2   Продвинутый"] = { precision_setuser = "2" }
		end
		if ( user == 3 ) then
			params.Options[" 3 ->Эксперт<-"] = { precision_setuser = "3" }
		else
			params.Options[" 3   Эксперт"] = { precision_setuser = "3" }
		end

		Panel:AddControl( "ListBox", params )

			Panel:AddControl( "Checkbox", { Label = "Включить уведомления инструмента?", Command = "precision_enablefeedback", Description = "Вкл/выкл текстовые сообщения от инструмента"  } )
			Panel:AddControl( "Checkbox", { Label = "Вкл = Сообщения в чате, Выкл = В центре экрана", Command = "precision_chatfeedback", Description = "Если чат засоряется, уведомления можно выводить на экран"  } )
			Panel:AddControl( "Checkbox", { Label = "Добавлять толчок/притяжение в историю отмен (Undo)", Command = "precision_nudgeundo", Description = "Полезно, если боитесь задвинуть деталь туда, где не сможете её достать"  } )
			Panel:AddControl( "Checkbox", { Label = "Добавлять перемещение в историю отмен (Undo)", Command = "precision_moveundo", Description = "Позволяет отменить кривое примагничивание кнопкой Z"  } )
			Panel:AddControl( "Checkbox", { Label = "Добавлять повороты в историю отмен (Undo)", Command = "precision_rotateundo", Description = "Позволяет отменять повороты кнопкой Z"  } )
			Panel:AddControl( "Button", { Label = "Сбросить настройки текущего режима", Command = "precision_defaultrestore", Description = "Свернуть меню"  } )
		else
			Panel:AddControl( "Button", { Label = "-- Общие настройки инструмента --", Command = "precision_generalmenu", Description = "Развернуть меню"  } )
		end
	end



	local function precision_defaults()
		local mode = LocalPlayer():GetInfoNum( "precision_mode", 3 )
		if mode  == 1 then
			RunConsoleCommand("precision_freeze", "1")
			RunConsoleCommand("precision_autorotate", "1")
			RunConsoleCommand("precision_ShadowDisable", "0")
			RunConsoleCommand("precision_nocollideall", "0")
			RunConsoleCommand("precision_physdisable", "0")
			RunConsoleCommand("precision_allowphysgun", "0")
			RunConsoleCommand("precision_entirecontrap", "0")
		elseif mode == 2 then
			RunConsoleCommand("precision_rotation", "15")
			RunConsoleCommand("precision_freeze", "1")
			RunConsoleCommand("precision_entirecontrap", "0")
		elseif mode == 3 then
			RunConsoleCommand("precision_rotate", "1")
			RunConsoleCommand("precision_offset", "0")
			RunConsoleCommand("precision_offsetpercent", "1")
			RunConsoleCommand("precision_rotation", "15")
			RunConsoleCommand("precision_freeze", "1")
			RunConsoleCommand("precision_nocollide", "1")
			RunConsoleCommand("precision_autorotate", "1")
			RunConsoleCommand("precision_entirecontrap", "0")
		end
		precision_updatecpanel()
	end
	concommand.Add( "precision_defaultrestore", precision_defaults )

	local function precision_genmenu()
		if ( showgenmenu == 1 ) then
			showgenmenu = 0
		else
			showgenmenu = 1
		end
		precision_updatecpanel()
	end
	concommand.Add( "precision_generalmenu", precision_genmenu )
	
	function precision_setmode( player, tool, args )
		if LocalPlayer():GetInfoNum( "precision_mode", 3 ) != args[1] then
			RunConsoleCommand("precision_mode", args[1])
			timer.Simple(0.05, function() precision_updatecpanel() end ) 
		end
	end
	concommand.Add( "precision_setmode", precision_setmode )

	function precision_setuser( player, tool, args )
		if LocalPlayer():GetInfoNum( "precision_user", 3 ) != args[1] then
			RunConsoleCommand("precision_user", args[1])
			timer.Simple(0.05, function() precision_updatecpanel() end ) 
		end
	end
	concommand.Add( "precision_setuser", precision_setuser )

	function precision_updatecpanel()
		local Panel = controlpanel.Get( "precision" )
		if (!Panel) then return end
		AddDefControls( Panel )
	end
	concommand.Add( "precision_updatecpanel", precision_updatecpanel )

	function TOOL.BuildCPanel( Panel )
		AddDefControls( Panel )
	end

	function TOOL:FreezeMovement()
		local stage = self:GetStage()
		if ( stage == 2 ) then
			return true
		end
		return false
	end
end

function TOOL:Holster()
	self:ClearObjects()
	self:SetStage(0)
	self:ClearSelection()
end