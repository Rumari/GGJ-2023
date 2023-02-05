extends Control


func _on_Play_pressed():
	get_tree().change_scene("res://scenes/Main.tscn")


func _on_Options_pressed():
	print("You don't need any options changed")


func _on_Quit_pressed():
	get_tree().quit(0)
