extends ImmediateGeometry

const EdEnums = preload("res://zqf_entity_editor/zee_enums.gd")

var _drawFieldName:String = "tagcsv"

var _proxy:ZEEEntityProxy = null
var _dirty:bool = true

var _colours:PoolColorArray = PoolColorArray()

var _drawTick:float = 0.0

func _ready():
	add_to_group(EdEnums.GROUP_NAME)
	_colours.push_back(Color.red)
	_colours.push_back(Color.green)
	_colours.push_back(Color.blue)
	_colours.push_back(Color.purple)
	_colours.push_back(Color.orange)
	_colours.push_back(Color.cyan)
	_colours.push_back(Color.white)

func zee_on_new_entity_proxy(newProxy) -> void:
	_proxy = newProxy
	_dirty = true
	_drawTick = 0.0
	pass

func zee_on_clear_entity_selection() -> void:
	_proxy = null
	_drawTick = 9999

func _process(_delta:float) -> void:
	if !_proxy:
		return
	# if !_dirty:
	# 	return
	# _dirty = false
	if _drawTick > 0.0:
		_drawTick -= _delta
		return
	_drawTick = 0.2
	var fields = _proxy.get_tag_fields()
	# print("Draw tag links found " + str(fields.size()) + " tag fields on subject")
	clear()
	begin(Mesh.PRIMITIVE_LINES)
	var numFields:int = fields.size()
	var numColours:int = _colours.size()
	for i in range(0, numFields):
		var field = fields[i]
		if field.name == "tagcsv":
			# don't draw incoming triggers yet
			continue
		set_color(_colours[i % numColours])
		var subjectTags:PoolStringArray = field.value.split(",", false, 0)
		draw_tags(_proxy, subjectTags)
	end()

func _intersects(a:PoolStringArray, b:PoolStringArray) -> bool:
	for txtA in a:
		for txtB in b:
			if txtA == txtB:
				return true
	return false

func draw_tags(subject:ZEEEntityProxy, targetTags:PoolStringArray) -> void:
	var origin:Vector3 = subject.global_transform.origin
	var proxies = get_tree().get_nodes_in_group(EdEnums.GROUP_ENTITY_PROXIES)
	for item in proxies:
		var proxy:ZEEEntityProxy = item as ZEEEntityProxy
		var tags = proxy.get_tags_field("tagcsv")
		if !_intersects(targetTags, tags):
			continue
		# draw connection line
		var dest:Vector3 = proxy.global_transform.origin
		add_vertex(origin)
		add_vertex(dest)
	pass
