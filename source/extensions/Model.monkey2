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
	
	
	Method CreateCollisionMesh( collisionGroup:Short )
		Local collider := AddComponent<MeshCollider>()
		collider.Mesh = Mesh
		
		Local body := AddComponent<RigidBody>()
		body.CollisionGroup = collisionGroup
		body.Kinematic = True
		body.Mass = 0
	End

End