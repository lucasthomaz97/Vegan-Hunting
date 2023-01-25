extends Spatial

func limit_velocity(state: PhysicsDirectBodyState, max_speed:float, on_floor: bool, on_water:bool=false, water_max_speed:float=24) -> void:
	var limit = (int(on_floor)*max_speed)-(int(on_water)*water_max_speed)
	limit = -limit if limit < 0 else limit
	var limited_velocity = state.linear_velocity.normalized()*min(limit, state.linear_velocity.length()) if on_floor or on_water else state.linear_velocity
	state.linear_velocity = Vector3(limited_velocity.x, state.linear_velocity.y, limited_velocity.z)
