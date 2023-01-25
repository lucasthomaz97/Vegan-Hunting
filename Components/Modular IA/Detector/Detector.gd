extends Area

export var target: Array = ['House']
onready var chased: Spatial

func check_detected(name, t):
	return true if name in t else false
	
func _process(_delta):
	for body in get_overlapping_bodies():
		chased = body if check_detected(body.name, target) else chased

func _on_Detector_body_entered(body):
	if body.name in target:
		chased = body

func _on_Detector_body_exited(body):
	if body.name in target:
		chased = null
