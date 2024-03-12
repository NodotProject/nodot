shader_type spatial;

uniform float timeScaleFactor = 0.04;
uniform vec3 color: source_color = vec3(1.0, 0.0, 0.0);
uniform sampler2D underlay_texture: repeat_enable, filter_linear;
uniform sampler2D emission_texture: repeat_enable, filter_linear;
uniform sampler2D normal_texture: repeat_enable, filter_linear;
uniform sampler2D noise_texture: repeat_enable, filter_linear;

float localTime() {
    return TIME * timeScaleFactor;
}

mat2 makem2(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat2(vec2(c, -s), vec2(s, c));
}

float noise(vec2 x) {
    return texture(noise_texture, x * 0.01).r; // Assuming the noise is in the red channel
}

vec2 gradn(vec2 p) {
    float ep = 0.09;
    float gradx = noise(vec2(p.x + ep, p.y)) - noise(vec2(p.x - ep, p.y));
    float grady = noise(vec2(p.x, p.y + ep)) - noise(vec2(p.x, p.y - ep));
    return vec2(gradx, grady);
}

float flow(vec2 p) {
    float z = 2.0;
    float rz = 0.0;
    vec2 bp = p;
    
    for (float i = 1.0; i < 7.0; ++i) {
        vec2 offset = vec2(sin(localTime() * 0.6), cos(localTime() * 1.9)) * 0.1; // Oscillating offset
        vec2 gr = gradn(i * (p + offset) * 0.34);
        gr *= makem2(sin(localTime() * 6.0) * PI);
        p += gr * 0.5;
        rz += (sin(noise(p) * 7.0) * 0.5 + 0.5) / z;
        z *= 1.4;
        p *= 2.0;
        bp *= 1.9;
    }
    return rz;
}

void fragment() {
	
    float rz = flow(UV);
    vec3 shader_col = color / rz; // Red color from the shader effect
    shader_col = pow(shader_col, vec3(1.4));
	
	vec3 texture_col = texture(underlay_texture, UV).rgb; // Color from the additional texture
	vec3 final_col = mix(shader_col, texture_col, 0.0);
	vec2 uv = vec2(UV.x, UV.y + localTime() / 10.0);

    ALBEDO = texture(emission_texture, uv).rgb;
	NORMAL_MAP = texture(normal_texture, uv).rgb;
	EMISSION = final_col;
}