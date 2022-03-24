extends Node
class_name MobStats

const Enums = preload("res://src/enums.gd")

export var entityType:String = "mob_punk"
export var health:int = 50
export var moveSpeed:float = 4.5
export var evadeSpeed:float = 3
export var moveTime:float = 1.5
export var losCheckTime:float = 0.25
export var stunTime:float = 0.2
export var stunThreshold:int = 1
export(Enums.EnemyStrengthClass) var sizeClass = Enums.EnemyStrengthClass.Fodder
