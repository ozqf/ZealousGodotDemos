@tool
extends Node3D

@onready var _prefabSkyscraper1:PackedScene = preload("res://test_07_walled_city/prefabs/skyscraper_1.tscn")

@export_tool_button("Build", "Callable") var buildButton = build_from_editor

@export var texture:Texture2D
@export var blockSize:Vector3 = Vector3(84, 600, 84)

@export var width:int = 500
@export var height:int = 500

func build_from_editor() -> void:
	build()

func build() -> void:
	if texture == null:
		print("No texture to build from!")
		return
	
	if blockSize.x <= 0.0 || blockSize.y <= 0.0 || blockSize.z <= 0.0:
		print("Must have positive block size on all axes")
		return
	var texW:int = texture.get_width()
	var texH:int = texture.get_height()
	print("Building from tex size " + str(texW) + ", " + str(texH))
	
	for child in get_children():
		child.queue_free()
	
	# offset to place this node at centre
	var offsetX:float = (texW * blockSize.x) * 0.5
	var offsetZ:float = (texH * blockSize.z) * 0.5
	
	for x in range(0, texW):
		for z in range(0, texH):
			var c:Color = texture.get_image().get_pixel(x, z)
			if c.r > 0:
				var normalisedX:float = float(x) / float(texW)
				var normalisedZ:float = float(z) / float(texH)
				var newX:float = normalisedX * width
				var newY:float = -((1.0 - c.r) * blockSize.y)
				var newZ:float = normalisedZ * height
				
				
				newX = x * blockSize.x - offsetX
				newZ = z * blockSize.z - offsetZ
				
				#print("Placing at " + str(newX) + ", " + str(newZ))
				var building:Node3D = _prefabSkyscraper1.instantiate() as Node3D
				add_child(building)
				building.owner = get_tree().edited_scene_root
				building.position = Vector3(newX, newY, newZ)
	print("City build complete")
