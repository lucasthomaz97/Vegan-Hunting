extends Spatial

export var move_speed: float = 100
export var on_air_divider: float = 0.08

onready var on_floor: bool = false
onready var distance: Vector3 = Vector3.ZERO

func controlability()-> float:
	return 1.0 if on_floor else on_air_divider

func move(objective: Vector3, my_translation: Vector3):
	distance = my_translation.direction_to(objective)
	var move_dir = Vector3(distance.x, 0, distance.z).normalized()*move_speed
	return move_dir
