tool
extends KinematicBody2D

# references ------------------------------------------------------------------


# signals ---------------------------------------------------------------------


# variables -------------------------------------------------------------------
export(GEM.PLAYER_IDS) var id = GEM.PLAYER_IDS.start
var state = GEM.PLAYER_STATES.active setget set_state
export var color = Color.white setget set_color

export(GEM.SOCKET_TYPES) var socket_type = GEM.SOCKET_TYPES.none setget set_socket_type
export(GEM.DIRECTIONS) var socket_direction = GEM.DIRECTIONS.left setget set_socket_direction
export(GEM.PLUG_TYPES) var plug_type = GEM.PLUG_TYPES.none setget set_plug_type
export(Array, Texture) onready var socket_sprites
export(Array, Texture) onready var plug_sprites

var velocity = Vector2.ZERO
export var velocity_max = Vector2.ZERO
export var accel = Vector2.ZERO
export var decel = Vector2.ZERO

export var squish_min = Vector2.ZERO
export var squish_max = Vector2.ZERO

var other_player = null
var plug_area = null
var plug_rotation_degrees = 0
var plug_zone_position = Vector2.ZERO
var target_plug_zone_position = Vector2.ZERO
var plugged_in = false setget set_plugged_in


# main functions --------------------------------------------------------------
func _ready():
	# connect signals
	
	#set player state
	if id == GEM.PLAYER_IDS.start:
		self.state = GEM.PLAYER_STATES.active
		self.socket_type = GEM.SOCKET_TYPES.none
	else:
		self.state = GEM.PLAYER_STATES.inactive
		self.socket_type = socket_type
	
	#initialize variables
	self.socket_direction = socket_direction
	self.plug_type = plug_type


func _process(delta):
	plug_zone_position = $Sprite/PlugZonePosition.global_position


func _physics_process(delta):
	if Engine.editor_hint or state == GEM.PLAYER_STATES.inactive:
		global_position = Vector2(stepify(global_position.x, 32), stepify(global_position.y, 32))
		return
	
	get_input()
#	get_squish()  #removed squish for now as it messed with the plug animations
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


var plug_out_position = Vector2(42,0)
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
	print($PlugPivot/PlugSprite.position.distance_to(plug_out_position))
	if plug_area and not at_target_plug_zone_position() and plug_target_position != plug_in_position:
		global_position = lerp(global_position, target_plug_zone_position, .4)
	
	self.plugged_in = $PlugPivot/PlugSprite.position.distance_to(plug_out_position) < 5
	

func at_target_plug_zone_position():
	var distance_to_zone_position_threshhold = 1
	return global_position.distance_to(target_plug_zone_position) < distance_to_zone_position_threshhold and plug_area


# set/get functions -----------------------------------------------------------
func set_color(new_val):
	color = new_val
	
	modulate = color


func set_plugged_in(new_val):
	if plugged_in != new_val:
		print("plugged in")
		GSM.emit_signal("plugged_in", id, other_player.id)
		get_parent().remove_child(self)
		other_player.get_node("Node2D").add_child(self)
		other_player.state = GEM.PLAYER_STATES.active
		self.state = GEM.PLAYER_STATES.inactive
		
	
	plugged_in = new_val


func set_socket_type(new_val):
	socket_type = new_val
	if socket_type < socket_sprites.size():
		$Sprite.texture = socket_sprites[socket_type]


func set_socket_direction(new_val):
	socket_direction = new_val
	if has_node("Sprite"):
		$Sprite.rotation_degrees = socket_direction
		print(socket_direction
		)
	

func set_plug_type(new_val):
	plug_type = new_val
	if plug_type < plug_sprites.size():
		$PlugPivot/PlugSprite.texture = plug_sprites[plug_type]


func set_state(new_val):
	state = new_val
	
	if state == GEM.PLAYER_STATES.active:
		$PlugPivot/PlugSprite.show()
	else:
		$PlugPivot/PlugSprite.hide()


# signal functions ------------------------------------------------------------
func _on_Area2D_area_entered(area):
	if area.is_in_group("plug"):
		other_player = area.get_parent().get_parent()
		plug_area = area
		plug_rotation_degrees = int(round(area.get_parent().rotation_degrees))
		target_plug_zone_position = other_player.plug_zone_position


func _on_Area2D_area_exited(area):
	if area.is_in_group("plug"):
		plug_area = null
		target_plug_zone_position
