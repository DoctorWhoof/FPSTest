Namespace m2extensions


Class Entity Extension
	
	'------------------------------------------------- Transformation extensions -------------------------------------------------
	
	'Direction vectors (normalized)
	Property Forward:Vec3f()
		Return Basis.k
	End
	
	Property Up:Vec3f()
		Return Basis.j
	End
	
	Property Right:Vec3f()
		Return Basis.i
	End
	
	
	'Preserves current world space transform when changing parent
	Method SwitchParent( newParent:Entity )
		Local oldPos := Position
		Local oldRot := Rotation
		Local oldScl := Scale
		Parent = newParent
		Position = oldPos
		Rotation = oldRot
		Scale = oldScl
	End
	
	
	'Positions and scales an entity in relation to an (axis aligned) camera to have a specific pixel size that corresponds to its size in meters.
	Method MakePixelPerfect( depthMultiplier:Double, camera:Camera, axis:Axis, virtualHeight:Float = Null )
		
		Local mult:= 1.0
		If virtualHeight Then mult = virtualHeight / camera.Viewport.Height

		Local s := (camera.Viewport.Height/2.0) * mult
		Local a := (Double(camera.FOV)/2.0) * degToRad
		Local h := s / Sin(a)
		Local d := Sqrt( (h*h) - (s*s) ) * depthMultiplier
		
		Select axis
			Case Axis.X
				X = camera.X + d
			Case Axis.Y
				Y = camera.Y + d
			Case Axis.Z
				Z = camera.Z + d
		End
		Scale *= depthMultiplier
		
'		For Local c := Eachin Children
'			c.Scale *= depthMultiplier
'		Next
	End
	

	'Same as before, but also sets an absolute size in pixels regardless of the original size
	Method MakePixelPerfect( width:Double, height:Double, depth:Double, depthMultiplier:Double, camera:Camera, axis:Axis, virtualHeight:Float = Null )

		MakePixelPerfect( depthMultiplier, camera, axis, virtualHeight )
		
		Local scaleMultiplier:= 1.0
		Local model := Cast<Model>( Self )
		If model
			If model.Mesh Then scaleMultiplier = 1.0 / model.Mesh.Bounds.Height
		End
		
		Select axis
			Case Axis.X
				Scale = New Vec3f( depth, height, width ) * depthMultiplier * scaleMultiplier
			Case Axis.Y
				Scale = New Vec3f( width, depth, height ) * depthMultiplier * scaleMultiplier
			Case Axis.Z
				Scale = New Vec3f( width, height, depth ) * depthMultiplier * scaleMultiplier
		End
	End
	
	
	'Rotate with axis selection
	Method Rotate( axis:Axis, value:Float )
		Select axis
			Case Axis.X RotateX( value )
			Case Axis.Y RotateZ( value )
			Case Axis.Z RotateY( value )
		End
	End
	
	
	'Translate with axis selection
	Method Move( axis:Axis, value:Float )
		Select axis
			Case Axis.X MoveX( value )
			Case Axis.Y MoveY( value )
			Case Axis.Z MoveZ( value )
		End
	End
	
	'------------------------------------------------- Hierarchy extensions -------------------------------------------------
	
	Method GetChild<T>:T( name:String )
		'Tries "first level" children first
		Local model:T
		For Local c := Eachin Children
			model = Cast<T>(c)
			If model
				If model.Name = name
					Return model
				End
			End
		Next
		
		'If code reaches here, there's no model found yet
		For Local c := Eachin Children
			Local recurse := c.GetChild<T>( name )
			If recurse Then Return recurse
		Next
		
		'Nothing found
		Print "Entity: " + name + " not found under " + Name
		Return Null
	End
	
	
	'Replaces all material indices with a single material, can recursively set children's materials as well	
	Method SetMaterials( mat:Material, alpha:Float = 1.0, assignToChildren:Bool = False )

		Local model := Cast<Model>( Self )
		If model
			Local matArray := New Material[ model.Materials.Length ]
			For Local n := 0 Until matArray.Length
				matArray[n] = mat
			Next
			Print ( "Entity: Replacing material in " + Name )
			model.Materials = matArray
			model.Material = mat
		End
		
		Alpha = alpha
		
		If assignToChildren
			For Local c := Eachin Children
				Local model := Cast<Model>(c)
				If model
					model.SetAllMaterials( mat, alpha, assignToChildren )
				End
			Next
		End
	End
	
	
	Method SetColor( newColor:Color )
		Color = newColor
		For Local c := Eachin Children
			c.Color = newColor
		Next
	End
	

'	'Creates subroutine with Entity's name as the owner
'	Method Delay( length:Double, func:Void(), loop:Bool = False )
'		Local newDelay := New Job( length, loop, func, Name )
'	End

End



