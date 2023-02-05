extends Spatial

const Enemy = preload("res://scenes/Enemy.tscn")

signal win
signal attack

export(NodePath) var player
export var enemy_count = 5

var enemies = []

func _ready():
	connect("win", get_node(player), "win")
	
	# spawn enemies
	for _i in range(enemy_count):
		var enemy = Enemy.instance()
		enemy.set("player", "../" + player)
		enemy.connect("died", self, "enemy_died")
		enemy.connect("want_attack", self, "enemy_want_attack")
# warning-ignore:return_value_discarded
		connect("attack", enemy, "attack")
		enemy.translation.x = rand_range(-5.0, 5.0)
		enemy.translation.z = rand_range(-10.0, 0.0)
		enemies.push_back(enemy)
		add_child(enemy) 
	pick_attacker(enemies[0])

func enemy_died(enemy):
	enemies.remove(enemies.find(enemy))
	if len(enemies) == 0:
		emit_signal("win")
	else:
		pick_attacker(enemies[0])

func enemy_want_attack(enemy):
	pick_attacker(enemy)

func pick_attacker(attacker):
	for enemy in enemies:
		if enemy == attacker:
			enemy.set("stance", "attack")
		else:
			enemy.set("stance", "distance")
