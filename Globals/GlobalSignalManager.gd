extends Node
# GLOBAL SIGNAL MANAGER

# references ------------------------------------------------------------------


# signals ---------------------------------------------------------------------

#		audio signals
signal set_bus_volume				# bus_id, new_val
signal set_bus_mute					# bus_id, new_val

#		scene management signals
signal change_scene					# new_game_scene_id, new_menu_scene_id

signal plugged_in					# plug id, socket id

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


