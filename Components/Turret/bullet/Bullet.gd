extends Spatial

export var damage: float = 1.0

onready var shoot_dir = Vector3.FORWARD

func hit():
	if $Detector.chased != null:
		if $Detector.chased.has_node('Life'):
			$Detector.chased.get_node('Life').take_damage(damage)

func _on_Bullet_body_entered(body):
	hit()
