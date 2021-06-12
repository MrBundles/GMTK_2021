extends Node
# GLOBAL ENUM MANAGER

# enums -----------------------------------------------------------------------
#		scene management enums
enum MENU_SCENES {no_change, game_ui, main, level_select, settings, credits, pause, bug_report}
enum SCENE_TRANSITION_MODES {no_transition, color_wipe, texture_wipe, color_fade, texture_fade, mask_fade}
enum SCENE_TRANSITION_DIRECTIONS {up, down, left, right}

enum SOCKET_TYPES {none, single_square, single_triangle, single_circle, double_square, double_triangle, double_circle}
enum PLUG_TYPES {none, single_square, single_triangle, single_circle, double_square, double_triangle, double_circle}
enum PLAYER_IDS {start, end, none, a, b, c, d, e, f, g, h, i, j, k}
enum PLAYER_STATES {active, inactive}
enum DIRECTIONS {up=90, down=-90, left=0, right=180}

# references ------------------------------------------------------------------


# signals ---------------------------------------------------------------------


# variables -------------------------------------------------------------------



# main functions --------------------------------------------------------------
func _ready():
	# connect signals
	
	
	pass


func _process(delta):
	pass


# helper functions ------------------------------------------------------------



# set/get functions -----------------------------------------------------------



# signal functions ------------------------------------------------------------


