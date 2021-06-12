extends Node

# references ------------------------------------------------------------------


# signals ---------------------------------------------------------------------


# variables -------------------------------------------------------------------
var plug_zone_position = Vector2.ZERO


# main functions --------------------------------------------------------------
func _ready():
	# connect signals
	
	
	plug_zone_position = $PlugZone.global_position


func _process(delta):
	pass


# helper functions ------------------------------------------------------------



# set/get functions -----------------------------------------------------------



# signal functions ------------------------------------------------------------


