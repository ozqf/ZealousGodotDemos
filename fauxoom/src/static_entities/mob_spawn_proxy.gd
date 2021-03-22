extends Spatial
class_name MobSpawnProxy


enum EnemyType {
	Gunner,
	FleshWorm,
	Gasbag
}
export(EnemyType) var type = EnemyType.Gunner
export(String) var targetName:String = ""
export(String) var target:String = ""

func _ready() -> void:
	visible = false
