extends Area

export (NodePath) var target_path : NodePath
export var y_lerp_speed : float = 175
export var h_lerp_speed: float = 450
export var check_on_floor_method: String = 'is_on_floor'
export var max_offset_y : float = 1.5
export var on_ground_v_offset: float = -0.1
export var max_distance: float = 30

onready var target : RigidBody = get_node(target_path)
onready var target_inside: bool = false
onready var target_grounded: bool = false
onready var target_was_grounded: bool = false
onready var insider: Spatial
onready var target_y: float = 0
onready var target_pos: Vector2 = Vector2.ZERO
onready var target_pos_y: float = 0
onready var speed: float = 0

func check_if_target_is_inside(to_iterate:Array=get_overlapping_bodies()) -> bool:
	for inside in to_iterate:
		if inside == target:
			return true
		else:
			insider = inside
	return false

func check_if_target_on_floor() -> bool:
	if target.has_method(check_on_floor_method):
		return target.on_floor
	return false

func is_something_ahead(all_inside: Array = $ObstacleCheck.get_overlapping_bodies()) -> bool:
	var max_coll: float = len(all_inside)-1
	var coll: int = 0
	for child in all_inside:
		coll+=0 if child == target or (target_grounded and Utils.check_if_many_is_equal([child.rotation_degrees.x, child.rotation_degrees.z],[0, -0])) else 1
	return true if coll <= max_coll and coll > 0 else false

func _ready():
	set_as_toplevel(true)

func _process(delta):
	var other_delta: float = get_physics_process_delta_time()
	$CollisionShape.global_rotation.y = target.get_child(0).global_rotation.y
	$ObstacleCheck.global_rotation.y = target.get_child(0).global_rotation.y

func _physics_process(delta):
	var other_delta: float = get_process_delta_time()
	target_grounded = check_if_target_on_floor()
	target_inside = check_if_target_is_inside()
	target_y = target.global_translation.y+ max_offset_y
	target_pos_y = global_translation.y if !target_grounded or !global_translation.distance_squared_to(target.global_translation) >= max_distance else target_y
	target_pos_y = target_y if is_something_ahead() or is_something_ahead(get_overlapping_bodies()) or !target_inside else target_pos_y
	target_pos = Vector2(target.global_translation.x, target.global_translation.z)
	global_translation.x = lerp(global_translation.x, target_pos.x, h_lerp_speed *other_delta *delta)
	global_translation.z = lerp(global_translation.z, target_pos.y, h_lerp_speed *other_delta *delta)
	global_translation.y = lerp(global_translation.y, target_pos_y, y_lerp_speed *other_delta *delta)
	target_was_grounded = target_grounded
