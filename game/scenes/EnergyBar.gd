extends TextureProgress


func _process(delta):
	self.value = Globals.player.energy
