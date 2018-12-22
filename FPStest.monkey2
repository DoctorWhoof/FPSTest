Namespace fpsdemo

#Import "assets/"
#Import "<mojo3d>"

#Import "source/CharacterController"
#Import "source/extensions/Entity"
#Import "source/extensions/Model"
#Import "source/extensions/Math"

Using mojo3d..
Using mojo..
Using std..
Using m2extensions..

Function Main()
	SetConfig( "MOJO3D_RENDERER","forward" )
	New AppInstance
	New FPSWindow( 1280, 720 )
	App.Run()
End

Class FPSWindow Extends Window

	Field _scene:Scene
	Field _camera:Camera

	Method New( width:Int, height:Int )
		Super.New( "FPS Demo", width, height, WindowFlags.Resizable )
	End
	
	Method OnCreateWindow() Override
		_scene = New Scene
		_scene.ClearColor = New Color( 0.3, 0.5, 0.9 )
		_scene.EnvTexture = Texture.Load("asset::white_cliff_top_4k.jpg", TextureFlags.FilterMipmap | TextureFlags.Cubemap )
		_scene.SkyTexture = _scene.EnvTexture
		_scene.AmbientLight = New Color( 0.2, 0.3, 0.4 )
	
		Local light := New Light
		light.Rotate(15,-50,0)
		light.Color = New Color( 1.25, 1.1, 1.0 )
		light.CastsShadow = True
		
		'eyecandy
		Local rays := New GodraysEffect( light )
		rays.Exposure = 0.0005
		rays.Decay = 10.0
		rays.Color = New Color( 1.0, 0.8, 0.5 )
		
		_scene.AddPostEffect( rays )
		_scene.AddPostEffect( New FXAAEffect )
		
		
		Local env := Model.Load( "asset::test_env1.gltf")
		For Local e := Eachin _scene.GetRootEntities()
			Local m := Cast<Model>( e )
			If m
				m.CreateCollisionMesh( 1 )
			End
		Next
		
		Local hero := New Pivot
		hero.Name = "Hero"
		hero.X = 0
		hero.Y = 3
		hero.Z = 0

		_camera = New Camera
		_camera.Parent = hero
		_camera.FOV = 60
		_camera.Near = 0.1
		_camera.Far = 100
		_camera.View = Self
		
		Local col := hero.AddComponent<CapsuleCollider>()
		col.Axis = Axis.Y
		col.Length = 1.5
		col.Radius = 0.25
		
		Local controller := hero.AddComponent<CharacterController>()
		controller.allowGravity = True
		controller.allowJump = True
		controller.horizontalAxis = Axis.X
		controller.verticalAxis = Axis.Z
		controller.collidesWith = 1
		
		controller.useLocalTransforms = True
		controller.firstPerson = True
		controller.firstPersonCamera = _camera
		
		controller.speed = 0.1
		controller.jumpSpeed = .1
		_scene.World.Gravity = New Vec3f( 0, -0.35, 0 )
	End
	
	Method OnRender( canvas:Canvas ) Override
		RequestRender()
		_scene.Update()
		_camera.Render( canvas )
		canvas.Color = Color.Black
		canvas.DrawText( "Click to capture mouse, escape to release it. WASD keys to walk, space bar to jump",0,0 )
		canvas.DrawText( "FPS="+App.FPS,0,20 )
	End
	
End