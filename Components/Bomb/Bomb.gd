extends RigidBody

export var planted_group: String = 'Planted'
export var holding_group: String = 'Holding'
export var throw_tutorial: String = 'Press LMB to Throw'
export var size: float = 0.7
export var start_size: float = 0.1

onready var on_floor: bool = false
onready var Explosion = preload("res://Components/Bomb/Explosion.tscn")
onready var original_pos: Vector3 = Vector3.ZERO
onready var exploded: bool = false

func grow(sz: float) -> void:
	var tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_trans(Tween.TRANS_SINE)
	yield(tween.tween_property($CollisionShape,'scale',Vector3.ONE*sz,1),"finished")
	tween.stop()

func _ready():
	grow(size)
	original_pos = global_translation
	
func explode():
	var explosion = Explosion.instance()
	explosion.global_translation = global_translation
	get_parent().get_parent().add_child(explosion)
	$CollisionShape.scale = Vector3.ONE * start_size
	global_translation.y -= 500000
	$Reset.start()
	exploded = true

func _process(delta):
	if is_in_group(planted_group) and on_floor and !exploded:
		mode = RigidBody.MODE_STATIC if on_floor else mode
		explode()
	if is_in_group(holding_group):
		mode = RigidBody.MODE_RIGID

func _integrate_forces(state):
	on_floor = $OnFloorCheck.is_on_floor(state)

func _on_Reset_timeout():
	mode = RigidBody.MODE_STATIC
	remove_from_group(holding_group)
	remove_from_group(planted_group)
	grow(size)
	exploded = false
	global_translation = original_pos
