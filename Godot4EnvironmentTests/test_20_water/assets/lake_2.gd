extends MeshInstance3D

func _process(_delta:float) -> void:
	var backBuffer:BackBufferCopy = get_parent() as BackBufferCopy
	if !backBuffer:
		print("No backbuffer parent")
		return
	var capturedScreen:ViewportTexture = backBuffer.get_viewport().get_texture()
	var mat:ShaderMaterial = self.get_surface_override_material(0) as ShaderMaterial
	if mat == null:
		print("mat is not a shader mat")
		return
	mat.set_shader_parameter("water_backbuffer", capturedScreen)
