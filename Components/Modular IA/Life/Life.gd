extends Sprite3D

export var points = 100
export var drop: Array = ["res://Components/Turret/Turret.tscn", "res://Scenes/BombPlant/BombPlant.tscn"]
export var drop_name: Array = ['Turret', 'Bomb']
export var seed_path: String = "res://Components/Seed/Seed.tscn"

func take_damage(qtt):
	$Render/ProgressBar.value -= qtt
	
func drop_item(obj):
	if rand_range(0,5) < 2:
		var i = load(seed_path)
		var Drop = i.instance()
		var drop_i = int(rand_range(0, len(drop)))
		Drop.Plant = load(drop[drop_i])
		Drop.plant_name = drop_name[drop_i]
		Drop.global_translation = get_parent().global_translation
		get_parent().get_parent().add_child(Drop)
	obj.queue_free()

func destroyed(object:RigidBody):
	Score.Score += points if $Render/ProgressBar.value < 1 and get_parent().is_in_group('Enemy') else Score.Score
	drop_item(object)
