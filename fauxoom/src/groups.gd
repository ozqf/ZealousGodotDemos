class_name Groups

const CONSOLE_GROUP_NAME:String = "console"
const CONSOLE_FN_EXEC:String = "console_on_exec"

const GAME_GROUP_NAME:String = "game"
const GAME_FN_MAP_CHANGE:String = "game_on_map_change"
# reset isn't a thing now. Uses 'load checkpoint' instead
# const GAME_FN_RESET:String = "game_on_reset"
const GAME_FN_PLAYER_SPAWNED:String = "game_on_player_spawned"
const GAME_FN_PLAYER_DIED:String = "game_on_player_died"
const GAME_FN_LEVEL_COMPLETED:String = "game_on_level_completed"
const GAME_FN_REGISTER_PREVIEW_CAMERA:String = "game_register_preview_camera"

const GAME_FN_READ_MAP_TEXT_SUCCESS:String = "game_on_read_map_text_success"
const GAME_FN_READ_MAP_TEXT_FAIL:String = "game_on_read_map_text_fail"
const GAME_FN_LOAD_BASE64:String = "game_on_load_base64"
const GAME_FN_SAVE_MAP_TEXT:String = "game_on_save_map_text"
const GAME_FN_WROTE_MAP_TEXT:String = "game_on_wrote_map_text"

# generic entity events group
const ENTS_GROUP_NAME:String = "entities"
const ENTS_FN_TRIGGER_ENTITIES:String = "on_trigger_entities"

const STATIC_ENTS_GROUP_NAME:String = "static_entities"
const DYNAMIC_ENTS_GROUP_NAME:String = "dynamic_entities"

const PLAYER_GROUP_NAME:String = "player"
const PLAYER_FN_STATUS:String = "player_status_update"
const PLAYER_FN_HIT:String = "player_hit"
