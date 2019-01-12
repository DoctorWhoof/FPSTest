Namespace echo

#Import "<mojo3d>"
#Import "<std>"

Using mojo3d..
Using mojo..
Using std..

Class Echo
	
	Global font:Font
	Global scale:= 1.0
	Global showChildren:= False
	
	Private
	
	Global _textStack:= New StringStack
	Global _colorStack:= New Stack<Color>
	Global _width :Int
	Global _border :Int
	
	Public
	
	'************************************* Public static functions *************************************
	
	'Use this to add text to the Echo Display
	Function Add( text:String, color:Color = Color.White )
		_textStack.Push( text )
		_colorStack.Push( color )
	End
	
	
	'This will echo the entire mojo3d scene hierarchy, recursively
	Function Add( scene:Scene )
		Add( "Scene", Color.LightGrey )
		For Local e := EachIn scene.GetRootEntities()
			Local color := ( e.Visible? Color.White Else Color.Grey )
			Echo.Add( e, ".   ", showChildren, color )
		End
	End
	
	Function Add( e:Entity, tab:String, showChildren:Bool, color:Color )
		
		Local name := e.Name
		If e.Children And Not showChildren Then name += " (+)"
		
		Echo.Add( tab + name, color )
		If e.Children
			If showChildren
				If e.Children.Length > 20
					Echo.Add( tab + tab + "(" + e.Children.Length + " children...)", color/1.2 )
				Else
					For Local c := Eachin e.Children
						Echo.Add( c, tab + ".   ", showChildren, color )
					Next
				End
'			Else
					
			End
		End
	End
	
	'Rect width
	Function Width:Int()
		Return _width+_border+_border
	End
	
	'Draws all echo messages
	Function Draw( canvas:Canvas, x:Int=0, y:Int=0, rectAlpha:Float = 0.5, border:Int = 5 )
		
		_border = border
		
		If font Then canvas.Font = font
		
		canvas.PushMatrix()
		canvas.Scale( scale, scale )
		
		Local lineY := 2
		
		'Figure out dimensions.
		_width = 0
		For Local n := 0 Until _textStack.Length
			local text := _textStack[ n ]
			Local size := canvas.Font.TextWidth( text )
			If( size > _width ) _width = size
		Next
		
		'Draw rect
		If rectAlpha > 0.01
			canvas.Alpha = rectAlpha
			canvas.Color = New Color( 0, 0, 0 )
			canvas.DrawRect( x-border, y+lineY-border, Width(), (canvas.Font.Height*_textStack.Length)+border+border )
		End
		
		'Draw text
		For Local n := 0 Until _textStack.Length
			local text := _textStack[ n ]
			canvas.BlendMode = BlendMode.Alpha
			canvas.Alpha = 1.0
	
			canvas.Color = _colorStack[ n ]
			canvas.DrawText( text, x, y+lineY )
			lineY += canvas.Font.Height
		Next
		
		canvas.PopMatrix()
		Clear()
	End
	
	'Clears stacks. MUST BE CALLED when not drawing the current messages or the stacks will grow until they explode.
	Function Clear()
		_textStack.Clear()
		_colorStack.Clear()
	End
	
	
End

'********************************   Extensions   ********************************

'Class Entity Extension
'	
'	Method Echo( tab:String )
'		util.Echo.Add( tab + Name )
'		For Local c := Eachin Children
'			c.Echo( tab + ".   " )
'		Next	
'	End	
'	
'End
