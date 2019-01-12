Namespace m2extensions

#Import "<mojo3d>"

Using mojo3d..
Using std.geom

Class Light Extension

	Method AddGuide( size:Float )
		Local mat := New PbrMaterial( Color.Yellow, 0.5, 0.5 )
		mat.EmissiveFactor = Color.Yellow

		Local guide:Model
	
		Select Type
			Case LightType.Point
				guide = Model.CreateSphere( size, 12, 12, mat, Self )
			Case LightType.Spot
				guide = Model.CreateCone( size, size, Axis.Z, 12, mat, Self )
			Case LightType.Directional
				guide = Model.CreateCylinder( size/2.0, size, Axis.Z, 12, mat, Self )
		End

		guide.Alpha = 0.25
		guide.LocalRx = 180
		guide.CastsShadow = False
	End

End
