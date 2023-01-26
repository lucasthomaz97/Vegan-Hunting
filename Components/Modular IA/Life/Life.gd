extends Sprite3D

export var points = 100
export var drop: Array = ["res://Components/Turret/Turret.tscn", "res://Scenes/BombPlant/BombPlant.tscn"]
export var drop_name: Array = ['Turret', 'Bomb']
export var seed_path: String = "res://Components/Seed/Seed.tscn"
export var bar: NodePath
onready var max_hp: int = 5

func _process(delta):
	get_node(bar).value = max_hp

func take_damage(qtt):
	max_hp -= qtt
	
func drop_item(obj):
	if rand_range(0,5) < 2:
		var i = load(seed_path)
		var Drop = i.instance()
		owner.add_child(Drop)
		var drop_i = int(rand_range(0, len(drop)))
		Drop.Plant = load(drop[drop_i])
		Drop.plant_name = drop_name[drop_i]
		Drop.global_translation = get_parent().global_translation
	obj.queue_free()

func destroyed(object:RigidBody):
	Score.Score += points if max_hp < 1 and get_parent().is_in_group('Enemy') else Score.Score
	drop_item(object)
