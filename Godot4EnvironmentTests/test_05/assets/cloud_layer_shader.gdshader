shader_type spatial;

//render_mode blend_add;

uniform sampler2D albedo : source_color,filter_nearest_mipmap,repeat_enable;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 colour = texture(albedo, vec2(UV.x, UV.y));
	 ALBEDO = colour.xyz;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
