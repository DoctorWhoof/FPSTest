Namespace m2extensions

#Import "<mojo3d>"

Using mojo3d..
Using mojo.graphics
Using std.graphics

Class Collider Extension
	'Creates debug geometry for collider
	Method CreateDebugMesh( color:Color = Color.Green )

		Local material := New PbrMaterial( color )
		material.EmissiveFactor = color
'		material.CullMode = CullMode.None

		Local debugModel:Model

		Select InstanceType.Name
			Case "mojo3d.CapsuleCollider"
				Local capsule := Cast<CapsuleCollider>( Self )
				debugModel = Model.CreateCapsule( capsule.Radius/Entity.Scale.X, capsule.Length/Entity.Scale.X, capsule.Axis, 16, material, Entity )
				debugModel.LocalPosition = capsule.Origin
			Case "mojo3d.SphereCollider"
				Local sphere := Cast<SphereCollider>( Self )
				debugModel = Model.CreateSphere( sphere.Radius/Entity.Scale.X, 16, 16, material, Entity )
				debugModel.LocalPosition = sphere.Origin
			Case "mojo3d.BoxCollider"
				Local cube := Cast<BoxCollider>( Self )
				debugModel = Model.CreateBox( cube.Box, 1, 1, 1, material, Entity )
			Case "mojo3d.MeshCollider"
				Local meshCol := Cast<MeshCollider>( Self )
				debugModel = New Model( meshCol.Mesh, material, Entity )
		End

		debugModel.Name = "ColliderGuide"
		debugModel.Alpha = 0.35
	End
	
End