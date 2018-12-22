Namespace fpsdemo

'TO DO:
'Limit diagonal speed
'Stick character to ground when going downhill (currently bounces)
'Allow movement without a collider (assert was already removed, now need to modify code)

Class CharacterController Extends Behaviour
	
	Field speed := 1.0		'Units per frame
	Field jumpSpeed := 0.5
	Field slopeThreshold := 45.0		'Slopes higher than this angle cause character to slide down
	
	Field constantSpeed := New Vec3f
	Field useLocalTransforms := False

	Field horizontalAxis := Axis.X
	Field verticalAxis := Axis.Y
	
	Field jumpAxis := Axis.Y
	
	Field allowJump := False
	Field allowGravity := False
	
	Field firstPerson := False
	Field firstPersonCamera :Camera
	Field mouseSensitivity := 0.1
	
	Field lockXMovement := False
	Field lockYMovement := False
	Field lockZMovement := False
	
	Field collidesWith:Short = -1
	Field movementLimit :Boxf

	Protected
	Field _col:ConvexCollider
	Field _colMesh :Model
	Field _colMat :PbrMaterial

	Field _isColliding:= False
	Field _isMoving:= False
	Field _jumping:Bool
	Field _onwall:Bool
	Field _onground:Bool
	Field _hitGround:Bool

	Field _prevMouse:Vec2f
	Field _previousRes:QResult
	Field _previousColBody:RigidBody

	Field _slopeY:Float
	Field _grav:Float
	Field _src:Vec3f
	Field _step1:Vec3f
	Field _step2:Vec3f
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
		_col = Cast<ConvexCollider>( Entity.Collider )
		_slopeY = Cos( DegToRad(slopeThreshold) )
	End
	
	
	'Required for proper collision when parent is moving
	Method OnBeginUpdate() Override
		_isMoving = False
		_hitGround = False
		_src = Entity.Position
	End
	
	'Here's where the movement happens
	Method OnUpdate( elapsed:Float ) Override
	
		Local delta := elapsed / _normalizedDelta
		
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
				If firstPersonCamera
					firstPersonCamera.RotateX( deltaX )
				End
			Else
				'initializes _prevMouse only if mouse is clicked
				If Mouse.ButtonHit( MouseButton.Left )
					_prevMouse = New Vec2f( Float( Mouse.X ), Float( Mouse.Y ) )
					Mouse.PointerVisible = False
				End
			End
			
		End
		
		'Horizontal step
		If Keyboard.KeyDown( Key.A )
			LimitedMove( horizontalAxis, -speed, delta )
			_isMoving=True
		Else If Keyboard.KeyDown( Key.D )
			LimitedMove( horizontalAxis, speed, delta )
			_isMoving=True
		Endif
		
		If constantSpeed.X <> 0.0
			_isMoving=True
			LimitedMove( horizontalAxis, constantSpeed.X, delta )
		End
		
		If verticalAxis = Axis.Z
			If Keyboard.KeyDown( Key.W )
				LimitedMove( verticalAxis, speed, delta )
				_isMoving=True
			Else If Keyboard.KeyDown( Key.S )
				LimitedMove( verticalAxis, -speed, delta )
				_isMoving=True
			Endif
			
			If constantSpeed.Z <> 0.0
				_isMoving=True
				LimitedMove( verticalAxis, constantSpeed.Z, delta )
			End
		End
		
		If _col
			_xResult = QCollide( _src, Entity.Position )
			_step1 = _xResult.position
			LimitedMove( _step1 )
		Else
			_step1 = Entity.Position
		End
		
		'Y step
		If verticalAxis = Axis.Y
			If Keyboard.KeyDown( Key.W )
				LimitedMove( verticalAxis, speed, delta )
				_isMoving=True
			Else If Keyboard.KeyDown( Key.S )
				LimitedMove( verticalAxis, -speed, delta )
				_isMoving=True
			Endif
		End
		
		If constantSpeed.Y <> 0.0
			_isMoving=True
			LimitedMove( verticalAxis, constantSpeed.Y, delta )
		End
		
		'Gravity
		If allowGravity
			If _onground
				_grav=-Entity.Collider.Margin
			End
'			If _previousRes.normal.Y >= _slopeY
'				_grav=-Entity.Collider.Margin
'			End
			_grav+=( Entity.Scene.World.Gravity.Y * elapsed )
		End

		'Jump
		If Keyboard.KeyHit( Key.Space ) And allowJump And Not _jumping
			_jumping=True
			_grav= jumpSpeed
		Endif
		
		Entity.Move( Axis.Y, _grav )
		
		If _col
			_yResult = QCollide( _step1, Entity.Position )
			_step2 = _yResult.position
			Entity.Position = _step2
		End
				
		'Collision events
		Local qres:QResult
		If _xResult.body Then qres = _xResult
		If _yResult.body Then qres = _yResult

'		If qres.body
'			If _isColliding
'				Entity.CollisionStay( qres.body.Entity )
'			Else
'				_previousColBody = qres.body
'				Entity.CollisionEnter( qres.body.Entity )
'				Entity.CollisionStay( qres.body.Entity )
'				_isColliding = True
'				If qres.onground Then _hitGround = True
'			End
'		Else
'			If _previousColBody
'				Entity.CollisionLeave( _previousColBody.Entity )
'				_previousColBody = Null
'			End
'			_isColliding = False
'		End
		
		'Modifiers
		If qres.body
			If _jumping
				If Not _onground
					'Character hits head while jumping, instantly loses all vertical momentum.
					If qres.normal.Y < -0.1 And _grav > 0
						_grav = 0.0
					End
				End
			Else
				If allowGravity
					If _onground
						'Prevent sliding down slopes below threshold
						If _yResult.normal.Y >= _slopeY
'							Echo.Add( yResult.normal.X, Color.Cyan )
'							If ( horizontal > 0 And qres.normal.X < 0 ) Or ( horizontal < 0 And qres.normal.X > 0 )
								'Attempt to help "lock" character to slope. Not working yet...
'								Echo.Add( "!!!!!!!!!!", Color.Cyan)
'							Else
								_step2 = _step1
								Entity.Position = _step1
'							End
						End
					End
				End
			End
		End
		
'		Echo.Add( "jumping:" + _jumping, Color.Red )
'		Echo.Add( "onGround:" + _onground, Color.Pink )

		_previousRes = qres
		_onground=_yResult.onground
		_onwall=_xResult.onwall
		
		If _onground Then _jumping = False
		
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
			End
			If Entity.LocalZ > movementLimit.max.Z
				Entity.LocalZ = movementLimit.max.Z
			End
			If Entity.LocalZ < movementLimit.min.Z
				Entity.LocalZ = movementLimit.min.Z
			End
		End
	End
	
	
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
	
	
'	Method OnCopy:CharacterController( e:Entity ) Override
'		Local c:=New CharacterController( e )
'		c.CopyState( GetSavedState() )
'		Return c
'	End
	
	Protected
	
	Method LimitedMove( axis:Axis, amount:Float, delta:Float )
		If axis = Axis.X And Not lockXMovement Then Entity.MoveX( amount * delta, Not useLocalTransforms )
		If axis = Axis.Y And Not lockYMovement Then Entity.MoveY( amount * delta, Not useLocalTransforms )
		If axis = Axis.Z And Not lockZMovement Then Entity.MoveZ( amount * delta, Not useLocalTransforms )
	End
	
	Method LimitedMove( goal:Vec3f )
		If Not goal Return
		If Not lockXMovement Then Entity.X = goal.X
		If Not lockYMovement Then Entity.Y = goal.Y
		If Not lockZMovement Then Entity.Z = goal.Z
	End
	
	'********************************* QCollide *********************************
	
	Internal
	
	'Modified Mark Sibly's QCollide
	Method QCollide:QResult( src:Vec3f,dst:Vec3f  )
	
		If Not _col Return Null
		
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

			Local cresult:=world.ConvexSweep( _col, src, dst, collidesWith )
			If Not cresult Exit
			
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
	Field body:RigidBody
End

