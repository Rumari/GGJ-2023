extends Spatial

export(NodePath) var music

func _ready():
# warning-ignore:return_value_discarded
	get_node(music).connect("bar", $"Enemy Controller", "on_attack")
