
Namespace mojogame.util

'Provides unique collision ID (read only) to each group instance

Enum Group
	None
	MousePick
	Player
	Terrain
	Enemy
	Props
	Obstacle
	Trigger
	NPC
End

#Rem

Class Group
	
	Field animationModifier:String
	Field speedModifier:Float
	
'	Global Player := New Group
'	Global NPC := New Group
'	Global Enemy := New Group
'	Global Item := New Group
'	
'	Global Terrain := New Group
'	Global Water := New Group
'
'	Global Platform := New Group
'	Global Ladder := New Group
'	Global Obstacle := New Group
'	Global Door := New Group
'
'	Global KIllzone := New Group
'	Global Portal := New Group
'	Global Trigger := New Group

	Private

	Field _collisionMask:Short
	Global _currentIndex :Short = 0

	Public
	
	'************************************* Public Properties *************************************
	
	Property CollisionMask:Short()
		Return _collisionMask
	End
	
	'************************************* Public Methods *************************************
	
	Method New()
		_currentIndex += 1
		_collisionMask = _currentIndex
		Assert( _collisionMask < 16, "~nGroup: Max number of groups (16) reached! This is a Bullet Physics limitation.~n")
		Print "New Group, CollisionMask " + _collisionMask
	End
	
End
