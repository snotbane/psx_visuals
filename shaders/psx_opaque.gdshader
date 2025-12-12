shader_type spatial;
render_mode blend_mix, vertex_lighting, diffuse_lambert, specular_occlusion_disabled, specular_disabled, shadows_disabled, fog_disabled;

#include "uid://bbm41nyy2th3f"

global uniform float psx_affine_strength;
global uniform vec4 psx_fog_color;
global uniform float psx_fog_far;
global uniform float psx_fog_near;
global uniform float psx_snap_distance;

// If enabled, we will Gouraud shading and multiply vertex colors to albedo.
uniform bool use_vertex_colors_in_albedo = true;

// If enabled, use global PSX fog. Otherwise, fog will not appear on these surfaces, as if there is a hole in the fog.
uniform bool use_global_fog = true;

uniform sampler2D albedo: hint_default_white, filter_nearest;
uniform vec4 albedo_tint: source_color = vec4(1);

uniform sampler2D emission: hint_default_black, filter_nearest;
uniform vec3 emission_tint: source_color = vec3(1);

uniform float alpha_scissor_threshold: hint_range(0.0, 1.0, 0.01) = 0.5;

varying vec3 VERTEX_COLOR;
varying float VERTEX_DEPTH;

varying float fog_strength;
varying vec2 affine_uv_scaled;

void vertex() {
    VERTEX_COLOR = COLOR.rgb;

	VERTEX = snap(VERTEX, MODELVIEW_MATRIX, psx_snap_distance);
	vec3 vertex_world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	VERTEX_DEPTH = distance(vertex_world, CAMERA_POSITION_WORLD);
	affine_uv_scaled = UV * VERTEX_DEPTH;
	fog_strength = (use_global_fog && psx_fog_near != psx_fog_far) ?
		clamp(psx_fog_color.a * (VERTEX_DEPTH - psx_fog_near) / (psx_fog_far - psx_fog_near), 0.0, 1.0) :
		0.0;
}

void fragment() {
	vec2 affine_uv = affine_uv_scaled / VERTEX_DEPTH;
	vec2 uv = mix(UV, affine_uv, psx_affine_strength);

	vec3 fog_rgb = mix(vec3(0), psx_fog_color.rgb, fog_strength);

	vec4 albedo_color = texture(albedo, uv) * albedo_tint;
	if (use_vertex_colors_in_albedo) albedo_color *= vec4(VERTEX_COLOR, 1.0);
	ALBEDO = albedo_color.rgb * (1.0 - fog_strength) + fog_rgb;

	ALPHA = albedo_color.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;

	vec4 emission_color = texture(emission, uv) * vec4(emission_tint, 1.0);
	EMISSION = emission_color.rgb + fog_rgb;

	SPECULAR = 0.0;
	ROUGHNESS = 0.0;
	METALLIC = 0.0;
	AO = 1.0;
}
