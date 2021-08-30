extends MeshInstance

export var material:SpatialMaterial = null

func _ready():
	if material == null:
		material = SpatialMaterial.new()
	_block_fill_tex()

func _block_fill_tex() -> void:
	var tex:ImageTexture = ImageTexture.new()
	var img:Image = Image.new()
	img.create(50, 50, false, Image.FORMAT_RGBAF)
	img.fill(Color(0, 0, 1, 1))
	img.lock()
	img.set_pixel(0, 0, Color(1, 0, 0, 1))
	# img.set_pixel(0, 25, Color.red)
	img.unlock()
	tex.create_from_image(img)
	material.set_texture(SpatialMaterial.TEXTURE_ALBEDO, tex)
	self.material_override = material
