extends Control

export var Game: String = "res://Scenes/Garden.tscn"

func _ready():
	$AnimationPlayer.play("qqr")
	
func _process(delta):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _on_Button_pressed():
	get_tree().change_scene(Game)
