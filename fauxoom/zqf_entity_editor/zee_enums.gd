
const GROUP_NAME:String = "zqf_entity_editor"
# one param: new root type
const FN_ROOT_MODE_CHANGE:String = "zee_on_root_mode_changed"
const FN_GLOBAL_ENABLED:String = "zee_on_global_enabled"
const FN_GLOBAL_DISABLED:String = "zee_on_global_disabled"
# one param: new entity proxy instance
const FN_NEW_ENTITY_PROXY:String = "zee_on_new_entity_proxy"
const FN_CLEAR_ENTITY_SELECTION:String = "zee_on_clear_entity_selection"

enum RootMode {
	File,
	Select,
	Add,
	LinkTargets,
	Scale
}

enum ShapeType {
	Point,
	Actor,
	BoxVolume,
	SphereVolume
}
