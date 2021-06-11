extends Node
# GLOBAL AUDIO MANAGER

# references ------------------------------------------------------------------


# signals ---------------------------------------------------------------------


# variables -------------------------------------------------------------------



# main functions --------------------------------------------------------------
func _ready():
	# connect signals
	GSM.connect("set_bus_volume", self, "_on_set_bus_volume")
	GSM.connect("set_bus_mute", self, "_on_set_bus_mute")
	
	pass


func _process(delta):
	pass


# helper functions ------------------------------------------------------------



# set/get functions -----------------------------------------------------------



# signal functions ------------------------------------------------------------
func _on_set_bus_volume(bus_id, new_val):
	AudioServer.set_bus_volume_db(bus_id, new_val)


func _on_set_bus_mute(bus_id, new_val):
	AudioServer.set_bus_mute(bus_id, new_val)

