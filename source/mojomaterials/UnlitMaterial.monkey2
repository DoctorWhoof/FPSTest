
Namespace mojo3d

#Import "<mojo3d>"
#Import "<std>"
#Import "shaders/unlit.glsl@/shaders/"

Using mojo3d..
Using std..

Class UnlitMaterial Extends Material
	
	Method New()
		Init()
		AddInstance()
	End
	
	Method New( color:Color )
		Init()
		ColorFactor=color
		AddInstance( New Variant[]( color ) )
	End
	
	Method New( material:UnlitMaterial )
		Super.New( material )
		AddInstance( material )
	End

	Method Copy:UnlitMaterial() Override
		Return New UnlitMaterial( Self )
	End
	
	'***** textures *****
	
'	[jsonify=1]
	Property Boned:Bool()
		Return (AttribMask & 192)=192
	Setter( boned:Bool )
		If boned AttribMask|=192 Else AttribMask&=~192
	End
	
'	[jsonify=1]
	Property ColorTexture:Texture()
		Return Uniforms.GetTexture( "ColorTexture" )
	Setter( texture:Texture )
		Uniforms.SetTexture( "ColorTexture",texture )
		UpdateAttribMask()
	End
	
	'***** factors *****
'	[jsonify=1]
	Property ColorFactor:Color()
		Return Uniforms.GetColor( "ColorFactor" )
	Setter( color:Color )
		Uniforms.SetColor( "ColorFactor",color )
	End
	
'	[jsonify=1]
	Property AlphaDiscard:Float()
		Return Uniforms.GetFloat( "AlphaDiscard" )
	Setter( value:Float )
		Uniforms.SetFloat( "AlphaDiscard",value )
	End
	
	Private
	
	Field _boned:Bool
	
	Method Init()
		Uniforms.DefaultTexture=Texture.ColorTexture( Color.White )
		ShaderName="unlit"
		AttribMask=1|4
		ColorTexture=Null
		ColorFactor=Color.White
		AlphaDiscard = 0.1
	End
	
	Method UpdateAttribMask()
		If Uniforms.NumTextures<>0 AttribMask|=24 Else AttribMask&=~24
	End
	
End


