Namespace m2extensions

#Import "<std>"

Using std.geom

Function Format:String( number:Double, decimals:Int = 1 )
	Local arr:String[] = String(number).Split(".")
	If arr.Length > 1
		Return arr[0] + "." + arr[1].Left( decimals )
	Else
		Return arr[0]
	End
End

Function Format:String( vec:Vec2<Float>, decimals:Int = 1 )
	Return Format( vec.X, decimals ) + ", " + Format( vec.Y, decimals )
End

Function Format:String( vec:Vec3<Float>, decimals:Int = 1 )
	Return Format( vec.X, decimals ) + ", " + Format( vec.Y, decimals ) + ", " + Format( vec.Z, decimals )
End