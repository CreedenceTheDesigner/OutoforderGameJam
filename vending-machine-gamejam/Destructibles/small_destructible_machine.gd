extends Area3D

@export var max_health := 40

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var current_health := max_health:
	set(value):
		current_health = value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func smash(damage: int):
	animation_player.play("Hit")
	SignalManager.destruction_up.emit()
	current_health -= damage

func check_death():
	if current_health < 0:
		SignalManager.small_points.emit()
		queue_free()
		
