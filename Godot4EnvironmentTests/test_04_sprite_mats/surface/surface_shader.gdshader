shader_type spatial;

uniform sampler2D albedo : source_color,filter_nearest_mipmap,repeat_enable;

void vertex() {
	VERTEX.y += cos(VERTEX.x) * sin(VERTEX.z);
}

void fragment() {
	// Called for every pixel the material is visible on.
	float scale = 10.0;
	vec4 colour = texture(albedo, vec2(UV.x * scale, UV.y * scale));
	ALBEDO = colour.xyz;
	SPECULAR = 0.0;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
