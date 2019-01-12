Namespace std.random

#Import "<std>"

Using std..

'Shuffles a stack randomly.
Class Stack<T> Extension
	Method Shuffle()
		For Local i := 0 Until Length
			Local ia := Int(Rnd(0, Length))
			Local ib := Int(Rnd(0, Length))
			Swap(ia, ib)
		Next
	End
End

'Randomly returns True or False, given a probability for True.
Function RandomChance:Bool( probability:Float )
	If Rnd( 0.0, 1.0 ) < probability
		Return True
	Else
		Return False
	End
End

'Returns a rendom item from an array.
Function RandomPick<T>:T( choices:T[] )
	Return choices[ Round( Rnd( 0.0, 1.0 ) * (choices.Length-1.0) ) ]
End

'Returns a rendom item from an array, based on a probability for each item.
'Each chance should be a number between 0 and 1.0
'All chances should add up to 1.0.
'Example: RandomPick( [1,2,3], [0.2, 0.5, 0.3])
Function RandomPick<T>:T( choices:T[], chances:Float[] )
	local totalChance:Float = 0.0
	For Local n := 0 Until choices.Length
		totalChance += chances[n]
		local random :Float = Rnd( 0.0, 1.0 )
		If random <= totalChance
			Return choices[n]
		End
	End
	Return choices[ choices.Length - 1 ]
End