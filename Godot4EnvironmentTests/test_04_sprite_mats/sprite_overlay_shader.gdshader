shader_type spatial;
render_mode blend_add,depth_test_disabled;

uniform sampler2D mask : filter_nearest_mipmap,repeat_enable;
uniform sampler2D noise : filter_nearest_mipmap,repeat_enable;

// triplanar
uniform float uv1_blend_sharpness;
varying vec3 uv1_triplanar_pos;
varying vec3 uv1_power_normal;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;

void vertex() {
	// billboard
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(vec4(normalize(cross(vec3(0.0, 1.0, 0.0), INV_VIEW_MATRIX[2].xyz)), 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))), 0.0), MODEL_MATRIX[3]);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);

	// triplanar texturing
		vec3 normal = NORMAL;
	TANGENT = vec3(0.0,0.0,-1.0) * abs(normal.x);
	TANGENT+= vec3(1.0,0.0,0.0) * abs(normal.y);
	TANGENT+= vec3(1.0,0.0,0.0) * abs(normal.z);
	TANGENT = normalize(TANGENT);
	BINORMAL = vec3(0.0,1.0,0.0) * abs(normal.x);
	BINORMAL+= vec3(0.0,0.0,-1.0) * abs(normal.y);
	BINORMAL+= vec3(0.0,1.0,0.0) * abs(normal.z);
	BINORMAL = normalize(BINORMAL);
	uv1_power_normal=pow(abs(NORMAL),vec3(uv1_blend_sharpness));
	uv1_triplanar_pos = VERTEX * uv1_scale + uv1_offset;
	uv1_power_normal/=dot(uv1_power_normal,vec3(1.0));
	uv1_triplanar_pos *= vec3(1.0,-1.0, 1.0);
}

vec4 triplanar_texture(sampler2D p_sampler,vec3 p_weights,vec3 p_triplanar_pos) {
	vec4 samp=vec4(0.0);
	samp+= texture(p_sampler,p_triplanar_pos.xy) * p_weights.z;
	samp+= texture(p_sampler,p_triplanar_pos.xz) * p_weights.y;
	samp+= texture(p_sampler,p_triplanar_pos.zy * vec2(-1.0,1.0)) * p_weights.x;
	return samp;
}

void fragment() {
	vec3 uv = uv1_triplanar_pos;
	uv.x = uv1_triplanar_pos.x;
	uv.y = uv1_triplanar_pos.y + (TIME * 0.5);

	vec4 albedo_tex = triplanar_texture(noise,uv1_power_normal,uv);
	float alpha = texture(mask, vec2(UV.x, UV.y)).a;
	//ALBEDO = vec3(alpha, alpha, alpha);

	if (alpha < 0.1)
		discard;
	//ALBEDO += vec3(0.5, 0.5, 0.5);
	//float weight = texture(noise, vec2(UV.x, UV.y)).b;
	float weight = albedo_tex.b;
	if (weight < 0.5)
		discard;
	ALBEDO += vec3(0.0, weight, weight);
	/*if (FRAGCOORD.x > 600.0)
	{
		ALBEDO += vec3(0.0, 1.0, 1.0);
	}
	else
	{
		ALBEDO += vec3(1.0, 0.0, 1.0);
	}*/
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
