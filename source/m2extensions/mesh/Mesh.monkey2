'Namespace mojo3d
'
'Class Mesh Extension
'
'	Method Append:Void ( model:Model, mesh:Mesh, material:PbrMaterial = Null )
'	
'		If Not material
'			material = New PbrMaterial (New Color( Rnd(),Rnd(),Rnd() ))
'		Endif
'		
'		If Not model.Mesh
'			model.Mesh = mesh
'			
'			model.Materials=New Material[]( material )
'		Else
'			
'			model.Mesh.AddMesh( mesh,model.Mesh.NumMaterials )
'			
'			Local materials:=model.Materials.Resize( model.Materials.Length+1 )
'			materials[materials.Length-1]=material
'			model.Materials=materials
'			
'		Endif
'	 
'		model.Mesh.UpdateNormals ()
'		model.Mesh.UpdateTangents ()
'		
'	End	
'	
'End