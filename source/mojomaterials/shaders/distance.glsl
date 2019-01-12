
//@renderpasses 1,7,11,15,2,6,10,14,22,26,30

//@import "pbr"

//@vertex

void main(){
 	transformVertex();
}

//@fragment
#if MX2_COLORPASS	//is this a color pass?

#if MX2_TEXTURED
uniform sampler2D m_AmbientTexture;
uniform sampler2D m_MaskTexture;

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

uniform float m_Near;
uniform float m_Far;
uniform float m_UvScaleNear;
uniform float m_UvScaleFar;
uniform float m_NormalFactorNear;
uniform float m_NormalFactorFar;

uniform vec4 m_ColorFactor;
uniform vec4 m_AmbientFactor;
uniform vec4 m_EmissiveFactor;
uniform float m_MetalnessFactor;
uniform float m_RoughnessFactor;

void main(){


#if MX2_TEXTURED
	float blend = clamp( v_Position.z, m_Near, m_Far );
	blend =( blend - m_Near ) / ( m_Far - m_Near );
	
	vec4 vBlend = vec4( blend, blend, blend, 1.0);
	
	vec2 uvNear = v_TexCoord0 / m_UvScaleNear;
	vec2 uvFar = v_TexCoord0 / m_UvScaleFar;

	vec4 colorA=texture2D( m_ColorTextureA,uvNear );
	vec4 colorB=texture2D( m_ColorTextureB,uvFar );
	vec4 color=mix( colorA, colorB, vBlend ) ;
	color.rgb=pow( color.rgb, vec3(2.2) );
	color*=m_ColorFactor;
	
	vec3 ambient=pow( texture2D( m_AmbientTexture,uvNear ).rgb,vec3( 2.2 ) ) * m_AmbientFactor.rgb;

	vec3 emissA=texture2D( m_EmissiveTextureA,uvNear ).rgb;
	vec3 emissB=texture2D( m_EmissiveTextureB,uvFar ).rgb;
	vec3 emissive=mix( emissA, emissB, vBlend.rgb ) * m_EmissiveFactor.rgb;
	emissive=pow( emissive, vec3(2.2) );
	//vec3 emissive=pow( texture2D( m_EmissiveTextureA,uvNear ).rgb,vec3( 2.2 ) ) * m_EmissiveFactor.rgb;

	float metalA=texture2D( m_MetalnessTextureA,uvNear ).b;
	float metalB=texture2D( m_MetalnessTextureB,uvFar ).b;
	float metalness=mix( metalA, metalB, blend ) * m_MetalnessFactor;
	//float metalness=texture2D( m_MetalnessTextureA,uvNear ).b * m_MetalnessFactor;
	
	float roughA=texture2D( m_RoughnessTextureA,uvNear ).g;
	float roughB=texture2D( m_RoughnessTextureB,uvFar ).g;
	float roughness=mix( roughA, roughB, blend ) * m_RoughnessFactor;
	//float roughness=texture2D( m_RoughnessTextureA,uvNear ).g * m_RoughnessFactor;
	
	float occA=texture2D( m_OcclusionTextureA,uvNear ).r;
	float occB=texture2D( m_OcclusionTextureB,uvFar ).r;
	float occlusion=mix( occA, occB, blend );
	//float occlusion=texture2D( m_OcclusionTextureA,uvNear ).r;
	
#if MX2_BUMPMAPPED
	
	vec3 normA = ( texture2D( m_NormalTextureA,uvNear ).xyz * m_NormalFactorNear ) * 2.0 - 1.0;
	vec3 normB = ( texture2D( m_NormalTextureB,uvFar ).xyz * m_NormalFactorFar ) * 2.0 - 1.0;
	vec3 normal = mix( normA, normB, vBlend.rgb );
	normal=normalize( v_TanMatrix * normal );
	//vec3 normal=texture2D( m_NormalTexture,v_TexCoord0 ).xyz * 2.0 - 1.0;
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
