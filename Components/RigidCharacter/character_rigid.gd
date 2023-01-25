extends RigidBody

export (NodePath) var camera_path : NodePath
export var jump_height : float = 3.525
export var water_resistance : float = 0.875
export var turn_weight : int = 20
export var rotation_weight: int = 7
export var floor_rate : float = 0.45
export var move_speed : int = 200
export var deadzone : float = 0.2
export var max_speed : float = 13
export var water_max_speed: float = 24
export var on_air_divider : float = 0.08
export var suspended_jump : float = 2
export var coyote_multiplier : float = 1.75
export var throw_force: int = 12
export var enemy_throw_multiplier: float = 1.2
export var throw_vector: Vector3 = Vector3(0, 0.5, 2)
export var grab_anim_time: float = 0.1
export var seed_group: String = 'Seed'
export var weapon_group: String = 'Weapon'
export var holding_group: String = 'Holding'
export var planted_group: String = 'Planted'

var move_dir : Vector3 = Vector3.ZERO
var last_strong_direction : Vector3 = Vector3.FORWARD
var is_jumping : bool = false
var active_jump_buffer : bool = false
var input : Vector3 = Vector3.ZERO
var fwd_bwd : float = 0
var lft_rgt : float = 0
var on_floor : bool = false
var on_water : bool = false
var suspended : bool = false
var was_on_floor: bool = false
var floor_normal: Vector3 = Vector3.ZERO
var was_on_wall: bool = false
var was_on_water: bool = false
var was_jumping: bool = false
var held_object: RigidBody
var hold_max_weight: int = 100
var air_pause : bool = false

onready var camera : Spatial = get_node(camera_path)
onready var current_vel : Vector3 = Vector3.ZERO
onready var checkpoint : Vector3 = Vector3.ZERO

func get_input() -> Vector3:
	var input_y = Input.get_joy_axis(0, JOY_ANALOG_LY) if !Input.get_connected_joypads().empty() else Input.get_axis("ui_up","ui_down")
	var input_x = Input.get_joy_axis(0, JOY_ANALOG_LX) if !Input.get_connected_joypads().empty() else Input.get_axis("ui_left", "ui_right")
	return Vector3(input_x*int(input_x < -deadzone or input_x > deadzone),0,input_y*int(input_y < -deadzone or input_y > deadzone)).normalized()
	
func get_input_camera_oriented()->Vector3:
	input = get_input()
	var final_input: Vector3 = Vector3.ZERO
	final_input.x = input.x * sqrt(1.0 - input.z * input.z / 2.0)
	final_input.z = input.z * sqrt(1.0 - input.x * input.x / 2.0)
	return $impulse.global_transform.basis.orthonormalized().xform(final_input)

func adjust_character_rotation(movement:Vector3) -> float:
	var common_rotation : Vector3 = $Mesh.rotation
	return lerp_angle($Mesh.rotation.y, atan2(movement.x, movement.z), get_physics_process_delta_time()*turn_weight) if !(movement.x == 0 and movement.z == 0) else common_rotation.y

func limit_velocity(state: PhysicsDirectBodyState) -> void:
	var limit = (int(on_floor)*max_speed)-(int(on_water)*water_max_speed)
	limit = -limit if limit < 0 else limit
	state.linear_velocity.y = 0 if (!$Coyote.is_stopped() and !is_jumping and !on_floor) else state.linear_velocity.y
	state.linear_velocity = Vector3.ZERO if suspended else state.linear_velocity
	var limited_velocity = state.linear_velocity.normalized()*min(limit, state.linear_velocity.length()) if on_floor or on_water else state.linear_velocity
	state.linear_velocity = Vector3(limited_velocity.x, state.linear_velocity.y, limited_velocity.z)

func is_on_floor(state: PhysicsDirectBodyState) -> bool:
	for contact in state.get_contact_count():
		var contact_normal = state.get_contact_local_normal(contact)
		if contact_normal.dot(Vector3.UP) > floor_rate:
			floor_normal = contact_normal
			return true
	return false
	
func game_over() -> void:
	global_translation = checkpoint
	linear_velocity = Vector3.ZERO
	$CameraDirector.global_translation = checkpoint
	
func is_on_water(inside: bool) -> void:
	on_water = inside

func can_jump() -> bool:
	if ((on_floor or suspended or !$Coyote.is_stopped() or !$GravityNotFreezeCoyote.is_stopped() or on_water) and bool(Input.get_action_strength("ui_accept"))) or (!$JumpBuffer.is_stopped() and on_floor):
		return true
	else: 
		return false

func jump(state:PhysicsDirectBodyState, buffer: bool) -> bool:
	var jump_vector: Vector3 = Vector3.ZERO
	var h_impulse: float = jump_height*int(!on_water)
	var v_impulse: float = jump_height
	var on_water_gravity: float = (state.total_gravity.y - state.linear_velocity.y)*on_air_divider if state.total_gravity.y - state.linear_velocity.y < 0 else -(state.total_gravity.y - state.linear_velocity.y)*jump_height*((on_air_divider+floor_rate)+1)
	jump_vector.y = sqrt(v_impulse*-v_impulse*state.total_gravity.y) if !on_water or suspended else sqrt(v_impulse*-v_impulse*on_water_gravity)
	jump_vector += Vector3(state.linear_velocity.x, 0, state.linear_velocity.z)*h_impulse*jump_height if buffer and on_floor else Vector3.ZERO
	$Coyote.stop()
	$GravityNotFreezeCoyote.stop()
	$JumpBuffer.stop()
	suspended = false
	apply_central_impulse(jump_vector)
	$AfterJump.start()
	return true
	
func update_grabbed() -> void: 
	held_object.transform.basis = $Mesh.transform.basis
	held_object.linear_velocity.y = clamp(held_object.linear_velocity.y,5, 1000) if !on_floor and held_object.global_translation.y <= $holding.global_translation.y else linear_velocity.y
	
func grab_action() -> void:
	grab_object() if $Mesh/grab.is_colliding() and held_object == null else throw_object()
	
func grab_object() -> void:
	if $Mesh/grab.get_collider() is RigidBody and $Mesh/grab.get_collider().weight < hold_max_weight:
		var origin_layer: Array = $"/root/Utils".get_collision_layer_bits($Mesh/grab.get_collider(),true)
		var origin_mask: Array = $"/root/Utils".get_collision_mask_bits($Mesh/grab.get_collider(), true)
		$"/root/Utils".change_collision_activation($Mesh/grab.get_collider(),origin_layer,origin_mask, false, false)
		var to_held : RigidBody = $Mesh/grab.get_collider()
		$anim.set('parameters/holding/current', 1)
		$anim.set('parameters/grab/active', true)
		$ThrowDelay.start()
		var tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_trans(Tween.TRANS_SINE)
		yield(tween.tween_property(to_held,"global_translation", $holding.global_translation, grab_anim_time),"finished")
		tween.stop()
		held_object = to_held
		held_object.global_translation = $holding.global_translation
		if held_object.is_in_group(seed_group) or held_object.is_in_group(weapon_group):
			held_object.add_to_group(holding_group)
		to_held = null
		$holding/PinJoint.set_node_b(held_object.get_path())
		$"/root/Utils".change_collision_activation(held_object, origin_layer, origin_mask, true, true)
		
func throw_object() -> void:
	if held_object != null and $ThrowDelay.is_stopped():
		if held_object.is_in_group(seed_group) or held_object.is_in_group(weapon_group):
			held_object.add_to_group(planted_group)
		held_object.apply_central_impulse($Mesh.global_transform.basis.orthonormalized().xform(throw_force*throw_vector))
		held_object = null
		$holding/PinJoint.set_node_b($holding/PinJoint.get_path())
		$anim.set('parameters/throw/active', true)
	
func can_coyote() -> bool:
	var can = (!on_floor and !is_jumping and was_on_floor and $Coyote.is_stopped() and $AfterVImpulse.is_stopped()) and !Input.is_action_just_pressed("ui_accept")
	return can
	
func can_gravity_not_freeze_coyote() -> bool:
	var can = (!on_floor and !is_jumping and (was_on_floor or was_on_water) and $AfterJump.is_stopped() and $Coyote.is_stopped() and $GravityNotFreezeCoyote.is_stopped()) and !Input.is_action_just_pressed("ui_select")
	return can
	
func controlability()-> float:
	return 1.0 - (int(on_water)*water_resistance) if on_floor or on_water else on_air_divider
	
func _ready():
	$GravityNotFreezeCoyote.wait_time = $Coyote.wait_time
	$anim.active = true
	Score.Score = 0
	checkpoint = global_translation
	
func _process(delta):
	$anim.set('parameters/holding/current', int(held_object != null))
	$impulse.rotation_degrees.y = camera.rotation_degrees.y
	
func _physics_process(delta):
	update_grabbed() if held_object != null else null
	$Center/Score.text = 'Score: '+str(Score.Score)
	$anim.set('parameters/running/current', int(move_dir == Vector3.ZERO))
	$anim.set('parameters/run/current', int(move_dir == Vector3.ZERO))

func _integrate_forces(state: PhysicsDirectBodyState) -> void:
	is_jumping = false
	on_floor = is_on_floor(state)
	move_dir = get_input_camera_oriented()*move_speed*controlability()
	suspended = true if $Mesh/front.is_colliding() and !$Mesh/up.is_colliding() and state.linear_velocity.y < 0 and !on_floor else false
	
	grab_action() if Input.is_action_pressed("ui_grab") else null
	add_central_force(move_dir)
	is_jumping = jump(state, active_jump_buffer) if can_jump() and !was_jumping else false
	
	$Mesh.rotation.y = adjust_character_rotation(move_dir) if !suspended else $Mesh.rotation.y
	$AfterVImpulse.start() if !is_jumping and !on_floor and linear_velocity.y >= 1 else null 
	$Coyote.start() if can_coyote() else null
	$GravityNotFreezeCoyote.start() if can_gravity_not_freeze_coyote() else null
	$JumpBuffer.start() if !on_floor and $Coyote.is_stopped() and Input.is_action_just_pressed("ui_accept") and !is_jumping else null
	
	limit_velocity(state)
	current_vel = state.linear_velocity
	was_on_floor = on_floor
	was_on_water = on_water
	was_on_wall = $Mesh/front.is_colliding() and $Mesh/up.is_colliding()
	was_jumping = is_jumping
	active_jump_buffer = !$JumpBuffer.is_stopped()
