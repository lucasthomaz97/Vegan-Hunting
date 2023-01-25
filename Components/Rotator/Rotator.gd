extends Spatial

export var rotate_amount: float = 0.025

func _process(delta):
	rotation_degrees.y = rand_range(0,360)
