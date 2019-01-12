Namespace m2extensions


Function ArrayContains<T>:Bool( arr:T[], value:T )
	For local n := 0 Until arr.Length
		If arr[ n ] = value Then Return True
	End
	Return False
End


Function ArrayToString<T>:String( arr:T[] )
	Local text:= "["
	For Local a := Eachin arr
		text += a + ","	
	End
	Return text.Slice(0,text.Length-1) + "]"
End



