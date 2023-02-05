extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var brightness = $"Level 1".optimality
	$Camera.environment.ambient_light_energy = brightness
	$Camera.v_offset = brightness * rand_range(0, 0.5)
	$Camera.h_offset = brightness * rand_range(0, 0.5)
