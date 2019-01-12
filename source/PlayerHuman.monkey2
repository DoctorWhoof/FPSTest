Namespace mojogame

Class PlayerHuman Extends Player

	Method New( entity:Entity )
		Super.New( entity )
		SetControl( Key.Up, "Up", "" )
		SetControl( Key.Down, "Down", "" )
		SetControl( Key.Left, "Left", "" )
		SetControl( Key.Right, "Right", "" )
	End

	Method OnBeginUpdate() Override
		Super.OnBeginUpdate()

		For Local c := Eachin controls.Values
			c.Update()
		Next
		
'		For Local c := Eachin commands.Keys
'			Echo.Add( c + ":" + commands[c] )
'		End
	End

End
