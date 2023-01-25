extends Spatial

export var shoot_interval_in_sec: float = 0.1
export var target: String = 'Follower'
const size: float = 0.6
const speed: float = 5.0
const turn_weight: float = 100.0
var bullet = load("res://Components/Turret/bullet/Bullet.tscn")

onready var can_shoot: bool = false

func _ready():
	$TMesh/qt_flower/AnimationPlayer.play("Grow")
	$grow.play(0)
	$Detector.target.append(target)
	can_shoot = false

func _process(delta):
	if $Detector.chased != null and can_shoot:
		look_at($Detector.chased.global_translation.normalized(), Vector3.UP)
		$anim.play("shoot")

func _on_AnimationPlayer_animation_finished(anim_name):
	can_shoot = true
