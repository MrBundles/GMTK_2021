extends Node

# references ------------------------------------------------------------------


# signals ---------------------------------------------------------------------


# variables -------------------------------------------------------------------
export var new_game_scene_id = 0
export(GEM.MENU_SCENES) var new_menu_scene_id = GEM.MENU_SCENES.main


# main functions --------------------------------------------------------------
func _ready():
	# connect signals
	
	
	pass


func _process(delta):
	pass


# helper functions ------------------------------------------------------------



# set/get functions -----------------------------------------------------------



# signal functions ------------------------------------------------------------




func _on_Button_pressed():
	GSM.emit_signal("change_scene", new_game_scene_id, new_menu_scene_id)
