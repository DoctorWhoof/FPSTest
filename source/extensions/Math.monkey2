
Namespace monkey.math

Const degToRad :Double = Pi / 180.0
Const radToDeg :Double = 180.0 / Pi
Const one :Double = 1.0					'This is just to ensure 1.0 is a double, not float

'*********************** Math functions ***********************

Function Normalize:Double( min:Double, max:Double, current:Double )
	Local range :Double = max - min
	If( range = 0 ) Return 0.0
	Return  Clamp<Double>( ( current - min )/range, 0.0, 1.0 )
End


Function Fractional:Float( x:Float )
	Return ( x - Floor(x) )
End


'LINEAR interpolation
Function Mix:Double( a:Double, b:Double, mix:Double )
	Return ( a * ( 1 - mix ) ) + ( b * mix )
End

'SMOOTH interpolation
Function SmoothMix:Double( a:Double, b:Double, mix:Double )
	Local range :Double = b - a
	If range < 0.000001 And range > -0.000001 Then Return a
	Local x := mix * mix * mix * ( mix * ( ( mix * 6 ) - 15 ) + 10 )
	Return( x * range ) + a
End

'Normalized SMOOTH interpolation
Function SmoothStep:Double( a:Double, b:Double, mix:Double )
	Local range :Double = b - a
	If range < 0.000001 And range > -0.000001 Then Return 0.0
	mix = Clamp<Double>( (mix - a) / (b - a), 0.0, 1.0 )
	Return mix * mix * mix * ( mix * ( ( mix * 6 ) - 15 ) + 10 )
End

'Old, flaky smooth interpolation
Function Smooth:Double( a:Double, b:Double, rate:Double = 10.0, delta:Double = one )
	If rate <= 1.0 Then Return b
	Return a + ( (a - b) / (-rate/(delta*delta) ) )
End

'Quantization functions
Function Quantize:Double( number:Double, size:Double )
	If size Then Return Round( number / size ) * size
	Return number
End


Function QuantizeDown:Double( number:Double, size:Double )		'Snaps to nearest lower value multiple of size
	If size Then Return Floor( number / size ) * size
	Return number
End


Function QuantizeUp:Double( number:Double, size:Double )		'Snaps to nearest upper value multiple of size
	If size Then Return Ceil( number / size ) * size
	Return number
End

'Angle functions
Function AngleBetween:Double(x1:Double, y1:Double, x2:Double, y2:Double)
	Return ATan2((y2 - y1), (x2 - x1)) * radToDeg
End


Function RadToDeg:Double ( rad:Double )
	Return rad * radToDeg	'( 180.0 / Pi )
End


Function DegToRad:Double( deg:Double )
	Return deg * degToRad	'( Pi / 180.0 )
End

#rem monkeydoc
Returns the nearest "power of two" number (64, 128, 256, 512, 1024, etc).
#end
Function NearestPow:Int( number:Int )
	Return Pow( 2, Ceil( Log( number )/Log( 2 ) ) )
End


'Misc
'Untested since monkey-x!
'Function DeltaMultiply:Double( value:Double, multiplier:Double, delta:Double )
'	Local attenuation := ( one - ( ( one - multiplier ) * delta ) )
'	Return( value * attenuation )
'End
'Function DeltaMultiply:Vec2<Double>( vec:Vec2<Double>, multiplier:Double, delta:Double )
'	Local attenuation := ( one - ( ( one - multiplier ) * delta ) )
'	Return( vec * attenuation )
'End
