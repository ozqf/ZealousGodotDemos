shader_type spatial;

varying float vertexWeight;

void vertex() {
	float sinFunc1 = sin(TIME * 5.0 + VERTEX.x * 10.0);
	float sinFunc2 = sin(TIME * 5.0 + VERTEX.z * 10.0);
	vertexWeight = (sinFunc1 + sinFunc2) * 0.5;
	vertexWeight = (vertexWeight + 1.0) * 0.5;
	VERTEX.y += vertexWeight;
}

void fragment() {
	float weight = vertexWeight;
	ALBEDO = vec3(clamp(weight, 0, 1), clamp(weight, 0, 1) * 0.25, 0.0);
	//ROUGHNESS = 1.0;
	//RIM = 0.1;
}
