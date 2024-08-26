extends Area3D

@export var damage := 20

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("destructible"):
		area.smash(damage)
