
//@renderpasses 1,7,11,15,2,6,10,14,22,26,30

//@import "pbr"

//@vertex

void main(){
 	transformVertex();
}

//@fragment
#if MX2_COLORPASS	//is this a color pass?

#if MX2_TEXTURED
uniform sampler2D m_GlobalColorTexture;
uniform sampler2D m_GlobalNormalTexture;
uniform sampler2D m_GlobalCombinedTexture;

uniform sampler2D m_AmbientTexture;
uniform sampler2D m_MaskTexture;

uniform sampler2D m_ColorTextureA;
uniform sampler2D m_RoughnessTextureA;
uniform sampler2D m_OcclusionTextureA;

uniform sampler2D m_ColorTextureB;
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
uniform float m_NormalFactorNear;
uniform float m_NormalFactorFar;

uniform vec4 m_ColorFactor;
uniform vec4 m_AmbientFactor;
uniform vec4 m_EmissiveFactor;
uniform float m_MetalnessFactor;
uniform float m_RoughnessFactor;

void main(){


#if MX2_TEXTURED
	float maskblend = texture2D( m_MaskTexture,v_TexCoord0 ).r;
	float distblend = clamp( v_Position.z, m_Near, m_Far );
	distblend =( distblend - m_Near ) / ( m_Far - m_Near );
	
	vec4 vMaskBlend = vec4( maskblend, maskblend, maskblend, 1.0);
	vec4 vDistBlend = vec4( distblend, distblend, distblend, 1.0);
	
	vec2 uvNear = v_TexCoord0 / m_UvScaleNear;

	vec4 colorA=mix( texture2D( m_ColorTextureA,uvNear ), texture2D( m_ColorTextureB,uvNear ), maskblend ) ;
	vec4 colorB=texture2D( m_GlobalColorTexture, v_TexCoord0 );
	vec4 color=mix( colorA, colorB, distblend );
	color.rgb=pow( color.rgb, vec3(2.2) );
	color*=m_ColorFactor;
	
	float roughA = mix( texture2D( m_RoughnessTextureA,uvNear ).g, texture2D( m_RoughnessTextureB,uvNear ).g, maskblend );
	float roughB = texture2D( m_GlobalCombinedTexture,v_TexCoord0 ).g;
	float roughness=mix( roughA, roughB, distblend ) * m_RoughnessFactor;

	float occNearA=texture2D( m_OcclusionTextureA,uvNear ).r;
	float occNearB=texture2D( m_OcclusionTextureB,uvNear ).r;
	float occA = mix( occNearA, occNearB, maskblend );
	float occB = texture2D( m_GlobalCombinedTexture,v_TexCoord0 ).r;
	float occlusion=mix( occA, occB, distblend );
	
	vec3 ambient=pow( texture2D( m_AmbientTexture,v_TexCoord0 ).rgb,vec3( 2.2 ) ) * m_AmbientFactor.rgb;
	
#if MX2_BUMPMAPPED
	vec3 normNearA = texture2D( m_NormalTextureA,uvNear ).xyz * 2.0 - 1.0;
	vec3 normNearB = texture2D( m_NormalTextureB,uvNear ).xyz * 2.0 - 1.0;
	vec3 normA = mix( normNearA, normNearB, vMaskBlend.rgb );
	vec3 normB = texture2D( m_GlobalNormalTexture,v_TexCoord0 ).xyz * 2.0 - 1.0;
	vec3 normal = mix( normA, normB, vDistBlend.rgb );
	
	//vec3 normal=texture2D( m_GlobalNormalTexture,v_TexCoord0 ).xyz * 2.0 - 1.0;
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
	emitPbrFragment( color,ambient,m_EmissiveFactor.rgb,0.0,roughness,occlusion,normal );
}

#else	//if not a color pass, must be a shadow pass...

void main(){
	emitShadowFragment();
}

#endif
