extends Control

onready var score: float = 0

export var Menu: String = 'res://Scenes/Menu.tscn'
export var Game: String = "res://Scenes/Garden.tscn"

func _ready():
	$Box/Score.text = 'Score: '+str(Score.Score)
	
func _process(delta):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true

func _on_Retry_pressed():
	get_tree().paused = !get_tree().paused
	get_tree().change_scene(Game)

func _on_Menu_pressed():
	get_tree().paused = !get_tree().paused
	get_tree().change_scene(Menu)
