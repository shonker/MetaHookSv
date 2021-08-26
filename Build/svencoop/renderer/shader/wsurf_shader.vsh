#version 430

#extension GL_EXT_texture_array : require
#extension GL_ARB_shader_draw_parameters : require

#include "common.h"

uniform float u_parallaxScale;

layout(location = 0) in vec3 in_vertex;
layout(location = 1) in vec3 in_normal;
layout(location = 2) in vec3 in_tangent;
layout(location = 3) in vec3 in_bitangent;
layout(location = 4) in vec3 in_diffusetexcoord;
layout(location = 5) in vec3 in_lightmaptexcoord;
layout(location = 6) in vec2 in_detailtexcoord;
layout(location = 7) in vec2 in_normaltexcoord;
layout(location = 8) in vec2 in_parallaxtexcoord;
layout(location = 9) in vec2 in_speculartexcoord;
#ifdef DECAL_ENABLED
layout(location = 10) in int in_decalindex;
#endif

out vec3 v_worldpos;
out vec3 v_normal;
out vec3 v_tangent;
out vec3 v_bitangent;
out vec2 v_diffusetexcoord;
out vec3 v_lightmaptexcoord;
out vec2 v_detailtexcoord;
out vec2 v_normaltexcoord;
out vec2 v_parallaxtexcoord;
out vec2 v_speculartexcoord;
out vec4 v_shadowcoord[3];
flat out int v_drawid;

#ifdef DECAL_ENABLED
flat out int v_decalindex;
#endif

void main(void)
{
#ifdef LEGACY_ENABLED

	vec4 worldpos4 = vec4(in_vertex, 1.0);
    v_worldpos = worldpos4.xyz;

	vec4 normal4 = vec4(in_normal, 0.0);
	v_normal = normalize((normal4).xyz);

	#ifdef DIFFUSE_ENABLED
		v_diffusetexcoord = vec2(in_diffusetexcoord.x, in_diffusetexcoord.y);
	#endif

#else

	vec4 worldpos4 = EntityUBO.entityMatrix * vec4(in_vertex, 1.0);
    v_worldpos = worldpos4.xyz;

	vec4 normal4 = vec4(in_normal, 0.0);
	v_normal = normalize((EntityUBO.entityMatrix * normal4).xyz);

	#ifdef DIFFUSE_ENABLED
		v_diffusetexcoord = vec2(in_diffusetexcoord.x + in_diffusetexcoord.z * EntityUBO.scrollSpeed, in_diffusetexcoord.y);
	#endif

#endif

#ifdef LIGHTMAP_ENABLED
	v_lightmaptexcoord = in_lightmaptexcoord;
#endif

#ifdef DETAILTEXTURE_ENABLED
	v_detailtexcoord = in_detailtexcoord;
#endif

#if defined(NORMALTEXTURE_ENABLED) || defined(PARALLAXTEXTURE_ENABLED)
    vec4 tangent4 = vec4(in_tangent, 0.0);
    v_tangent = normalize((EntityUBO.entityMatrix * tangent4).xyz);
	vec4 bitangent4 = vec4(in_bitangent, 0.0);
    v_bitangent = normalize((EntityUBO.entityMatrix * bitangent4).xyz);
#endif

#ifdef NORMALTEXTURE_ENABLED
	v_normaltexcoord = in_normaltexcoord;
#endif

#ifdef PARALLAXTEXTURE_ENABLED
	v_parallaxtexcoord = in_parallaxtexcoord;
#endif

#ifdef SPECULARTEXTURE_ENABLED
	v_speculartexcoord = in_speculartexcoord;
#endif

#ifdef SHADOWMAP_ENABLED

	#ifdef SHADOWMAP_HIGH_ENABLED
        v_shadowcoord[0] = SceneUBO.shadowMatrix[0] * vec4(v_worldpos, 1.0);
    #endif

    #ifdef SHADOWMAP_MEDIUM_ENABLED
        v_shadowcoord[1] = SceneUBO.shadowMatrix[1] * vec4(v_worldpos, 1.0);
    #endif

    #ifdef SHADOWMAP_LOW_ENABLED
        v_shadowcoord[2] = SceneUBO.shadowMatrix[2] * vec4(v_worldpos, 1.0);
    #endif

#endif

#ifdef DECAL_ENABLED
	v_decalindex = in_decalindex;
#endif

	v_drawid = gl_DrawIDARB;
	gl_Position = SceneUBO.projMatrix * SceneUBO.viewMatrix * worldpos4;
}