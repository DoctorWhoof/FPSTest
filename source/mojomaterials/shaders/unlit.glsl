//@renderpasses 0,1,2
//@import "std"

//@vertex
void main(){
	transformVertex();
}

//@fragment
#if MX2_COLORPASS

	uniform vec4 m_ColorFactor;
	uniform float m_AlphaDiscard;
	#if MX2_TEXTURED
	uniform sampler2D m_ColorTexture;
	#endif
	
	void main(){
	
	#if MX2_TEXTURED
		vec4 color=texture2D( m_ColorTexture,v_TexCoord0 );
		color.rgb=pow( color.rgb,vec3( 2.2 ) );
		color*=m_ColorFactor * v_Color;
	#else
		vec4 color=m_ColorFactor * v_Color;
	#endif
	
	if( color.a<m_AlphaDiscard ) discard;
	
	#if MX2_FORWARDRENDERER || MX2_FORWARDPASS
		emitColorFragment(color);
	#else
		gl_FragColor = color;
	#endif
	}

#else	//if not a color pass, must be a shadow pass...

	void main(){
		gl_FragColor= vec4(1,1,1,1);
	}

#endif
