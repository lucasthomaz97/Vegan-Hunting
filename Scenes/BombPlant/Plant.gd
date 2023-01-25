extends Spatial

export var fruit: String = "res://Components/Bomb/Bomb.tscn"
export var fruit_name:String = 'Bomb'

var Fruit = load(fruit)
var qtt_inside: int = 0

func _ready():
	$bomb_flower/AnimationPlayer.play("Grow")
