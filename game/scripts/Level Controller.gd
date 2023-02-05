extends Spatial

export(NodePath) var music
export var optimality = 0.0

const BEAT_START = 17
const BEAT_PERIOD = 1

var time_between_beats
var last_beat
var time = 0.0

func _ready():
# warning-ignore:return_value_discarded
	get_node(music).connect("beat", self, "on_beat")

func _process(delta):
	time += delta

func on_beat(i):
	if last_beat != null:
		time_between_beats = time - last_beat
	last_beat = time
	
	print("beat %d" % i)	
	if i >= BEAT_START and (i - BEAT_START) % BEAT_PERIOD == 0:
		$BeatAnimator.playback_speed = 1.0 / (time_between_beats * BEAT_PERIOD)
		$BeatAnimator.play("Beat")
		print("attack on beat %d" % i)
		$"Enemy Controller".emit_signal("attack")

func _on_Player_died():
	get_tree().change_scene("res://scenes/Main Menu.tscn")
