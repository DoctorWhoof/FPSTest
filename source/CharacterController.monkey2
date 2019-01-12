Namespace fpsdemo

'TO DO:
'Implement triggers - do not rely on physics. Triggers will be bounding box only, and will not interfere with collision results.
'Eliminate X rotation on entity. Only rotate camera, transform entity using camera vector when moving.
'Limit diagonal speed

'Try: make speed proportional to slope. Maybe this will automatically limit high slopes from being climbed.
'Stick character to ground when going downhill (currently bounces)
'Allow movement without a collider (assert was already removed, now need to modify code)
'Remove LimitedMovement, replace it with copying the axis original position in the end if the axis is locked

Class CharacterController Extends Behaviour
	
	Field speed := 1.0					'Meters per second.
	Field jumpSpeed := 1.0				'Make sure you adjust the Scene.World.Gravity for proper feel.
	Field climbSpeed := 1.0				'This is used going up ladders
	Field runMultiplier := 3.0
	
	Field headBobAmount := 0.05			'How many meters the head bobs when walking
	Field headBobFrequency := 2.5		'How times per second the head completes a bob
	
	Field slopeSlide := 45.0			'Slopes higher than this angle cause character to slide down.
	Field slopeStop := 60.0				'Slopes higher than this angle cause character stop walking.
	
	Field constantSpeed := New Vec3f	'Applies this speed regardless of input
	Field useLocalTransforms := True	'Mojo3D seems inverted? False means true...

	Field horizontalAxis := Axis.X
	Field verticalAxis := Axis.Y
	Field jumpAxis := Axis.Y
	
	Field allowJump := False
	Field allowGravity := False
	
	Field firstPerson := False
	Field fpsCamera :Camera
	Field mouseSensitivity := 0.1
	
	Field lockXMovement := False
	Field lockYMovement := False
	Field lockZMovement := False
	
	Field collidesWith:Int = -1
	Field movementLimit :Boxf

	Protected
	Field _collider:ConvexCollider
	Field _player:Player
'	Field _colMesh :Model
'	Field _colMat :PbrMaterial

	Field _isColliding:= False
	Field _isFlying:=False
	Field _isMoving:= False
	Field _isJumping:=False
	Field _onwall:Bool
	Field _onground:Bool
	Field _hitGround:Bool
	Field _ontrigger:RigidBody

	Field _prevPosition:Vec3f
	Field _prevMouse:Vec2f
	Field _previousRes:QResult
	Field _previousColBody:RigidBody
	Field _previousMovingPos:Vec3f

	Field _previousClock:Double
	Field _bobClock:Double

	Field _slopeSlide:Float
	Field _slopeStop:Float
	Field _grav:Float
	Field _src:Vec3f
	Field _step1:Vec3f
	Field _step2:Vec3f
	
	Field _qres:QResult
	Field _xResult:QResult
	Field _yResult:QResult

	Const _normalizedDelta := Double(1.0) / Double(60.0)
	
	Public
	
	Method New( entity:Entity )
		Super.New( entity )
	End
	
	Property OnGround:Bool()
		Return _onground
	End
	
	Property OnWall:Bool()
		Return _onwall
	End

	Method OnStart() Override
		_collider = Cast<ConvexCollider>( Entity.Collider )
		_player = Entity.GetComponent<Player>()
		_slopeSlide = Cos( DegToRad(slopeSlide) )
		_slopeStop= Cos( DegToRad(slopeStop) )
	End
	
	'Required for proper collision when parent is moving
	Method OnBeginUpdate() Override
		_isMoving = False
		_hitGround = False
		_src = Entity.Position
		_ontrigger = Null
	End
	
	'Here's where the movement happens
	Method OnUpdate( elapsed:Float ) Override
	
		Local finalSpeed := speed
		
		If firstPerson
			'De-initializes mouselook if escape is pressed
			If Keyboard.KeyHit( Key.Escape )
				_prevMouse = Null
				Mouse.PointerVisible = True
			End
		
			If _prevMouse
				'Only starts updating if _prevMouse is initialized
				Local deltaX := ( Float(Mouse.Y) - _prevMouse.Y ) * mouseSensitivity
				Local deltaY := ( Float(Mouse.X) - _prevMouse.X ) * -mouseSensitivity
				Entity.RotateY( deltaY )
				If _isFlying
					Entity.RotateX( deltaX )
					Entity.Rz = 0
				Else
					If fpsCamera
						fpsCamera.RotateX( deltaX )
						fpsCamera.Rz = 0
					End
				End
			Else
				'initializes mouselook only if mouse is clicked and _prevMouse is null
				If Mouse.ButtonHit( MouseButton.Left )
					_prevMouse = New Vec2f( Float( Mouse.X ), Float( Mouse.Y ) )
					Mouse.PointerVisible = False
				End
			End
		End
		
		If _player
			If _player.IsHolding( "Run" )
				finalSpeed = speed * runMultiplier
			End
			If _player.HasHit( "Fly" )
				_grav = 0
				_isFlying = Not _isFlying
				If Not _isFlying
					StartFlying()
				Else
					EndFlying()
				End
			End
		End
		
		
		If _isFlying
			Fly( finalSpeed, elapsed )
			Echo.Add( "Flying", Color.Pink )
		Else
			Walk( finalSpeed, elapsed )
		End
		
		_onground=_yResult.onground
		_onwall=_xResult.onwall
		
		SendCollisionEvents()
		
		If movementLimit
			If Entity.LocalX > movementLimit.max.X
				Entity.LocalX = movementLimit.max.X
			End
			If Entity.LocalX < movementLimit.min.X
				Entity.LocalX = movementLimit.min.X
			End
			If Entity.LocalY > movementLimit.max.Y
				Entity.LocalY = movementLimit.max.Y
				_grav = 0
			End
			If Entity.LocalY < movementLimit.min.Y
				Entity.LocalY = movementLimit.min.Y
				_grav = 0
				_onground = True
			End
			If Entity.LocalZ > movementLimit.max.Z
				Entity.LocalZ = movementLimit.max.Z
			End
			If Entity.LocalZ < movementLimit.min.Z
				Entity.LocalZ = movementLimit.min.Z
			End
		End
		
		If _onground Then _isJumping = False
		If _isMoving Then _previousMovingPos = Entity.Position
		_previousRes = _qres
		_prevPosition = Entity.Position
		
	End
	
	'Mouse re-centering
	Method OnEndUpdate() Override
		If firstPerson
			'Mouse centering. Does not run if _prevMouse is not initialized (first click hasn't happened)
			If _prevMouse
				Local threshold := App.ActiveWindow.Height / 10
				Local center := New Vec2i( App.ActiveWindow.Width/2, App.ActiveWindow.Height/2 )
				Local limit := New Recti( center.X - threshold, center.Y - threshold, center.X + threshold, center.Y + threshold )
				If Mouse.X < limit.Left Or Mouse.X > limit.Right Or Mouse.Y < limit.Top Or Mouse.Y > limit.Bottom
					Mouse.Location = New Vec2i( center.X, center.Y )
				End
				
				_prevMouse = New Vec2f( Float( Mouse.X ), Float( Mouse.Y ) )
			End
		End
	End
	
	'Requires mojogame library
	Method OnCopy:CharacterController( e:Entity ) Override
		Local c:=New CharacterController( e )
'		c.CopyState( GetSavedState() )
		Return c
	End
	
	Protected
	
	Method LimitedMove( axis:Axis, amount:Float, elapsed:Float )
		If axis = Axis.X And Not lockXMovement Then Entity.MoveX( amount * elapsed, Not useLocalTransforms )
		If axis = Axis.Y And Not lockYMovement Then Entity.MoveY( amount * elapsed, Not useLocalTransforms )
		If axis = Axis.Z And Not lockZMovement Then Entity.MoveZ( amount * elapsed, Not useLocalTransforms )
	End
	
	Method LimitedMove( goal:Vec3f )
		If Not goal Return
		If Not lockXMovement Then Entity.X = goal.X
		If Not lockYMovement Then Entity.Y = goal.Y
		If Not lockZMovement Then Entity.Z = goal.Z
	End
	
	Method Walk( _speed:Float, elapsed:Float )
		HorizontalMovement( _speed, elapsed )
		
		'Gravity
		If allowGravity
			'Only increase gravity if not on ground. Does not zero it, in order for _onGround to work properly.
			'The "modifiers" section will later deal with locking horizontal movement if on ground
			If Not _onground
				_grav +=( Entity.Scene.World.Gravity.Y * elapsed )
			End
		End

		'Jump
		If _player?.HasHit( "Jump" ) And allowJump
			If Not _isJumping
				_isJumping=True
				_grav= jumpSpeed
			End
		Endif
		
		Entity.Move( Axis.Y, _grav * elapsed )
		
		If _collider
			_yResult = QCollide( _step1, Entity.Position, collidesWith )
			_step2 = _yResult.position
			Entity.Position = _step2
		End
				
		'Populate collision results
		If _xResult.body Then _qres = _xResult
		If _yResult.body Then _qres = _yResult
		
		'Modifiers
		If _qres.body
			If _isJumping
				If Not _qres.onground
					'Character hits head while jumping, instantly loses all vertical momentum.
					If _qres.normal.Y < -0.1 And _grav > 0
						_grav = 0.0
					End
				End
			Else
				If allowGravity
					If _qres.onground
						If Not _isMoving
							'When idle, Prevent sliding down slopes above threshold
							If _yResult.normal.Y >= _slopeSlide
								Entity.Position = _step1
							End
						Else
							'When moving, prevent moving up steep slopes. Not working yet.
'							Echo.Add( "xresult normal.Y:" + _yResult.normal.Y, Color.Cyan )
'							Echo.Add( "slopeStop:" + _slopeStop, Color.Cyan )
'							Echo.Add( "Dot:" + _yResult.normal.Dot( Entity.Forward ) )
'							If _yResult.normal.Y < _slopeStop
'								If _yResult.normal.Dot( Entity.Forward ) < 0
'									Entity.Position = _src
'								End
'							End
						End
					End
				End
			End
		End
		
		If fpsCamera And _onground
			Local dt := Clock.Now() - _previousClock
			Local mult := _prevPosition.Distance( Entity.Position ) / ( speed / App.FPS )
'			Echo.Add( _prevPosition.Distance( Entity.Position ), Color.Pink )
			If _isMoving
'				If Not _bobClock
'					dt = 0
'				End
				_bobClock += dt
				fpsCamera.LocalY = Sin( _bobClock * headBobFrequency * Tau ) * headBobAmount * mult
				fpsCamera.LocalX = Sin( ( _bobClock - 0.25 ) * headBobFrequency * Pi ) * headBobAmount * 0.5 * mult
			End
			_previousClock = Clock.Now()
		End
		
		Echo.Add( "onGround:" + _onground, Color.Pink )
			
	End
	
	Method Fly( _speed:Float, elapsed:Float )
		HorizontalMovement( _speed, elapsed )
		'Populate collision results
		If _xResult.body Then _qres = _xResult
		If _yResult.body Then _qres = _yResult
	End

	Method HorizontalMovement( _speed:Float, elapsed:Float )
		'Horizontal step
		If constantSpeed.X <> 0.0
			_isMoving=True
			LimitedMove( horizontalAxis, constantSpeed.X, elapsed )
		End
		
		If _player
			If _player.IsHolding( "Left" )
				LimitedMove( horizontalAxis, -_speed, elapsed )
				_isMoving=True
			Else If _player.IsHolding( "Right" )
				LimitedMove( horizontalAxis, _speed, elapsed )
				_isMoving=True
			Endif
			If verticalAxis = Axis.Z
				If _player.IsHolding( "Up" )
					LimitedMove( verticalAxis, _speed, elapsed )
					_isMoving=True
				Else If _player.IsHolding( "Down" )
					LimitedMove( verticalAxis, -_speed, elapsed )
					_isMoving=True
				Endif
				
				If constantSpeed.Z <> 0.0
					_isMoving=True
					LimitedMove( verticalAxis, constantSpeed.Z, elapsed )
				End
			End
		End
		
		If _collider
			_ontrigger = QCollide( Entity.Position+New Vec3f(0,0.1,0), Entity.Position+New Vec3f(0,-0.1,0), Group.Trigger ).body
			_xResult = QCollide( _src, Entity.Position, collidesWith )
			_step1 = _xResult.position
			LimitedMove( _step1 )
		Else
			_step1 = Entity.Position
		End
		
		'Y step
		If verticalAxis = Axis.Y
			If _player
				If _player.IsHolding( "Up" )
					LimitedMove( verticalAxis, _speed, elapsed )
					_isMoving=True
				Else If _player.IsHolding( "Down" )
					LimitedMove( verticalAxis, -_speed, elapsed )
					_isMoving=True
				Endif
			End
		End
		
		If constantSpeed.Y <> 0.0
			_isMoving=True
			LimitedMove( verticalAxis, constantSpeed.Y, elapsed )
		End
	End
	
	
	Method SendCollisionEvents()
		'Requires mojogame library
		If _qres.body
			If _isColliding
'				Entity.CollisionStay( _qres.body.Entity )
				Else
				_previousColBody = _qres.body
'				Entity.CollisionEnter( _qres.body.Entity )
'				Entity.CollisionStay( _qres.body.Entity )
				_isColliding = True
'				If _qres.onground Then _hitGround = True
			End
		Else
			If _previousColBody
'				Entity.CollisionLeave( _previousColBody.Entity )
				_previousColBody = Null
			End
			_isColliding = False
		End
	End
	
	
	Method StartFlying()
		Local tempRx := Entity.LocalRx
		Entity.LocalRx = 0
		fpsCamera?.Rx = tempRx
	End
	
	Method EndFlying()
		If fpsCamera
			Entity.Rx = fpsCamera.LocalRx
			fpsCamera.LocalRx = 0
		End
	End

	'********************************* QCollide *********************************
	
	Internal

	'Modified Mark Sibly's QCollide
	Method QCollide:QResult( src	:Vec3f, dst:Vec3f, mask:Int  )
	
		If Not _collider Return Null
		
		Local margin:= 0.01
		Local world:=Entity.Scene.World
		Local plane0:Planef
		Local plane1:Planef
		Local state:=0
		Local casts:=0
		Local qresult:QResult
		
		Repeat
			If src.Distance( dst )<.0001
				dst=src
				Exit
			Endif
	
			casts+=1
			
			
			Local cresult:=world.ConvexSweep( _collider, src, dst, mask )
			If Not cresult Exit
			Echo.Add( "QCollide: " + mask + "; " + cresult.body.Entity.Name + ":" + cresult.body.CollisionGroup, Color.Orange )
			
			If mask = Group.Trigger
				If cresult.body
					qresult.position=dst
					qresult.ontrigger = cresult.body
					Echo.Add( "OnTrigger: " + cresult.body.Entity.Name, Color.Sky )
					Return qresult
				End
			End
			
			qresult.body = cresult.body
			qresult.normal = cresult.normal
		
			If cresult.normal.y>.5
				qresult.onground=True
			Endif
			
			If cresult.normal.y<0.1 And cresult.normal.y >-0.1
				qresult.onwall=True
			Endif
				
			Local plane:=New Planef( cresult.point,cresult.normal )
			plane.d-=margin
			
			Local d0:=plane.Distance( src ),d1:=plane.Distance( dst )
			Local tline:=New Linef( src,dst-src )
			Local t:=plane.TIntersect( tline )
			
			If t>0
				src=tline * t
			Endif
	
			Select state
				Case 0
					Local tdst:=plane.Nearest( dst )
					dst=tdst
					plane0=plane
					state=1
				Case 1
					Local v:=plane0.n.Cross( plane.n )
					If v.Length>.00001
						Local groove:=New Linef( src,v )
						dst=groove.Nearest( dst )
						plane1=plane
						state=2
					Else
						Print "QCollide OOPS2"
						dst=src
						Exit
					Endif
				Case 2
					dst=src
					Exit
			End
		Forever
		
		If casts>3 Print "QCOLLIDE OOPS3 casts="+casts
	
		qresult.position=dst
		Return qresult
	End
	
End

Internal

Struct QResult
	Field position:Vec3f
	Field normal:Vec3f
	Field onground:Bool
	Field onwall:Bool
	Field ontrigger:RigidBody
	Field body:RigidBody
End

