class_name Groups

const CONSOLE_GROUP_NAME:String = "console"
const CONSOLE_FN_EXEC:String = "console_on_exec"

const SYSTEM_GROUP_NAME:String = "system"
const SYSTEM_FN_CONFIG_CHANGE:String = "config_changed"

const INFLUENCE_GROUP:String = "influence_map"
const INFLUENCE_FN_ADD:String = "influence_map_add"
const INFLUENCE_FN_REMOVE:String = "influence_map_remove"
const INFLUENCE_FN_REGISTER_MAP:String = "influence_register_map"
const INFLUENCE_FN_DEREGISTER_MAP:String = "influence_deregister_map"

const GAME_GROUP_NAME:String = "game"
const GAME_FN_PAUSE:String = "game_pause"
const GAME_FN_UNPAUSE:String = "game_unpause"
const GAME_FN_MAP_CHANGE:String = "game_on_map_change"
const GAME_FN_RUN_MAP_SPAWNS:String = "game_run_map_spawns"
const GAME_FN_CLEANUP_TEMP_ENTS:String = "game_cleanup_temp_ents"
const GAME_FN_EVENT_EXPLOSION:String = "game_explosion"
const GAME_FN_EVENT_COMPLETE:String = "game_event_complete"
# reset isn't a thing now. Uses 'load checkpoint' instead
# const GAME_FN_RESET:String = "game_on_reset"
const GAME_FN_PLAYER_SPAWNED:String = "game_on_player_spawned"
const GAME_FN_PLAYER_DIED:String = "game_on_player_died"
# single param: dictionary of info
const GAME_FN_KING_GAME_OVER:String = "game_on_king_game_over"
const GAME_FN_LEVEL_COMPLETED:String = "game_on_level_completed"
const GAME_FN_REGISTER_PREVIEW_CAMERA:String = "game_register_preview_camera"
const GAME_FN_CAMERA_UPDATE:String = "game_camera_update"
const GAME_FN_KILL_AI:String = "game_kill_ai"

const GAME_FN_READ_MAP_TEXT_SUCCESS:String = "game_on_read_map_text_success"
const GAME_FN_READ_MAP_TEXT_FAIL:String = "game_on_read_map_text_fail"
const GAME_FN_LOAD_BASE64:String = "game_on_load_base64"
const GAME_FN_SAVE_MAP_TEXT:String = "game_on_save_map_text"
const GAME_FN_WROTE_MAP_TEXT:String = "game_on_wrote_map_text"

# single param - the new environment to apply
const GAME_FN_SET_ENVIRONMENT:String = "game_set_environment"

# generic entity events group
const ENTS_GROUP_NAME:String = "entities"
const ENTS_FN_TRIGGER_ENTITIES:String = "on_trigger_entities"
const ENTS_FN_SET_DEBUG_MOB:String = "on_set_debug_mob"
const ENTS_FN_RESTORED_ENTITY:String = "on_restored_entity"
const ENTS_FN_GLOBAL_COMMAND:String = "ents_on_global_command"
const ENTS_FN_MOB_AWOKE_ID:String = "ents_mob_awoke_id"
const ENTS_FN_MOB_DIED_ID:String = "ents_mob_died_id"
# called after an entity file has been loaded
const ENTS_FN_POST_LOAD:String = "ents_post_load"

const ENTS_CMD_DISABLE_ALL_FORCEFIELDS:String = "disable_all_forcefields"
const ENTS_CMD_ENABLE_ALL_FORCEFIELDS:String = "enable_all_forcefields"
const ENTS_CMD_KILL_ALL_AI:String = "kill_all_ai"

const STATIC_ENTS_GROUP_NAME:String = "static_entities"
const DYNAMIC_ENTS_GROUP_NAME:String = "dynamic_entities"
# ONLY hyper core grenades should be in this group!
const HYPER_CORES_GROUP:String = "hyper_cores"

const PRJ_GROUP_NAME:String = "projectiles"
# signature: Vector3 position, float radius, int cullTeamId
const PRJ_FN_BULLET_CANCEL_AT:String = "prj_bullet_cancel_at"
# signature: Vector3 position, int playerEntityId
const PRJ_FN_PLAYER_LASER_AIM_AT:String = "prj_laser_laser_aim_at"

const PLAYER_GROUP_NAME:String = "player"
const PLAYER_FN_STATUS:String = "player_status_update"
const PLAYER_FN_HIT:String = "player_hit"
const PLAYER_FN_WEAPON_CHANGE:String = "player_weapon_change"
const PLAYER_FN_MOVED:String = "player_camera_moved"
const PLAYER_FN_GROUND_SLAM_START:String = "player_ground_slam_start"
const PLAYER_FN_GROUND_SLAM_FINISH:String = "player_ground_slam_finished"
const PLAYER_FN_OPEN_DEBUG_MENU:String = "player_open_debug_menu"
const PLAYER_FN_CLOSE_DEBUG_MENU:String = "player_close_debug_menu"
# TODO: Why are there two of these?
const PLAYER_FN_PICKUP:String = "player_pickup"
const PLAYER_FN_GOT_ITEM:String = "player_got_item"

const HUD_GROUP_NAME:String = "hud"
const HUD_FN_PLAY_WEAPON_IDLE:String = "hud_play_weapon_idle"
const HUD_FN_PLAY_WEAPON_SHOOT:String = "hud_play_weapon_shoot"
const HUD_FN_PLAY_WEAPON_EMPTY:String = "hud_play_weapon_empty"
