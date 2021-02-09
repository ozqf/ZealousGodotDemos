extends Spatial
class_name EntityEditor

const _prefab_spawn_t = preload("res://map_gen/prefabs/spawn_point.tscn")
const _mapSpawnDef_t = preload("./map_spawn_def.gd")

enum EntEditMode { Select, Add, Rotate, SetTargets }

onready var _entTypeLabel:Label = $ui/template_list/ent_type_label

# updated from controller
var _gridX:int = 0
var _gridY:int = 0
var _mapDef:MapDef = null
var _isActive:bool = false

# state
var _templateIndex:int = 0
var _editMode = EntEditMode.Select
var _selected:SpawnPoint = null
var _highlighted:SpawnPoint = null
var _ents = []

var _templates = [
	{ "typeId": 1, "label": "PlayerStart" },
	{ "typeId": 2, "label": "End" },
]

func _ready() -> void:
	refresh_type_label()

func set_map_def(newMapDef:MapDef) -> void:
	_mapDef = newMapDef

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

func _click_add() -> void:
	var t:Transform = Transform.IDENTITY
	var s:float = _mapDef.scale
	var hs:float = s * 0.5
	t.origin.x = float(_gridX) * s + hs
	t.origin.y = -1
	t.origin.z = float(_gridY) * s + hs
	print("Create " + str(_templateIndex) + " at " + str(t.origin.x) + ", " + str(t.origin.z))
	var prefab = _prefab_spawn_t.instance()
	add_child(prefab)
	_ents.push_back(prefab)
	prefab.global_transform = t

func _click_select() -> void:
	pass

func process_click() -> void:
	if _editMode == EntEditMode.Add:
		_click_add()
	pass

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
