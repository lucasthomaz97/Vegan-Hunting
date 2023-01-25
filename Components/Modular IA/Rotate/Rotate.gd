extends Spatial

func adjust_rotation(movement:Vector3, turn_weight: float, to_rotate:Spatial) -> void:
	to_rotate.rotation.y = lerp_angle(to_rotate.rotation.y, atan2(movement.x, movement.z), get_physics_process_delta_time()*turn_weight) if !(movement.x == 0 and movement.z == 0) else to_rotate.rotation.y
