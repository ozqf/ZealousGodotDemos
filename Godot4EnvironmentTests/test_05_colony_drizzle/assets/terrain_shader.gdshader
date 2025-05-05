shader_type spatial;

uniform float heightLimit = 1.0;
uniform sampler2D heightMap : source_color,filter_nearest_mipmap,repeat_enable;
uniform sampler2D albedo : source_color,filter_nearest_mipmap,repeat_enable;

void vertex() {
	vec4 heightPixel = texture(heightMap, vec2(UV.x, UV.y));
	VERTEX.y += heightPixel.r * heightLimit;
	VERTEX.y += cos(VERTEX.x * heightLimit) * sin(VERTEX.z * heightLimit);
}

void fragment() {
	vec4 colour = texture(albedo, vec2(UV.x, UV.y));
	ALBEDO = colour.xyz;
	SPECULAR = 0.0;
	//ROUGHNESS = (colour.x * 0.25) + 0.5;
	//IRRADIANCE = colour;

}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
