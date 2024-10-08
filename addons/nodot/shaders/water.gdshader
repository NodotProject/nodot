shader_type spatial;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap, repeat_disable;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

uniform float uv_scale = 1.0;
uniform float normal_scale = 1.0;
uniform float roughness_scale = 1.0;
uniform float metallic_scale = 1.0;
uniform float time_scale = 1.0;
uniform float distortion_smoothing : hint_range(100.0, 1000.0) = 1.0;
uniform vec3 water_color : source_color;
uniform sampler2D wave : hint_normal;
uniform float depth_distance : hint_range(0.0, 10.0, 0.1) = 0.5;

uniform float noise_scale = 10.0;
uniform float height_scale = 0.15;
uniform float wave_speed = 0.0;
uniform float wave_time = 0.0;

uniform sampler2D foam_texture;
uniform float foam_intensity : hint_range(0.0, 1.0) = 0.5;
uniform float foam_scale : hint_range(0.0, 10.0) = 1.0;
uniform float foam_blend : hint_range(0.0, 1.0) = 0.5;
uniform float foam_edge_fade : hint_range(0.0, 1.0) = 0.5;

void vertex() {
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX.xy, 1.0, 1.0)).xyz;
	float height = texture(wave, world_pos.xz / noise_scale + wave_time * wave_speed * time_scale).r;
	VERTEX.y += height * height_scale;
}

void fragment() {
    vec2 _uv = UV * 100.0 * uv_scale;

    _uv.x += sin(TIME * time_scale + (_uv.x + _uv.y) * 25.0) / distortion_smoothing;
    _uv.y += cos(TIME * time_scale + (_uv.x - _uv.y) * 25.0) / distortion_smoothing;

    float depth_r = textureLod(DEPTH_TEXTURE, SCREEN_UV, 0.0).r;
    vec4 world = INV_PROJECTION_MATRIX * vec4(SCREEN_UV, depth_r, 1.0);
    world.xyz /= world.w;
    float depth_blend = smoothstep(world.z + depth_distance, world.z, VERTEX.z);
    vec3 screen = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;

    // Foam calculation with edge fading
    float foam_depth = 1.0 - depth_blend;
    vec2 foam_uv = _uv * foam_scale;
    foam_uv += vec2(sin(TIME), cos(TIME)) * 0.01;
    float foam_mask = texture(foam_texture, foam_uv).r * foam_intensity;

    // Calculate the edge fade based on depth
    float edge_fade = smoothstep(0.0, foam_edge_fade, foam_depth);

    foam_mask *= 1.0 - edge_fade; // Apply the edge fade to the foam
    foam_mask = smoothstep(0.2, 1.0, foam_mask); // Smoothing foam appearance

    // Mix foam with the final color
    vec3 final_color = mix(water_color, vec3(1.0), foam_mask * foam_blend);

    ALBEDO = final_color * depth_blend;
    NORMAL_MAP = texture(wave, _uv).rgb;
    NORMAL *= normal_scale;
    ROUGHNESS *= roughness_scale;
	METALLIC *= metallic_scale;
}
