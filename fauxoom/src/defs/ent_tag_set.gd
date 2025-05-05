class_name EntTagSet

var _tags:PackedStringArray = PackedStringArray()

func tag_count() -> int:
	return _tags.size()

func get_tag_by_index(index:int) -> String:
	if index < 0 || index >= _tags.size():
		return ""
	return _tags[index]

func has_tag(queryTag:String) -> bool:
	for tag in _tags:
		if tag == queryTag:
			return true
	return false

func add_tag(newTag:String) -> void:
	if self.has_tag(newTag):
		return
	_tags.push_back(newTag)

func remove_tag(removeTag:String) -> void:
	var l:int = _tags.size()
	for _i in range(0, l):
		if _tags[_i] == removeTag:
			_tags.remove(_i)
			return

func get_tags() -> PackedStringArray:
	return _tags

func get_csv() -> String:
	return _tags.join(",")

func read_csv(csv:String) -> void:
	_tags = csv.split(",", false, 0)

func read_from_dict_field(dict, fieldName) -> void:
	var current:String = get_csv()
	var data:String = ZqfUtils.safe_dict_s(dict, fieldName, current)
	read_csv(data)

func write_to_dict_field(dict, fieldName) -> void:
	dict[fieldName] = get_csv()

func append_global_tags(tagDict:Dictionary) -> void:
	for tag in _tags:
		if !tagDict.has(tag):
			tagDict[tag] = ""
