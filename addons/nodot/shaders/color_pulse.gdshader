shader_type spatial;

uniform float pulse_speed = 5.0;
uniform float strength = 0.04;
uniform vec3 color : source_color = vec3(1.0, 1.0, 1.0);

void fragment() {
	float pulse_amount = sin(TIME * pulse_speed) * strength + strength;
	ALBEDO = color;
	ALPHA = pulse_amount;
}
