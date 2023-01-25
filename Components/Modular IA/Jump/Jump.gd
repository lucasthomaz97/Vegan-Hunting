extends Spatial

func jump(state:PhysicsDirectBodyState, jump_height:float, floor_rate:float, on_floor:bool=true, on_air_divider:float=0.08, buffer: bool=false, on_water:bool=false) -> Vector3:
	var jump_vector: Vector3 = Vector3.ZERO
	var h_impulse: float = jump_height*int(!on_water)
	var v_impulse: float = jump_height
	var on_water_gravity: float = (state.total_gravity.y - state.linear_velocity.y)*on_air_divider if state.total_gravity.y - state.linear_velocity.y < 0 else -(state.total_gravity.y - state.linear_velocity.y)*jump_height*((on_air_divider+floor_rate)+1)
	jump_vector.y = sqrt(v_impulse*-v_impulse*state.total_gravity.y) if !on_water else sqrt(v_impulse*-v_impulse*on_water_gravity)
	jump_vector.y = jump_vector.y + (state.linear_velocity.y*-1) if state.linear_velocity.y < 0 else jump_vector.y
	return jump_vector

func will_jump_obstacle() -> bool:
	return true if $RayCast.is_colliding() and !$RayCast2.is_colliding() else false
