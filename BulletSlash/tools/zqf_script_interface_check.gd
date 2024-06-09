@tool
extends EditorScript
# Crude implementation of a static analyser that will check that
# gdscript files implement specified functions
# its quick and janky and plenty of room for improvement
# (eg loading interfaces from an external file, better parsing,
# performance over a large project may suck)

# add #@implements ifoo
# at the TOP of a gdscript file to implement the interface 'ifoo' in a script
# Run from gdscript editor
# file -> run or ctrl + shift + x
# view results in output window.

const LINE_MODE_READING_NAME:int = 0
const LINE_MODE_IDENTIFIER:int = 1
const LINE_MODE_TYPE:int = 2
const LINE_MODE_FIND_RETURN_TYPE:int = 3
const LINE_MODE_READING_RETURN_TYPE:int = 4

const EMPTY_TYPE:String = "void"

var verbose:bool = false

# declare the interface in this dictionary below
func _get_interfaces() -> Dictionary:
	var interfacesRaw = {
		ifoo = [
			"func get_foo(a:int, b:float, c:Node3D, d) -> int:",
			"func set_foo(b) -> void:",
			"func a():",
			"func b() -> float:"
		],
		ibar = [
			"func a():",
			"func b() -> float:"
		],
		IHittable = [
			"func hit(info:HitInfo) -> int:",
			"func get_team_id() -> int:"
		],
		IProjectile = [
			"func launch() -> void:",
			"func get_launch_info() -> ProjectileLaunchInfo:",
			"func cancel(cancelMode:int) -> void:"
		]
	}
	# extract interface function tokens
	var interfaces:Dictionary = {}
	for key in interfacesRaw.keys():
		interfaces[key] = {}
		for line in interfacesRaw[key]:
			var sig = _extract_signature(line)
			interfaces[key][sig[0]] = sig
	return interfaces

# returns array where the first item is the function name and
# last type is the return type, eg:
# "func foo(a:int, b:Node3D) -> int:"
# will return ["foo", "int", "Node3D", "int"]
# unspecified types are 'void'
# TODO: Replace with a proper tokeniser
# Note: intolerate of any variations of formatting it finds.
# eg: assumes entire function is on one line!
func _extract_signature(scriptLine:String) -> PackedStringArray:
	# run to params start
	var result:PackedStringArray = []
	var lineLen:int = scriptLine.length()
	# skip 'func ' to function name
	var cursor:int = scriptLine.find(" ") + 1
	var tokenStart:int = cursor
	var reading:bool = true
	var mode:int = LINE_MODE_READING_NAME
	var chr = scriptLine[0]
	while reading:
		var prevChr = chr
		chr = scriptLine[cursor]
		cursor += 1
		if cursor >= lineLen:
			reading = false
		match mode:
			LINE_MODE_READING_NAME:
				if chr != '(':
					continue
				var strLen:int = (cursor - 1) - tokenStart
				var functionName:String = scriptLine.substr(tokenStart, strLen)
				result.push_back(functionName)
				mode = LINE_MODE_IDENTIFIER
			LINE_MODE_IDENTIFIER:
				if chr == ':':
					mode = LINE_MODE_TYPE
					# we are on : but cursor has stepped to the next char already
					tokenStart = cursor
				elif chr == ',':
					# not type specified
					result.push_back(EMPTY_TYPE)
				if chr == ')':
					if !prevChr == '(':
						result.push_back(EMPTY_TYPE)
					mode = LINE_MODE_FIND_RETURN_TYPE
				continue
			LINE_MODE_TYPE:
				if chr == ',' || chr == ")":
					# end of type name
					var strLen:int = (cursor - 1) - tokenStart
					var typeName:String = scriptLine.substr(tokenStart, strLen)
					result.push_back(typeName)
					if chr == ")":
						mode = LINE_MODE_FIND_RETURN_TYPE
					else:
						mode = LINE_MODE_IDENTIFIER
				continue
			LINE_MODE_FIND_RETURN_TYPE:
				if chr == ':':
					result.push_back(EMPTY_TYPE)
					continue
				if chr == ' ' || chr == '-' || chr == '>':
					continue
				tokenStart = cursor - 1
				mode = LINE_MODE_READING_RETURN_TYPE
			LINE_MODE_READING_RETURN_TYPE:
				if chr == ':':
					var strLen:int = (cursor - 1) - tokenStart
					var typeName = scriptLine.substr(tokenStart, strLen)
					result.push_back(typeName)
	return result

func _packed_array_to_csv(arr:PackedStringArray) -> String:
	return ",".join(arr)

# compare two arrays of function tokens, eg:
# ["foo", "int", "float", "void"] vs ["foo", "int", "int", "void"]
func _compare_signatures(interface:PackedStringArray, implementation:PackedStringArray) -> PackedStringArray:
	var issues:PackedStringArray = []
	if interface.size() != implementation.size():
		var a:String = _packed_array_to_csv(interface)
		var b:String = _packed_array_to_csv(implementation)
		issues.push_back("mismatching signature lengths: " + str(interface.size()) + " vs " + str(implementation.size()))
		return issues
	for i in range(0, interface.size()):
		if interface[i] != implementation[i]:
			var a:String = _packed_array_to_csv(interface)
			var b:String = _packed_array_to_csv(implementation)
			issues.push_back( "Mismatch token at " + str(i) + " for " + str(interface[0]))
	return issues

func _check_implementation(
	scriptText:String, functions:Dictionary, scriptName:String, interfaceName:String) -> void:
	var lines:PackedStringArray = scriptText.split("\n")
	var implemented:Dictionary = {}
	for line in lines:
		if !line.begins_with("func "):
			continue
		var scriptFuncName:String = line.substr(5, line.find("(") - 5)
		# check if this function in the file matches one in the interface
		if !functions.has(scriptFuncName):
			continue
		var implementation = _extract_signature(line)
		implemented[scriptFuncName] = implementation
	
	var interfaceFuncKeys = functions.keys()
	for key in interfaceFuncKeys:
		if !implemented.has(key):
			print(">>> missing function " + str(functions[key]) + " in " + str(scriptName))
			continue
		# compare signatures
		var interface = functions[key]
		var implementation = implemented[key]
		var interfaceSigLen:int = interface.size()
		var implementationSigLen:int = implementation.size()
		var result:PackedStringArray = _compare_signatures(functions[key], implemented[key])
		if result.size() > 0:
			var a:String = _packed_array_to_csv(interface)
			var b:String = _packed_array_to_csv(implementation)
			print(">>> Issues on '" + key + "': " + a + " vs " + b)
		for issue in result:
			print("\t" + issue)

func _check_for_interfaces(gdScriptPath:String, interfaces:Dictionary) -> void:
	var file = FileAccess.open(gdScriptPath, FileAccess.READ)
	if file == null:
		print("Failed to open " + gdScriptPath)
		return
	var txt:String = file.get_as_text()
	#TODO: interface implementation must be right at the start of the file
	if !txt.begins_with("#@implements"):
		return
	
	# extract the first line and look for an implement list
	var line:String = txt.substr(0, txt.find("\n"))
	var tokens:PackedStringArray = line.split(" ")
	# remove the first token, the 'implements' keyword
	tokens.remove_at(0)
	for token in tokens:
		if verbose:
			print("\t" + gdScriptPath + "\timplements " + str(token))
		if !interfaces.has(token):
			print("Interface " + str(token) + " is not defined!")
			continue
		_check_implementation(txt, interfaces[token], gdScriptPath, token)

func _full_project_scan() -> void:
	print("--- Interfaces - full scan ---")
	
	var interfaces:Dictionary = _get_interfaces()
	
	print("Found " + str(interfaces.keys().size()) + " interfaces")
	# scan project for gdscript files
	var files:Dictionary = {}
	find_all_files_with_extension("res://", files, ".gd")
	print("Found " + str(files.keys().size()) + " files")
	print("--- checking interfaces ---")
	for key in files.keys():
		_check_for_interfaces(key, interfaces)

static func find_all_files_with_extension(path:String, results:Dictionary, extension:String) -> void:
	if path.begins_with('res:///.'):
		return
	# print("Searching path " + path)
	var files:PackedStringArray = DirAccess.get_files_at(path)
	var dirs:PackedStringArray = DirAccess.get_directories_at(path)
	for fileName in files:
		if fileName.ends_with(extension):
			results[path + "/" + fileName] = 0
	for dir in dirs:
		find_all_files_with_extension(path + "/" + dir, results, extension)

static func simplify_path(path:String) -> String:
	var tokens = path.split("/")
	var shortened:String = tokens[tokens.size() - 1]
	shortened = shortened.replace(".tres", "")
	return shortened

func _test() -> void:
	var a = _extract_signature("func b() -> float:")
	var b = _extract_signature("func b() -> int:")
	print(str(a.size()) + ": " + _packed_array_to_csv(a))
	print(str(b.size()) + ": " + _packed_array_to_csv(b))
	var result = _compare_signatures(a, b)
	for issue in result:
		print(">>> " + issue)

func _run() -> void:
	print("-------------------------------------------")
#	_test()
	_full_project_scan()
	print("Done")
