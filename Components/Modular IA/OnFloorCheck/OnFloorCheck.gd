extends Spatial

onready var floor_rate: float = 0.3

func is_on_floor(state: PhysicsDirectBodyState) -> bool:
	for contact in state.get_contact_count():
		var contact_normal = state.get_contact_local_normal(contact)
		if contact_normal.dot(Vector3.UP) >= floor_rate:
			return true
	return false
