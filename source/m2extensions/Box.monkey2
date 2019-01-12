Namespace m2extensions

#Import "<std>"

Using std.geom


Struct Box<T> Extension

	Function Cube:Box<T>( size:T )
		Local h := size/2.0
		Return New Box<T>( -h, -h, -h, h, h, h )
	End
	
	
	Function Cube:Box<T>( xLength:T, yLength:T, zLength:T, xHandle:Float=0.5, yHandle:Float=0.5, zHandle:Float=0.5 )
		Local x0 := -(xLength * xHandle)
		Local y0 := -(yLength * yHandle)
		Local z0 := -(zLength * zHandle)
		Local x1 := xLength * (1.0-xHandle)
		Local y1 := yLength * (1.0-yHandle)
		Local z1 := zLength * (1.0-zHandle)
	'	Print( x0 + "," + y0 + "," + z0 + ";    " + x1 + "," + y1 + "," + z1 )
		Return New Box<T>( x0, y0, z0, x1, y1, z1 )
	End
	
	
End