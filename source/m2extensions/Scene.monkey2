
Namespace m2extensions

Class Scene Extension
	
	Method Find<T>:T( name:String )
		Local e := FindEntity( name )
		If e
			Print name + " found."
			Return Cast<T>( e )
		End
		Print name + " not found!"
		Return Null
	End
	

	Function FindCamera:Camera( entities:Entity[] )
		Local cam:Camera
		For Local e:= Eachin entities
			Local candidate := Cast<Camera>( e )
			If candidate
				Print "Scene: Camera named '" + candidate.Name + "' Found"
				Return candidate
			Else
				cam = FindCamera( e.Children )
			End
		Next
		Return cam
	End

End
