extends Area3D

@export var damage := 20
@export var destruction_particles: PackedScene

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("destructible"):
		area.smash(damage)
		var smash = destruction_particles.instantiate()
		add_child(smash)
		smash.global_position = area.global_position
		self.monitoring = false
