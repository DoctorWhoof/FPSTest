Namespace clock

#Import "<std>"
#Import "Clock"

Using std..

Class Job
	'these fields alter the interval in a random fashion
	Field minRandom := 0.0
	Field maxRandom := 0.0
	Field owner := "none"
	
	Protected
	Field _func :Void()		'The function to be executed
	Field _length :Double	'interval, in seconds
	
	Field _loop :Bool
	Field _startTime	:Double = 0.0
	Field _randomTime :Double = 0.0
	Field _paused := False
	Field _dead := False
	
	Global routines := New Stack< Job >
		
	Public
	'Length of interval measured in seconds
	Method New( length:Double, loop:Bool, func:Void(), owner:String = Null )
		_length = length
		_func = func
		_loop = loop
		_startTime = Clock.Now()
		If owner <> Null Then Self.owner = owner
		routines.Push( Self )
	End

	
	Method Update( time:Double )
		If time >= ( _startTime + _length + _randomTime )
			_func()
			If _loop
				If ( minRandom<>0.0 ) Or ( maxRandom<>0.0 )
					_randomTime = Rnd( minRandom, maxRandom )
				End
				_startTime = time
			Else
				Kill()
			End
		End
	End
	
	
	Method Kill()
		_dead = True
'		SafeDelete()
	End

	
	'***********************************************************************************************
	
	Function UpdateAll( time:Double )
'		Echo.Add( routines.Length, Color.Pink )
		
		'Safe iterate, prevents some weird errors in corner cases
		If Not routines.Empty
			Local n := 0
			Local j := routines[n]
			Repeat
				If Not j._paused Then j.Update( time )
				n += 1
				If n >= routines.Length Then Exit
				j = routines[n]
			Until j = Null
		End
		'Delete dead routines
		SafeDelete()
	End
	
	Function SafeDelete()
		'Delete dead routines
		Local it:= routines.All()
		While Not it.AtEnd
			Local item:=it.Current
			If item._dead
				it.Erase()
			Else
				it.Bump()
			End
		Wend
	End
	
'	Function KillByOwner( ownerName:String )
'		Print( "Attempting to kill " + ownerName )
'		If ownerName
'			For Local s := Eachin routines
'				If s.owner = ownerName
'					s.Kill()
'					Print( "Killed routine owned by " + s.owner )
'				End
'			Next
'		End
'	End

End


Function Delay:Job( length:Double, func:Void() )
	Local newDelay := New Job( length, False, func )
	Return newDelay
End


Function Delay:Job( length:Double, loop:Bool, func:Void() )
	Local newDelay := New Job( length, loop, func )
	Return newDelay
End

