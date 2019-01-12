Namespace mojogame

Const hit :UInt = 1
Const hold :UInt = 2
Const release :UInt = 4

Class Player Extends Component Abstract

	Const Type:=New ComponentType( "Player",0,Null )
	
	Field alwaysMove		:= False				'true for Pac-Man or Snake style control (reads KeyHit, instead of KeyDown)
'	Field preventFlip		:= False			'prevents direction from changing 180 degrees (like in a Snake game)
'	Field directionStacking	:= True				'Allows direction commands to stay until they're manually cleared by a component (i.e. MotionGrid )
'	Field stackingLimit		:= 2

	Protected
	Field controls 			:= New Map< Key, Control >
	Field suspended			:= False
	
	Field commands			:= New Map< String, String >	'commands list, with subcommands (i.e. 'Use''LeftHand', 'Use''Weapon', etc.)
	Field previousCommands	:= New Map< String, String >

	'****************************** Public Properties ******************************

	Public
	Property IsEmpty:Bool()
		If commands.Empty Then Return True Else Return False
	End

	'****************************** Public Methods ******************************

	Method New( entity:Entity )
		Super.New( entity,Type )
	End


	Method OnBeginUpdate() Override
		previousCommands.Clear()
		previousCommands = commands.Copy()
		commands.Clear()
	End


'	Method Suspend( length:Double )
'		suspended = True
'		Delay( length, Lambda()
'			suspended = False
'		End )
'	End


	Method Resume()
		suspended = False
	End


	Method Hold( command:String, subcommand:String = "", clear:Bool= False )
		If Not suspended
			If clear Then commands.Clear()
			commands.Add( command, subcommand )
		End
	End
	
	
	Method IsHolding:Bool( key:String )
		If commands.Contains( key )
			Return True
		End
		Return False
	End
	
	
	Method HasHit:Bool( key:String )
		If commands.Contains( key )
			If Not previousCommands.Contains( key )
				Return True
			End
		End
		Return False
	End
	
	
	Method HasReleased:Bool( key:String )
		If Not commands.Contains( key )
			If previousCommands.Contains( key )
				Return True
			End
		End
		Return False
	End


	Method SubCommand:String( key:String )
		If commands.Contains( key )
			Return commands[key]
		Else
			If previousCommands.Contains( key )
				Return previousCommands[key]
			End
		End
		Return Null
	End
	

	Method SetControl( key:Key, command:String, subcommand:String )
		If controls.Contains( key ) Then controls.Remove( key )
		controls.Add( key, New Control( Self, key, command, subcommand ) )
		Print "Control (" + command + ", " + subcommand + ") added to key '" + Int(key) + "'" 
	End


	Method List()
		For Local c := Eachin commands.Keys
			Echo.Add( c )
		Next
	End


	' Method GetTopDirection:Int()
	' 	If Not directions.IsEmpty()
	' 		Return directions.Top()
	' 	Else
	' 		Return ""
	' 	End
	' End


	' Method RemoveTopDirection:Int()
	' 	If Not directions.IsEmpty()
	' 		Return directions.Pop()
	' 	End
	' End


	' Method WaitLag:Int(MyLag:Int)				'Returns True If the specified lag has elapsed
	' 	If TimeRef = 0
	' 		TimeRef = Millisecs()				'Starts counting
	' 		Return True
	' 	Else
	' 		If TimeRef < Millisecs() - MyLag	'Compares it with MyLag
	' 			TimeRef = 0
	' 			Return False
	' 		End
	' 	End
	' End


End


'***************************************************************************************************

Class Control
	Field key:Key
	Field command:String
	Field subcommand:String
	Field style:Int

	Private
	Field player:Player

	Public
	Method New( player:Player, key:Key, command:String, subcommand:String )
		Self.player = player
		Self.command = command
		Self.subcommand = subcommand
		Self.key = key
	End

	Method Update()
		If Keyboard.KeyDown( key ) Then player.Hold( command, subcommand )
	End
	
End
