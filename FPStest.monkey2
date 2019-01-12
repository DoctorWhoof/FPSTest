Namespace fpsdemo

#Import "assets/"
#Import "<mojo3d>"

#Import "source/CharacterController"
#Import "source/Group"

#Import "source/echo/Echo"
#Import "source/clock/Clock"
#Import "source/mojomaterials/TerrainMaterial"

#Import "source/m2extensions/Entity"
#Import "source/m2extensions/Collider"
#Import "source/m2extensions/Model"
#Import "source/m2extensions/math/Math"
#Import "source/Player"
#Import "source/PlayerHuman"

Using mojo3d..
Using mojo..
Using std..
Using m2extensions..
Using echo..
Using clock..
Using mojogame..
Using group..

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
		Super.New( "FPS Demo", width, height, WindowFlags.Resizable )' | WindowFlags.HighDPI )
	End
	
	Method OnCreateWindow() Override
		_scene = New Scene
		_scene.ClearColor = New Color( 0.3, 0.5, 0.9 )
		_scene.EnvTexture = Texture.Load("asset::textures/white_cliff_top_4k.jpg", TextureFlags.FilterMipmap|TextureFlags.Cubemap|TextureFlags.Envmap )
		_scene.SkyTexture = _scene.EnvTexture
'		_scene.EnvColor = Color.DarkGrey
		_scene.AmbientLight = New Color( 0.25, 0.3, 0.4 )*1.2' * 0.75
		_scene.FogFar = 5000
		_scene.FogNear = 1
		_scene.FogColor = New Color( 0.7, 0.8, 0.9, 0.5 )
		
		Echo.showChildren = True
		Echo.scale = 0.66
'		SwapInterval = 0
		
		Local env := Model.LoadBoned( "asset::models/castle.gltf")
		Assert( env, "Model load fail")
		env.Name = "CastleValley"
		For Local e := Eachin _scene.GetRootEntities()
			Local m := Cast<Model>( e )
			m?.Init()
		Next
		Local terrain := env.GetChild<Model>("E_None_terrain")
		
		
		'sun light
		Local sun := New Light
		sun.Rotate(30,-45,0)
		sun.Color = New Color( 1.25, 1.1, 1.0 )
		sun.CastsShadow = True
		
		'bounce light
'		Local bounce := New Light
'		bounce.Rotate(-45,50,0)
'		bounce.Color = New Color( 0.2, 0.25, 0.25 )
'		bounce.CastsShadow = False
		
		'eyecandy
		Local rays := New GodraysEffect( sun )
		rays.Exposure = 0.0003
		rays.Decay = 10.0
		rays.Color = New Color( 1.0, 0.8, 0.5 )
		
		_scene.AddPostEffect( rays )
		_scene.AddPostEffect( New FXAAEffect )
		
		'hero entity. The camera is parented to it.
		Local hero := New Pivot
		hero.Name = "Hero"
		hero.X = 0
		hero.Y = 15
'		hero.Z = -5
		hero.Ry = 180

		Local head := New Pivot'Model.CreateSphere( 0.1, 16, 16, New PbrMaterial( Color.Yellow ) )
		head.Name = "Head"
		head.Parent = hero
		head.LocalY = .8

		_camera = New Camera
		_camera.Name = "Camera"
		_camera.Parent = head
		_camera.FOV = 60
		_camera.Near = 0.1
		_camera.Far = 1000
		_camera.View = Self
		_camera.LocalY = 0.0
'		_camera.LocalZ = -2.0
		
		Local player := hero.AddComponent<PlayerHuman>()
		player.SetControl( Key.W, "Up", "" )
		player.SetControl( Key.S, "Down", "" )
		player.SetControl( Key.A, "Left", "" )
		player.SetControl( Key.D, "Right", "" )
		player.SetControl( Key.Space, "Jump", "" )
		player.SetControl( Key.R, "Reset", "" )
		player.SetControl( Key.F, "Fly", "" )
		player.SetControl( Key.LeftShift, "Run", "" )
		
		Local col := hero.AddComponent<CapsuleCollider>()
		col.Axis = Axis.Y
		col.Length = 1.0
		col.Radius = 0.3
'		col.CreateDebugMesh()
		
		Local controller := hero.AddComponent<CharacterController>()
		controller.collidesWith = Group.Environment | Group.Prop
		controller.allowGravity = True
		controller.allowJump = True
		controller.horizontalAxis = Axis.X
		controller.verticalAxis = Axis.Z
		controller.firstPerson = True
		controller.fpsCamera = _camera
		controller.movementLimit = terrain.Mesh.Bounds
		
		'Units are meters per second. Gravity has been adjusted for arcade physics...
		controller.speed = 6.0
		controller.jumpSpeed = 6.0
		controller.slopeSlide = 45
		Print _scene.World.Gravity
		_scene.World.Gravity = New Vec3f( 0, -20.0, 0 )
		
		'Terrain	
		Local originalMatA := Cast<PbrMaterial>(terrain.Materials[0])
		Local originalMatB := Cast<PbrMaterial>(terrain.Materials[1])
		
		Local mask := Texture.Load( "asset::terrain/terrain_mask.png", TextureFlags.FilterMipmap )
		Local normal := Texture.Load( "asset::terrain/terrain_normal.jpg", TextureFlags.FilterMipmap )
		Local color := Texture.Load( "asset::terrain/terrain_color.jpg", TextureFlags.FilterMipmap )
		Local combined := Texture.Load( "asset::terrain_occRoughMetal.jpg", TextureFlags.FilterMipmap )
		Local terrainMatA := New TerrainMaterial( mask, color, combined, normal, originalMatA, originalMatB )
'		
		terrain.Materials[0] = terrainMatA
		terrain.Materials[1] = terrainMatA
		terrainMatA.UvScaleNear = 1.0/200.0
	End
	
	Method OnRender( canvas:Canvas ) Override
		RequestRender()
		Clock.Update()
		_scene.Update()
		_camera.Render( canvas )
		Echo.Add( "FPS: " + App.FPS )
		Echo.Add(_scene)
		Echo.Draw( canvas, 5, 25 )
		canvas.Color = Color.Black
		canvas.DrawText( "Click to capture mouse, escape to release it. WASD keys to walk, space bar to jump",0,0 )
	End
	
End