extends RigidBody

export var crop: String = 'Floor'
export var planted_group: String = 'Planted'
export var holding_group: String = 'Holding'
export var plant_name: String = 'Plant'
export var Plant: PackedScene
export var throw_tutorial: String = 'Press LMB to Plant'

func _process(delta):
	$Name.text = plant_name + ' Seed'
	if is_in_group(planted_group) and mode == RigidBody.MODE_STATIC:
		var pl = Plant.instance()
		pl.global_translation = global_translation
		get_parent().add_child(pl)
		queue_free()
	elif is_in_group(holding_group):
		$Tutorial.text = throw_tutorial
	
func _integrate_forces(state):
	for contact in state.get_contact_count():
		var collider = state.get_contact_collider_object(contact)
		if collider != null and is_in_group(planted_group):
			if collider.name == crop:
				mode = RigidBody.MODE_STATIC
