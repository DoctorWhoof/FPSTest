Namespace clock

#Import "<std>"
#Import "<mojo>"

Using std..
Using mojo..

Class Clock

	Global scale:Double = 1.0		'Set this to slow down or speed up time
	Global frequency:Int = 60

	Private
	Global _now:Double						'The current time, in seconds
	Global _last:Int						'Used to get the time elapsed since the last frame
	Global _paused:Bool = False				'Current pause state
	Global _delta:Double					'holds Delta timing (using a 60fps frame rate as reference)
	Global _timer:Timer
	
	'********************** Functions **********************
	
	Public
	
	'Main time advance, called by the timer
	Function Update()
		_delta = ( Microsecs() - _last ) / ( 1000000.0 / scale )
		If Not _paused And App.Active
			_now += _delta
		End
		_last = Microsecs()
	End
	
	Function Now:Double()
		Return _now
	End
	

	Function Start()
		Reset()
	End


	Function Reset()
		_now = 0.0
		_delta = 1.0
		_paused = False
		_last = Microsecs()
	End
	
	
	Function Pause( state:Bool )
		_paused = state
	End
	
	
	Function PauseToggle()
		_paused = Not _paused
	End
	

	'Prevents "elapsed" time from varying too much from frame to frame
	Function SmoothElapsed:Double( elapsed:Double )
		Local deltaLimit:Double= (Double(1.0)/Double(App.FPS))*1.2		'20% tolerance
		If elapsed > deltaLimit
			elapsed = deltaLimit
		End
		Return elapsed
	End
	
	
	Function Delta:Double( elapsed:Double = -1.0, speed:Float = 60.0 )
		'If provided an elapsed time, use that instead of internal time.
		If elapsed > 0
			Return SmoothElapsed( elapsed ) * speed
		End
		Return SmoothElapsed( _delta ) * speed
	End
	
End