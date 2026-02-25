@tool
extends EditorScript

func _save_noise_texture(resourcePath:String, outputPath:String) -> void:
	print("Saving noise tex - " + str(resourcePath) + " to " + str(outputPath))
	var resource = load(resourcePath)
	if !resource.has_method("get_image"):
		print(str(resourcePath) + " is not an image!")
		return
	var img:Image = resource.get_image()
	img.clear_mipmaps()
	img.save_png(outputPath)
	pass

func _run() -> void:
	_save_noise_texture("res://shared/materials/world/components/tex_noise_concrete_01.tres", "c:/projects/misc/tex_noise_concrete_01.png")
	_save_noise_texture("res://shared/materials/world/components/tex_noise_concrete_01_128x.tres", "c:/projects/misc/tex_noise_concrete_01_128x.png")
	
	_save_noise_texture("res://shared/materials/world/components/tex_noise_concrete_grid.tres", "c:/projects/misc/tex_noise_concrete_grid.png")
	
	print("Run Noise Tex Extractor")
