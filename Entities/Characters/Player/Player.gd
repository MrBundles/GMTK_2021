tool
extends KinematicBody2D

# references ------------------------------------------------------------------


# signals ---------------------------------------------------------------------


# variables -------------------------------------------------------------------
export var color = Color.white setget set_color

var velocity = Vector2.ZERO
export var velocity_max = Vector2.ZERO
export var accel = Vector2.ZERO
export var decel = Vector2.ZERO

export var squish_min = Vector2.ZERO
export var squish_max = Vector2.ZERO

var in_plug_zone = false


# main functions --------------------------------------------------------------
func _ready():
	# connect signals
	
	
	pass


func _process(delta):
	print(in_plug_zone)


func _physics_process(delta):
	if Engine.editor_hint:
		return
	
	get_input()
	get_squish()
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
	if Input.is_action_pressed("ui_left"):
		velocity.x = clamp(velocity.x - accel.x, -velocity_max.x, velocity_max.x)
	elif Input.is_action_pressed("ui_right"):
		velocity.x = clamp(velocity.x + accel.x, -velocity_max.x, velocity_max.x)
	elif velocity.x < -accel.x:
		velocity.x = clamp(velocity.x + decel.x, -velocity_max.x, velocity_max.x)
	elif velocity.x > accel.x:
		velocity.x = clamp(velocity.x - decel.x, -velocity_max.x, velocity_max.x)
	else:
		velocity.x = 0
	
	#handle vertical input
	if Input.is_action_pressed("ui_up") and is_on_floor():
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


func update_plug():
	
	var plug_out_position = Vector2(0, 32)
	var plug_target_position = Vector2(0,0)
	
	if Input.is_action_pressed("ui_up"):
		$PlugPivot.rotation_degrees = 180
		plug_target_position = plug_out_position
	elif Input.is_action_pressed("ui_down"):
		$PlugPivot.rotation_degrees = 0
		plug_target_position = plug_out_position
	elif Input.is_action_pressed("ui_left"):
		$PlugPivot.rotation_degrees = 90
		plug_target_position = plug_out_position
	elif Input.is_action_pressed("ui_right"):
		$PlugPivot.rotation_degrees = 270
		plug_target_position = plug_out_position
	else:
		plug_target_position = Vector2(0,0)
	
	$PlugPivot/PlugSprite.position = lerp($PlugPivot/PlugSprite.position, plug_target_position, .2)
	


# set/get functions -----------------------------------------------------------
func set_color(new_val):
	color = new_val
	
	modulate = color


# signal functions ------------------------------------------------------------
func _on_Area2D_area_entered(area):
	if area.is_in_group("plug"):
		in_plug_zone = true


func _on_Area2D_area_exited(area):
	if area.is_in_group("plug"):
		in_plug_zone = false
