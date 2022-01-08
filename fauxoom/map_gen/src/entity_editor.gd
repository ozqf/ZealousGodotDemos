extends Spatial
class_name EntityEditor

const _prefab_spawn_t = preload("res://map_gen/prefabs/point_spawn.tscn")
const actor_spawn_t = preload("res://map_gen/prefabs/actor_spawn.tscn")
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

# templates is defined externally and injected in
var _templates = [ { "typeId": 1, "label": "Placeholder" } ]

func _ready() -> void:
	refresh_type_label()

func init(newMapDef:MapDef, entityTemplates) -> void:
	_templates = entityTemplates
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
	if template == null:
		return
	var prefab = _create_spawn_at(_grid_pos_to_world(_gridX, _gridY))
	print("Create " + str(template.typeId))
	
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

func process_left_held(_delta:float) -> void:
	pass

func set_yaw(obj:SpawnPoint, degrees:float) -> void:
	degrees = ZqfUtils.cap_degrees(degrees)
	var step = 360.0 / MapSpawnDef.ROTATION_STEPS
	var iterations:float = int(degrees / step)
	var result = iterations * step
	var rot = Vector3(0, result, 0)
	obj.rotation_degrees = rot
	obj.def.yaw = result
	print("Set rotation (" + str(degrees) + " to " + str(result) + ")")

func process_right_click() -> void:
	if _selected == null:
		return
	if _editMode == EntEditMode.Rotate:
		var dest:Vector3 = _grid_pos_to_world(_gridX, _gridY)
		var t:Transform = _selected.global_transform
		var origin = t.origin
		var dx = dest.x - origin.x
		var dz = origin.z - dest.z
		var degrees = rad2deg(atan2(dz, dx))
		degrees -= 90
		print("Rotate from " + str(origin) + " look at " + str(dest))
		print("degrees: " + str(degrees))
		set_yaw(_selected, degrees)
#		var rot = Vector3(0, degrees, 0)
#		_selected.rotation_degrees = rot
	else:
		var dest:Vector3 = _grid_pos_to_world(_gridX, _gridY)
		print("Move selected to " + str(dest))
		var t:Transform = _selected.global_transform
		t.origin = dest
		_selected.global_transform = t
		_selected.def.position.x = _gridX
		_selected.def.position.z = _gridY

func _find_highlighted_ent() -> void:
	var cam:Camera = get_viewport().get_camera()
	if cam == null:
		return
	var mouse:Vector2 = get_viewport().get_mouse_position()
	var origin:Vector3 = cam.project_ray_origin(mouse)
	var dir:Vector3 = cam.project_ray_normal(mouse)
	var newHighlight = null
	var result = ZqfUtils.hitscan_by_direction_3D(self, origin, dir, 1000, [], (1 << 18))
	
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

func _next_template() -> void:
	_templateIndex += 1
	if _templateIndex >= _templates.size():
		_templateIndex=  0
	refresh_type_label()

func _prev_template() -> void:
	_templateIndex -= 1
	if _templateIndex < 0:
		_templateIndex = _templates.size() - 1
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
	
	if Input.is_action_just_pressed("edit_mode_next"):
		_next_template()
	if Input.is_action_just_pressed("edit_mode_prev"):
		_prev_template()
