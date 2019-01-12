Namespace m2extensions

#Import "<mojo3d>"

Using mojo3d..

Class Camera Extension

	'height is the desired "virtual resolution" height, assuming 1 unit = 1 pixel
	Method FakeIso( height:Double, range:Double = 256.0, fov:Double = 0.001 )
		Assert( Parent, "Camera: FakeIso needs a camera parent at the origin. Rotate the parent, not the camera")
		
		Local rad := fov * ( Pi / 180.0 )		'Degrees to radians
		FOV = fov
		
		Local distance:Double = (height) / Tan(rad)
		Near = distance - range
		Far = distance + range
		LocalZ = -distance
	End
	
End