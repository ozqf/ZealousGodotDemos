shader_type spatial;

void vertex() {
	VERTEX.y += cos(VERTEX.x) * sin(VERTEX.z);
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
