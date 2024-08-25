extends Camera3D

## The node to align the smooth camera with
@export var target: Node3D
## Control the speed the SmoothCamera aligns with the target.
@export var speed: float = 30.0
	
func _process(delta: float) -> void:
	global_transform = global_transform.interpolate_with(
		target.global_transform, 
		clamp(speed * delta, 0.0, 1.0)
		)
	global_position = target.global_position
