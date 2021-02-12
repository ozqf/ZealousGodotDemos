extends Spatial
class_name EntityEditor

const _prefab_spawn_t = preload("res://map_gen/prefabs/spawn_point.tscn")
const _mapSpawnDef_t = preload("./map_spawn_def.gd")

enum EntEditMode { Select, Add, Rotate, SetTargets }

onready var _entTypeLabel:Label = $ui/template_list/ent_type_label

# updated from controller
var _gridX:int = 0
var _gridY:int = 0
var _isActive:bool = false
var _mapDef:MapDef = null

# state
var _templateIndex:int = 0
var _editMode = EntEditMode.Select
var _selected:SpawnPoint = null
var _highlighted:SpawnPoint = null
var _ents = []

var _templates = [
	{ "typeId": MapDef.ENT_TYPE_START, "label": "PlayerStart" },
	{ "typeId": MapDef.ENT_TYPE_END, "label": "End" },
]

func _ready() -> void:
	refresh_type_label()

func set_map_def(newMapDef:MapDef) -> void:
	_mapDef = newMapDef
	_load_ents()

func set_active(flag:bool) -> void:
	_isActive = flag
	if _isActive:
		$ui/template_list.visible = true
	else:
		$ui/template_list.visible = false

func _get_template() -> Dictionary:
	return _templates[_templateIndex]

func refresh_type_label() -> void:
	var temp = _get_template()
	var txt:String = ""
	txt += "Ents: " + str(_ents.size()) + "\n"
	if _highlighted != null:
		txt += "highlighted: " + str(_highlighted) + "\n"
	if _selected != null:
		txt += "selected: " + str(_selected) + "\n"

	if _editMode == EntEditMode.Add:
		txt += "Create:\n"
		txt += str(temp.typeId) + ": " + str(temp.label) + "\n"
	elif _editMode == EntEditMode.Select:
		txt += "Select:\n"
	elif _editMode == EntEditMode.Rotate:
		txt += "Set Rotation\n"
	elif _editMode == EntEditMode.SetTargets:
		txt += "Set Targets\n"
	
	_entTypeLabel.text = txt

func update_cursor_pos(gridX:int, gridY:int) -> void:
	_gridX = gridX
	_gridY = gridY
	_find_highlighted_ent()

# func _world_pos_to_grid_v(pos:Vector3) -> Vector3
# 	var s:float = _mapDef.scale
# 	var hs:float = s * 0.5
# 	var posOffset:Vector3 = Vector3(s * 0.5, 0, s * 0.5)
# 	var result = pos * 

func _grid_pos_to_world(gridX:int, gridY:int) -> Vector3:
	var s:float = _mapDef.scale
	var hs:float = s * 0.5
	return Vector3(float(gridX) * s + hs, -1, float(gridY) * s + hs)

func _create_spawn_at(pos:Vector3) -> SpawnPoint:
	var prefab = _prefab_spawn_t.instance()
	add_child(prefab)
	_ents.push_back(prefab)
	var t:Transform = Transform.IDENTITY
	t.origin = pos
	prefab.global_transform = t
	return prefab

func _load_ents() -> void:
	var numEnts:int = _mapDef.spawns.size()
	print("EntEd - loading " + str(numEnts) + " ents")
	for i in range(0, numEnts):
		var def:MapSpawnDef = _mapDef.spawns[i]
		var gx:int = int(def.position.x)
		var gy:int = int(def.position.z)
		var spawn:SpawnPoint = _create_spawn_at(_grid_pos_to_world(gx, gy))
		spawn.def = def
		def.position.x = gx
		def.position.z = gy

func _click_add() -> void:
	var template = _get_template()
	# var t:Transform = Transform.IDENTITY
	# var s:float = _mapDef.scale
	# var hs:float = s * 0.5
	# t.origin.x = float(_gridX) * s + hs
	# t.origin.y = -1
	# t.origin.z = float(_gridY) * s + hs
	# t.origin = _grid_pos_to_world(_gridX, _gridY)
	var prefab = _create_spawn_at(_grid_pos_to_world(_gridX, _gridY))
	print("Create " + str(template.typeId))
	# var prefab = _prefab_spawn_t.instance()
	# add_child(prefab)
	# _ents.push_back(prefab)
	# prefab.global_transform = t
	# setup ent info
	var _def:MapSpawnDef = _mapSpawnDef_t.new()
	_def.type = template.typeId
	_def.position = Vector3(_gridX, 0, _gridY)
	_mapDef.spawns.push_back(_def)

	# link spawnpoint obj and map def
	prefab.def = _def

func _click_select() -> void:
	if _highlighted == null:
		if _selected != null:
			_selected.set_selected(false)
			_selected = null
		return
	if _highlighted == _selected:
		return
	if _selected != null:
		_selected.set_selected(false)
	_selected = _highlighted
	_selected.set_selected(true)

func _delete_selected() -> void:
	if _selected == null:
		return
	var i:int = _ents.find(_selected)
	if i == -1:
		print("Cannot find delete target in ent list")
		return
	var j = _mapDef.spawns.find(_selected.def)
	if j == -1:
		print("Cannot find delete target's spawn in map def")
		return
	_ents.remove(i)
	_mapDef.spawns.remove(j)
	remove_child(_selected)
	_selected = null

func process_click() -> void:
	if _editMode == EntEditMode.Add:
		_click_add()
	elif _editMode == EntEditMode.Select:
		_click_select()

func _find_highlighted_ent() -> void:
	var cam:Camera = get_viewport().get_camera()
	if cam == null:
		return
	var mouse:Vector2 = get_viewport().get_mouse_position()
	var origin:Vector3 = cam.project_ray_origin(mouse)
	var dir:Vector3 = cam.project_ray_normal(mouse)
	var newHighlight = null
	var result = ZqfUtils.hitscan_by_pos_3D(self, origin, dir, 1000, [], (1 << 18))
	
	if result && result.collider is SpawnPoint:
		newHighlight = result.collider
	
	if newHighlight == null:
		if _highlighted != null:
			# print("Clear highlight")
			_highlighted.set_highlighted(false)
			_highlighted = null
		refresh_type_label()
		return
	
	if _highlighted != null:
		_highlighted.set_highlighted(false)
		_highlighted = null
	_highlighted = newHighlight
	# print("Set highlight: " + str(_highlighted))
	_highlighted.set_highlighted(true)
	refresh_type_label()

func update(_delta:float) -> void:
	if Input.is_action_just_pressed("slot_1"):
		_editMode = EntEditMode.Select
		refresh_type_label()
	if Input.is_action_just_pressed("slot_2"):
		_editMode = EntEditMode.Add
		refresh_type_label()
	if Input.is_action_just_pressed("slot_3"):
		_editMode = EntEditMode.Rotate
		refresh_type_label()
	if Input.is_action_just_pressed("slot_4"):
		_editMode = EntEditMode.SetTargets
		refresh_type_label()
	if Input.is_action_just_pressed("editor_delete"):
		_delete_selected()
		refresh_type_label()
