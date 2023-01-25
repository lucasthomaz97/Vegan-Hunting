extends Position3D

export var enemy: String = "res://Components/Enemies/Follower/Follower.tscn"
export var enemy_target: String = 'House'
export var offset_randomness: float = 20
export var interval_in_sec: float = 1
export var active: bool = true

onready var Enemy = load(enemy)

func spawn():
	var e = Enemy.instance()
	e.to_follow = enemy_target
	e.global_translation = global_translation
	get_parent().get_parent().add_child(e)

func _ready():
	$Timer.wait_time = interval_in_sec

func _on_Timer_timeout():
	if active:
		spawn()
