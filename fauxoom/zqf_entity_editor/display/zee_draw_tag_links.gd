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

func zee_on_new_entity_selection(newProxy) -> void:
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
	clear()
	begin(Mesh.PRIMITIVE_LINES)
	_draw_outgoing_links()
	_draw_incoming_links()
	end()

func _draw_outgoing_links() -> void:
	var fields = _proxy.get_tag_fields()
	# print("Draw tag links found " + str(fields.size()) + " tag fields on subject")
	
	var numFields:int = fields.size()
	var numColours:int = _colours.size()
	var colourI:int = 0
	for i in range(0, numFields):
		var field = fields[i]
		if field.name == "tagcsv":
			# don't draw incoming triggers yet
			continue
		set_color(_colours[colourI % numColours])
		colourI += 1
		var subjectTags:PoolStringArray = field.value.split(",", false, 0)
		draw_tags(_proxy, subjectTags)

func _draw_incoming_links() -> void:
	var origin:Vector3 = _proxy.global_transform.origin
	var proxies = get_tree().get_nodes_in_group(EdEnums.GROUP_ENTITY_PROXIES)
	var subjectTags:PoolStringArray = _proxy.get_tags_field_value("tagcsv")
	set_color(Color.white)
	var numProxies:int = proxies.size()
	for i in range(0, numProxies):
		var proxy = proxies[i]
		var dest:Vector3 = proxy.global_transform.origin

		var fields = proxy.get_tag_fields()
		for field in fields:
			if field.name == "tagcsv":
				continue
			var queryTags:PoolStringArray = field.value.split(",", false, 0)
			if !_intersects(subjectTags, queryTags):
				continue
			add_vertex(origin)
			add_vertex(dest)

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
		var tags = proxy.get_tags_field_value("tagcsv")
		if !_intersects(targetTags, tags):
			continue
		# draw connection line
		var dest:Vector3 = proxy.global_transform.origin
		add_vertex(origin)
		add_vertex(dest)
	pass
