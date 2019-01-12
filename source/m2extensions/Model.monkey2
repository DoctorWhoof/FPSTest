Namespace m2extensions

#Import "<mojo3d>"

Using mojo3d..

Class Model Extension

	'Replaces all material indices with a single material, can recursively set children's materials as well	
	Method SetAllMaterials( mat:Material, alpha:Float = 1.0, assignToChildren:Bool = False )

		Local matArray := New Material[ Materials.Length ]
		For Local n := 0 Until matArray.Length
			matArray[n] = mat
		Next
		
		Alpha = alpha
		
		Print ( "Replacing material in " + Name )
		Materials = matArray

		If assignToChildren
			For Local c := Eachin Children
				Local model := Cast<Model>(c)
				If model
					model.SetAllMaterials( mat, alpha, assignToChildren )
				End
			Next
		End
	End
	
	
	Method CreateCollisionMesh( collisionGroup:Int, colType:String )
		Local createBody := False
		If colType = "Mesh"
			Local collider := AddComponent<MeshCollider>()
			collider.Mesh = Mesh
			createBody = True
		Elseif colType = "Proxy"
			Local collider := AddComponent<MeshCollider>()
			collider.Mesh = Mesh
			Alpha=0
			createBody = True
		Elseif colType = "Box"
			Local collider := AddComponent<BoxCollider>()
			collider.Box = Mesh.Bounds
			createBody = True
		End
		If createBody
			Local body := AddComponent<RigidBody>()
			body.CollisionMask = 255
			body.CollisionGroup = collisionGroup
			body.Kinematic = True
			body.Mass = 0
			Print "Created "+colType+" collider for "+Name+" in group "+collisionGroup
		End
	End
	
	
	Method Init()
		Print "Init "+Name
		Local name := Name.Split("_")
		Local group:Int
	
		If name?.Length > 1
			Select name[0]
				Case "E" group=Group.Environment
				Case "P" group=Group.Prop
				Case "T" group=Group.Trigger
			End

			CreateCollisionMesh(group,name[1])
		End
		
		For Local c := Eachin Children
			Local m := Cast<Model>(c)
			m?.Init()
		Next
	End
	
	
	Method SetShadow( shadow:Bool )
		CastsShadow = shadow
		For Local c := Eachin Children
			Local model := Cast<Model>(c)
			If model
				model.SetShadow( shadow )
			End
		Next
	End

End