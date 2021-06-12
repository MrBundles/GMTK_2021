tool
extends KinematicBody2D

# references ------------------------------------------------------------------


# signals ---------------------------------------------------------------------


# variables -------------------------------------------------------------------
export var id = 0
export var color = Color.white setget set_color
export(GEM.SOCKET_TYPES) var socket_type = GEM.SOCKET_TYPES.none setget set_socket_type
export(GEM.PLUG_TYPES) var plug_type = GEM.PLUG_TYPES.none setget set_plug_type
export(Array, Texture) var socket_sprites = []
export(Array, Texture) var plug_sprites = []

var velocity = Vector2.ZERO
export var velocity_max = Vector2.ZERO
export var accel = Vector2.ZERO
export var decel = Vector2.ZERO

export var squish_min = Vector2.ZERO
export var squish_max = Vector2.ZERO

var plug_area = null
var plug_rotation_degrees = 0
var plug_zone_position = Vector2.ZERO
var plugged_in = false setget set_plugged_in


# main functions --------------------------------------------------------------
func _ready():
	# connect signals
	
	
	pass


func _process(delta):
	pass


func _physics_process(delta):
	if Engine.editor_hint:
		return
	
	get_input()
#	get_squish()
	update_plug()
	move_and_slide(velocity * delta * 1000, Vector2.UP)


# helper functions ------------------------------------------------------------
func get_input():
	#handle collisions
	if is_on_floor() or is_on_ceiling():
		velocity.y = 0

	if is_on_wall():
		velocity.x = 0
	
	#handle horizontal input
	if Input.is_action_pressed("ui_left") and not plugged_in:
		velocity.x = clamp(velocity.x - accel.x, -velocity_max.x, velocity_max.x)
	elif Input.is_action_pressed("ui_right") and not plugged_in:
		velocity.x = clamp(velocity.x + accel.x, -velocity_max.x, velocity_max.x)
	elif velocity.x < -accel.x:
		velocity.x = clamp(velocity.x + decel.x, -velocity_max.x, velocity_max.x)
	elif velocity.x > accel.x:
		velocity.x = clamp(velocity.x - decel.x, -velocity_max.x, velocity_max.x)
	else:
		velocity.x = 0
	
	#handle vertical input
	if Input.is_action_pressed("ui_up") and is_on_floor() and not plugged_in:
		velocity.y = clamp(velocity.y - accel.y, -velocity_max.y, velocity_max.y)
	else:
		velocity.y = clamp(velocity.y + decel.y, -velocity_max.y, velocity_max.y)


var lerp_val = 1
func get_squish():
	#set vertical squish based on vertical velocity
	lerp_val = lerp(lerp_val, velocity.y / velocity_max.y, .2)
	$Sprite.scale.y = lerp(squish_min.y, squish_max.y, lerp_val)
	
	#set horizontal squish based on vertical squish
	$Sprite.scale.x = lerp(squish_max.x, squish_min.x, $Sprite.scale.y / 1)
	
	#set vertical position of sprite so it always sits on the ground
	$Sprite.position.y = -$Sprite.scale.y * 32 + 32


var plug_out_position = Vector2(35,0)
var plug_in_position = Vector2(0,0)
func update_plug():
	var plug_target_position = Vector2(0,0)
	$PlugPivot.scale = $Sprite.scale
	
	if Input.is_action_pressed("ui_up") and plug_area and plug_rotation_degrees == 270:
		$PlugPivot.rotation_degrees = 270
		plug_target_position = plug_out_position
	elif Input.is_action_pressed("ui_down") and plug_area and plug_rotation_degrees == 90:
		$PlugPivot.rotation_degrees = 90
		plug_target_position = plug_out_position
	elif Input.is_action_pressed("ui_left") and plug_area and plug_rotation_degrees == 180:
		$PlugPivot.rotation_degrees = 180
		plug_target_position = plug_out_position
	elif Input.is_action_pressed("ui_right") and plug_area and plug_rotation_degrees == 0:
		$PlugPivot.rotation_degrees = 0
		plug_target_position = plug_out_position
	else:
		plug_target_position = plug_in_position
	
	$PlugPivot/PlugSprite.position = lerp($PlugPivot/PlugSprite.position, plug_target_position, .2)
	if plug_area and not at_plug_zone_position() and plug_target_position != plug_in_position:
		global_position = lerp(global_position, plug_zone_position, .2)
	
	plugged_in = $PlugPivot/PlugSprite.position.distance_to(plug_out_position) < 5
	

func at_plug_zone_position():
	var distance_to_zone_position_threshhold = 25
	return global_position.distance_to(plug_zone_position) < distance_to_zone_position_threshhold


# set/get functions -----------------------------------------------------------
func set_color(new_val):
	color = new_val
	
	modulate = color


func set_plugged_in(new_val):
	if plugged_in != new_val:
		GSM.emit_signal("plugged_in", id, plug_area.get_parent(id))
	
	plugged_in = new_val


func set_socket_type(new_val):
	if socket_type != new_val:
		$Sprite.texture = socket_sprites[socket_type]
	
	socket_type = new_val


func set_plug_type(new_val):
	if plug_type != new_val:
		$PlugPivot/PlugSprite.texture = plug_sprites[plug_type]
		print(plug_type)
	
	plug_type = new_val


# signal functions ------------------------------------------------------------
func _on_Area2D_area_entered(area):
	if area.is_in_group("plug"):
		plug_area = area
		plug_rotation_degrees = int(round(area.get_parent().rotation_degrees))
		plug_zone_position = area.get_parent().plug_zone_position


func _on_Area2D_area_exited(area):
	if area.is_in_group("plug"):
		plug_area = null
		plug_zone_position
