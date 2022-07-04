# group for messaging between editor components
const GROUP_NAME:String = "zqf_entity_editor"
# should ONLY be joined by entity proxies and nothing else
const GROUP_ENTITY_PROXIES:String = "zee_entity_proxies"

# one param: new root type
const FN_ROOT_MODE_CHANGE:String = "zee_on_root_mode_changed"
const FN_GLOBAL_ENABLED:String = "zee_on_global_enabled"
const FN_GLOBAL_DISABLED:String = "zee_on_global_disabled"

const FN_ON_CREATED_NEW_ENTITY:String = "zee_on_created_new_entity"

# one param: new entity proxy instance
const FN_NEW_ENTITY_SELECTION:String = "zee_on_new_entity_selection"
const FN_REMOVED_ENTITY_PROXY:String = "zee_on_removed_entity_proxy"
# can't just clear proxy by sending a null as this counts as a no-parameter function
# so this is a second message to clear the proxy reference
const FN_CLEAR_ENTITY_SELECTION:String = "zee_on_clear_entity_selection"

const FN_EDIT_TAGS_FIELD:String = "zee_on_edit_tags_field"

const FIELD_TYPE_TAGS:String = "tags"

enum RootMode {
	File,
	Select,
	Add,
	LinkTargets,
	Rotate,
	Scale
}

enum ShapeType {
	Point,
	Actor,
	BoxVolume,
	SphereVolume
}
