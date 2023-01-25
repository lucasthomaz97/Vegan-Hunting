extends Area

func _process(delta):
	for body in get_overlapping_bodies():
		if body.has_method('game_over'):
			body.game_over()
		else:
			body.queue_free()
