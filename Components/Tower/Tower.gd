extends RigidBody

export var ignore:Array
export var dmg_per_hit = 1
export var GameOver: PackedScene
export var max_hp: int = 1500

func _ready():
	$Life.max_hp = max_hp

func game_over():
	var GameOverScreen = GameOver.instance()
	GameOverScreen.score = Score.Score
	add_child(GameOverScreen)

func _process(delta):
	game_over() if $Life.max_hp <= 0 else null

func _integrate_forces(state):
	for contact in state.get_contact_count():
		var collider = state.get_contact_collider_object(contact)
		if collider != null:
			$Life.take_damage(dmg_per_hit) if !(collider.name in ignore) else 0
