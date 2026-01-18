extends Node

@onready var _container:Control = $menu/VBoxContainer

var _links:Dictionary = {
	"test_1": {
		"label": "1 - Cottage",
		"path": "res://test_01_csg_cottage/test_01.tscn",
	},
	"test_2": {
		"label": "2 - Neon Cube",
		"path": "res://test_02_neon_cube/test_02.tscn",
	},
	"test_3": {
		"label": "3 - Spider Mech",
		"path": "res://test_03_spider_mech/test_03.tscn"
	},
	"test_4": {
		"label": "4 - sprite mats",
		"path": "res://test_04_sprite_mats/test_04.tscn"
	},
	"test_5": {
		"label": "5 - Offworld Drizzle",
		"path": "res://test_05_colony_drizzle/test_05.tscn"
	},
	"test_6": {
		"label": "6 - Thin Air",
		"path": "res://test_06_thin_air/test_06.tscn"
	},
	"test_7": {
		"label": "7 - Walled City",
		"path": "res://test_07_walled_city/test_07.tscn"
	},
	"test_8": {
		"label": "8 - Fog City",
		"path": "res://test_08_fog_city/test_08.tscn"
	},
	"test_9": {
		"label": "9 - Bullet patterns",
		"path": "res://test_09_bullets/test_09.tscn"
	},
	"test_10": {
		"label": "10 - Highway",
		"path": "res://test_10_highway/test_10.tscn"
	},
	"test_11": {
		"label": "11 - Giant tunnel Loop",
		"path": "res://test_11_loop/test_11.tscn"
	},
	"test_12": {
		"label": "12 - Score bar fill",
		"path": "res://test_12_scorescreen/test_12.tscn"
	},
	"test_13": {
		"label": "13 - Wireframe Flythrough City",
		"path": "res://test_13_wireframe_city/test_13.tscn"
	},
	"test_14": {
		"label": "14 - Flying chase",
		"path": "res://test_14_flythrough/test_14.tscn"
	},
	"test_15": {
		"label": "15 - Map Screen",
		"path": "res://test_15_map_screen/test_15.tscn"
	},
	"test_16": {
		"label": "16 - Snow Boarding",
		"path": "res://test_16_boarding/test_16.tscn"
	},
	"test_17": {
		"label": "17 - Highwire",
		"path": "res://test_17_highwire/test_17.tscn"
	},
	"test_18": {
		"label": "18 - Falling",
		"path": "res://test_18_falling/test_18.tscn"
	}
}

func _ready() -> void:
	for tag in _links.keys():
		var link:Dictionary = _links[tag]
		var button:CustomButton = CustomButton.Create()
		button.name = tag
		button.tag = tag
		button.text = link.label
		button.data = link.path
		button.connect("custom_pressed", _button_pressed)
		_container.add_child(button)

func _button_pressed(button:CustomButton) -> void:
	print("Change scene - " + str(button.data))
	get_tree().change_scene_to_file(button.data)
