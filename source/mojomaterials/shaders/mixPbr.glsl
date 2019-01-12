
//@renderpasses 1,7,11,15,2,6,10,14,22,26,30

//@import "pbr"

varying vec3 worldPosition;

//@vertex

void main(){
 	transformVertex();
	worldPosition.xyz = a_Position.xyz;	
}

//@fragment

#if MX2_COLORPASS	//is this a color pass?

#if MX2_TEXTURED
uniform sampler2D m_AmbientTexture;

uniform sampler2D m_ColorTextureA;
uniform sampler2D m_EmissiveTextureA;
uniform sampler2D m_MetalnessTextureA;
uniform sampler2D m_RoughnessTextureA;
uniform sampler2D m_OcclusionTextureA;

uniform sampler2D m_ColorTextureB;
uniform sampler2D m_EmissiveTextureB;
uniform sampler2D m_MetalnessTextureB;
uniform sampler2D m_RoughnessTextureB;
uniform sampler2D m_OcclusionTextureB;


#if MX2_BUMPMAPPED
uniform sampler2D m_NormalTextureA;
uniform sampler2D m_NormalTextureB;
#endif
#endif

uniform float m_Min;
uniform float m_Max;

uniform vec4 m_ColorFactor;
uniform vec4 m_AmbientFactor;
uniform vec4 m_EmissiveFactor;
uniform float m_MetalnessFactor;
uniform float m_RoughnessFactor;

void main(){


#if MX2_TEXTURED
	
	float blend = clamp( worldPosition.y, m_Min, m_Max );
	blend =( blend - m_Min ) / ( m_Max - m_Min );

	vec4 a = vec4( blend, blend, blend, 1.0);
	vec3 gamma = vec3(2.2);

	vec4 colorA=texture2D( m_ColorTextureA,v_TexCoord0 );
	vec4 colorB=texture2D( m_ColorTextureB,v_TexCoord0 );
	vec4 color=mix( colorA, colorB, a ) ;
	color.rgb=pow( color.rgb, gamma );
	color*=m_ColorFactor;
	
	vec3 emissiveA = texture2D( m_EmissiveTextureA,v_TexCoord0 );
	vec3 emissiveB = texture2D( m_EmissiveTextureB,v_TexCoord0 );
	vec3 emissive = mix( emissiveA, emissiveB, a )
	emissive.rgb = pow( emissive.rgb, gamma );
	emissive *= m_EmissiveFactor.rgb;

	float metalnessA = texture2D( m_MetalnessTextureA,v_TexCoord0 ).b;
	float metalnessB = texture2D( m_MetalnessTextureB,v_TexCoord0 ).b;
	float metalness = mix( metalnessA, metalnessB, blend ) * m_MetalnessFactor;

	float roughnessA = texture2D( m_RoughnessTextureA,v_TexCoord0 ).g;
	float roughnessB = texture2D( m_RoughnessTextureB,v_TexCoord0 ).g;
	float roughness = mix( roughnessA, roughnessB, blend ) * m_RoughnessFactor;

	float occlusionA = texture2D( m_OcclusionTextureA,v_TexCoord0 ).r;
	float occlusionB = texture2D( m_OcclusionTextureB,v_TexCoord0 ).r;
	float occlusion = mix( occlusionA, occlusionB, blend );

	vec3 ambient=pow( texture2D( m_AmbientTexture,v_TexCoord1 ).rgb,vec3( 2.2 ) ) * m_AmbientFactor.rgb;
	
#if MX2_BUMPMAPPED
	vec3 normal=texture2D( m_NormalTexture,v_TexCoord0 ).xyz * 2.0 - 1.0;
	normal=normalize( v_TanMatrix * normal );
#else
	vec3 normal=normalize( v_Normal );
#endif

#else	//untextured...
	vec4 color=m_ColorFactor;
	vec3 ambient=m_AmbientFactor.rgb;
	vec3 emissive=m_EmissiveFactor.rgb;
	float metalness=m_MetalnessFactor;
	float roughness=m_RoughnessFactor;
	float occlusion=1.0;
	vec3 normal=normalize( v_Normal );
#endif

	emitPbrFragment( color,ambient,emissive,metalness,roughness,occlusion,normal );
}

#else	//if not a color pass, must be a shadow pass...

void main(){
	emitShadowFragment();
}

#endif
