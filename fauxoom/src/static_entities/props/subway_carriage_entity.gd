extends Node

onready var _northDoor1:Spatial = $north_door_1
onready var _northDoor2:Spatial = $north_door_2

onready var _southDoor1:Spatial = $south_door_1
onready var _southDoor2:Spatial = $south_door_2

onready var _northEastDoor1:Spatial = $north_east_door_1
onready var _northEastDoor2:Spatial = $north_east_door_2

onready var _northWestDoor1:Spatial = $north_west_door_1
onready var _northWestDoor2:Spatial = $north_west_door_2

onready var _southEastDoor1:Spatial = $south_east_door_1
onready var _southEastDoor2:Spatial = $south_east_door_2

onready var _southWestDoor1:Spatial = $south_west_door_1
onready var _southWestDoor2:Spatial = $south_west_door_2

export var northDoorOpen:bool = false
export var southDoorOpen:bool = false

export var northEastDoorOpen:bool = false
export var northWestDoorOpen:bool = false
export var southEastDoorOpen:bool = false
export var southWestDoorOpen:bool = false

func _ready():
	if northDoorOpen:
		_northDoor1.transform.origin += Vector3(-1, 0, 0)
		_northDoor2.transform.origin += Vector3(1, 0, 0)
		pass
	if southDoorOpen:
		_southDoor1.transform.origin += Vector3(-1, 0, 0)
		_southDoor2.transform.origin += Vector3(1, 0, 0)
		pass
	
	# door 1 == negative z, door 2 positive
	if northEastDoorOpen:
		ZqfUtils.local_translate(_northEastDoor1, Vector3(0, 0, -1))
		ZqfUtils.local_translate(_northEastDoor2, Vector3(0, 0, 1))
	if northWestDoorOpen:
		ZqfUtils.local_translate(_northWestDoor1, Vector3(0, 0, -1))
		ZqfUtils.local_translate(_northWestDoor2, Vector3(0, 0, 1))
	if southEastDoorOpen:
		ZqfUtils.local_translate(_southEastDoor1, Vector3(0, 0, -1))
		ZqfUtils.local_translate(_southEastDoor2, Vector3(0, 0, 1))
	if southWestDoorOpen:
		ZqfUtils.local_translate(_southWestDoor1, Vector3(0, 0, -1))
		ZqfUtils.local_translate(_southWestDoor2, Vector3(0, 0, 1))
