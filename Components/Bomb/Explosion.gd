extends Area

export var size: float = 7
export var speed: float = 0.3
export var target: String = 'Follower'
export var damage: float = 2

func _ready():
	$CPUParticles.emitting = true
	$CollisionShape/CPUParticles2.emitting = true
	$Detector.target.append(target)
	var tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_trans(Tween.TRANS_SINE)
	yield(tween.tween_property($CollisionShape, 'scale', Vector3.ONE*size, speed), "finished")
	tween.stop()
	$CollisionShape/MeshInstance.queue_free()
	space_override = Area.SPACE_OVERRIDE_DISABLED
	yield($sfx,"finished")
	queue_free()

func _process(delta):
	$Detector.scale = $CollisionShape.scale
	if $Detector.chased != null:
		if $Detector.chased.has_node('Life'):
			$Detector.chased.get_node('Life').take_damage(damage)
