extends Spatial

export(NodePath) var music

signal attack

func _ready():
	get_node(music).connect("bar", $"Enemy Controller", "on_attack")
