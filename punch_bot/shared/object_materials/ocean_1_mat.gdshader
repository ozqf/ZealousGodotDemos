shader_type spatial;

varying float vertexWeight;

void vertex() {
	float sinFunc1 = sin(TIME * 5.0 + VERTEX.x * 10.0);
	float sinFunc2 = sin(TIME * 5.0 + VERTEX.z * 10.0);
	vertexWeight = (sinFunc1 + sinFunc2) * 0.5;
	vertexWeight = (vertexWeight + 1.0) * 0.5;
	VERTEX.y += (vertexWeight * 8.0);
}

void fragment() {
	float weight = vertexWeight;
	vec3 baseColour = vec3(1.0, 1.0, 0.0);
	vec3 tipColour = vec3(1.0, 0.3, 0.0);
	
	ALBEDO = mix(baseColour, tipColour, weight);
	//ALBEDO = vec3(clamp(weight, 0, 1), clamp(weight, 0, 1) * 0.25, 0.0);
	ROUGHNESS = 0.5;
	RIM = 1.0;
}
