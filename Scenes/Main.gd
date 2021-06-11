extends Node

# enums
enum TWEEN_EASE_TYPES {ease_in, ease_out, ease_in_out, ease_out_in}
enum TWEEN_TRANSITION_TYPES {trans_linear, trans_sine, trans_quint, trans_quart, trans_quad, trans_expo, trans_elastic, trans_cubic, trans_circ, trans_bounc, trans_back}

# arrays
var tween_ease_type_array = [Tween.EASE_IN, Tween.EASE_OUT, Tween.EASE_IN_OUT, Tween.EASE_OUT_IN]
var tween_transition_type_array = [Tween.TRANS_LINEAR, Tween.TRANS_SINE, Tween.TRANS_QUINT, Tween.TRANS_QUART, Tween.TRANS_QUAD, Tween.TRANS_EXPO, Tween.TRANS_ELASTIC, Tween.TRANS_CUBIC, Tween.TRANS_CIRC, Tween.TRANS_BOUNCE, Tween.TRANS_BACK]

# references ------------------------------------------------------------------
onready var game_scene_root = $SceneLayer/ViewportContainer/SceneViewport/GameSceneRoot
onready var menu_scene_root = $SceneLayer/ViewportContainer/SceneViewport/MenuSceneRoot

# signals ---------------------------------------------------------------------


# variables -------------------------------------------------------------------
export(Array, PackedScene) var game_scene_array = []
export(Array, PackedScene) var menu_scene_array = []
export(GEM.SCENE_TRANSITION_MODES) var scene_transition_mode = GEM.SCENE_TRANSITION_MODES.no_transition
export(GEM.SCENE_TRANSITION_DIRECTIONS) var scene_transition_direction = GEM.SCENE_TRANSITION_DIRECTIONS.up
export(Color) var scene_transition_color = Color(1.0,1.0,1.0)
export(Texture) var scene_transition_texture
export(float, 0.0, 10.0, 0.01) var scene_transition_out_duration = 1.0
export(float, 0.0, 10.0, 0.01) var scene_transition_in_duration = 1.0
export(float, 0.0, 10.0, 0.01) var scene_transition_out_delay = 1.0
export(float, 0.0, 10.0, 0.01) var scene_transition_in_delay = 1.0
export(TWEEN_EASE_TYPES) var tween_ease_type = TWEEN_EASE_TYPES.ease_out
export(TWEEN_TRANSITION_TYPES) var tween_transition_type = TWEEN_TRANSITION_TYPES.trans_linear

var game_scene_id = 0 setget set_game_scene_id
var menu_scene_id = GEM.MENU_SCENES.main setget set_menu_scene_id


# main functions --------------------------------------------------------------
func _ready():
	# connect signals
	GSM.connect("change_scene", self, "_on_change_scene")
	
	init()


func _process(delta):
	pass


# helper functions ------------------------------------------------------------
func init():
	# initialize variables to update in global variable manager
	self.game_scene_id = game_scene_id
	self.menu_scene_id = menu_scene_id
	
	
# set/get functions -----------------------------------------------------------
func set_game_scene_id(new_val):
	game_scene_id = new_val
	
	GVM.game_scene_id = game_scene_id


func set_menu_scene_id(new_val):
	menu_scene_id = new_val
	
	GVM.menu_scene_id = menu_scene_id


# signal functions ------------------------------------------------------------
func _on_change_scene(new_game_scene_id, new_menu_scene_id):
	# if scene is currently transitioning, reject scene change
	if $SceneTransitionTween.is_active():
		return


	# initialize current scene texture and pass to transition shader
	var previous_scene_viewport_img = $SceneLayer/ViewportContainer/SceneViewport.get_texture().get_data()
	var previous_scene_viewport_tex = ImageTexture.new()
	previous_scene_viewport_tex.create_from_image(previous_scene_viewport_img)
	$SceneLayer/TextureRect.material.set_shader_param("previous_scene_texture", previous_scene_viewport_tex)


	# replace current game scene with new game scene if necessary
	if game_scene_id == -1:
		game_scene_root.hide()
		pass
	else:
		# clear current game scenes
		for child in game_scene_root.get_children():
			child.queue_free()

		# instantiate and add new game scene to sample viewport
		var new_game_scene_instance = game_scene_array[new_game_scene_id].instance()
		game_scene_root.add_child(new_game_scene_instance)


	# replace current menu scene with new menu scene if necessary
	if menu_scene_id == GEM.MENU_SCENES.no_change:
		menu_scene_root.hide()
		pass
	else:
		# clear current menu scenes
		for child in menu_scene_root.get_children():
			child.queue_free()

		# instantiate and add new menu scene
		var new_menu_scene_instance = menu_scene_array[new_menu_scene_id].instance()
		menu_scene_root.add_child(new_menu_scene_instance)


	# hide viewport with texture rect
	$SceneLayer/TextureRect.material.set_shader_param("transition_out_val", 1.0)
	$SceneLayer/TextureRect.material.set_shader_param("transition_in_val", 1.0)
	$SceneLayer/TextureRect.material.set_shader_param("transition_direction", scene_transition_direction)
	$SceneLayer/TextureRect.material.set_shader_param("transition_color", scene_transition_color)
	$SceneLayer/TextureRect.material.set_shader_param("transition_texture", scene_transition_texture)
	$SceneLayer/TextureRect.show()
	print("showing rect")


	# wait for canvas to update
	for i in range(2):
		yield(get_tree(), "idle_frame")	


	# initialize new scene texture and pass to transition shader
	var new_scene_viewport_img = $SceneLayer/ViewportContainer/SceneViewport.get_texture().get_data()
	var new_scene_viewport_tex = ImageTexture.new()
	new_scene_viewport_tex.create_from_image(new_scene_viewport_img)
	$SceneLayer/TextureRect.material.set_shader_param("new_scene_texture", new_scene_viewport_tex)


	# hide scenes until transition is finished
	game_scene_root.hide()
	menu_scene_root.hide()


	# initialize scene transition tween
	$SceneTransitionTween.stop_all()
	$SceneTransitionTween.remove_all()


	# interpolate transition shader property based on given parameters
	$SceneTransitionTween.interpolate_property(
		$SceneLayer/TextureRect.material, 															# set tween object
		"shader_param/transition_out_val", 														# set tween property
		$SceneLayer/TextureRect.material.get_shader_param("transition_out_val"),					# set tween initial value
		0.0,																						# set tween final value
		scene_transition_out_duration, 																# set tween duration
		tween_transition_type_array[tween_transition_type], 										# set tween transition type
		tween_ease_type_array[tween_ease_type],														# set tween ease type
		scene_transition_out_delay)																	# set tween delay
	
	$SceneTransitionTween.interpolate_property(
		$SceneLayer/TextureRect.material, 															# set tween object
		"shader_param/transition_in_val", 														# set tween property
		$SceneLayer/TextureRect.material.get_shader_param("transition_in_val"),						# set tween initial value
		0.0,																						# set tween final value
		scene_transition_in_duration, 																# set tween duration
		tween_transition_type_array[tween_transition_type], 										# set tween transition type
		tween_ease_type_array[tween_ease_type],														# set tween ease type
		scene_transition_out_delay + scene_transition_in_delay)		# set tween delay


	# start transition tween
	$SceneTransitionTween.start()


	# pause scene tree during transition
	get_tree().paused = true


func _on_SceneTransitionTween_tween_all_completed():
	print("tween completed")
	game_scene_root.show()
	menu_scene_root.show()
	$SceneLayer/TextureRect.hide()
	get_tree().paused = false
