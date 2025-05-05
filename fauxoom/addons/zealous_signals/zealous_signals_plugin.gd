@tool
extends EditorPlugin

func _list_triggers(obj:Object):
	var signals = obj.get_signal_list()
	for _i in range(0, signals.size()):
		var sig = signals[_i]
		if sig.name != "trigger":
			continue
		
		var connections = get_signal_connection_list("trigger")
		print("Trigger has " + str(connections.size()) + " connections")
		for _j in range(0, connections.size()):
			print("Connection: " + str(connections[_j]))
		# print("Signal: " + str(signals[_i]))

func _list_connections(obj:Object):
	var connections = obj.get_signal_connection_list("trigger")
	var numConnections:int = connections.size()
	if numConnections == 0:
		return
	print("Obj \"" + obj.name + "\" has " + str(numConnections) + " connections")
	for _i in range(0, numConnections):
		var connection = connections[_i]
		# connection dict eg:
		# binds: []
		# flags: (int)
		# method "on_trigger"
		# signal: "trigger"
		# source: object
		# target: object
		var src:Node3D = connection.source as Node3D
		var tar:Node3D = connection.target as Node3D
		var srcPos:Vector3 = src.global_transform.origin
		var tarPos:Vector3 = tar.global_transform.origin
		if src == null || tar == null:
			continue
#		print("Trigger connection: " + str(connection))
		print("Trigger conn from " + src.name + " to " + tar.name + "(" + str(srcPos) + " to " + str(tarPos) + ")")

# should this plugin be run for the given node?
func handles(obj:Object) -> bool:
	_list_connections(obj)
	if obj is ZGUBlock2Mesh:
		return true
	return false
