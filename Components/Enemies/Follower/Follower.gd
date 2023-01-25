extends RigidBody

export var to_follow: String = 'House'
export var move_speed: float = 100
export var max_speed: float = 12
export var turn_weight: float = 20
export var on_air_divider: float = 0.08
export var hp: int = 3

onready var floor_rate: float = 0.125

func _ready():
	set_as_toplevel(true)
	rotation_degrees = Vector3.ZERO
	$Move.on_air_divider = on_air_divider
	$OnFloorCheck.floor_rate = floor_rate
	$Move.move_speed = move_speed
	$Detector.target.append(to_follow)

func _process(delta):
	hp = $Life/Render/ProgressBar.value
	if hp < 1:
		$Life.destroyed(self)
		$CPUParticles.emitting = true
		$Q.start()

func _integrate_forces(state):
	$Mesh/slime/AnimationPlayer.play("walk")
	$Move.on_floor = $OnFloorCheck.is_on_floor(state)
	$Rotate.adjust_rotation(state.linear_velocity, turn_weight, $Mesh)
	if $Detector.chased != null:
		add_central_force($Move.move($Detector.chased.global_translation, global_translation))
	$LimitSpeed.limit_velocity(state, max_speed, $Move.on_floor)

func _on_Q_timeout():
	queue_free()
