extends Spatial

func pound(state:PhysicsDirectBodyState, pound_force: float, jump_height:float, max_vel_to_pound:float) -> Vector3:
	var y_only_if_positive: float = (state.linear_velocity.y+jump_height+(pound_force*int(state.linear_velocity.y==0)))*jump_height if state.linear_velocity.y >= 0 else 0
	var inverted_y: float = state.linear_velocity.y if state.linear_velocity.y > 0 else -state.linear_velocity.y
	var pound_vector:Vector3 = Vector3.DOWN * sqrt(pound_force*-pound_force*-(y_only_if_positive+inverted_y)) if state.linear_velocity.y > -max_vel_to_pound else Vector3.DOWN
	return pound_vector
