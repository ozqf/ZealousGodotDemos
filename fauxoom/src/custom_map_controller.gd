extends Spatial
class_name CustomMapLoader

func _ready() -> void:
    var map = AsciMapLoader.build_test_map()
    $map_gen.build_world_map(map)
