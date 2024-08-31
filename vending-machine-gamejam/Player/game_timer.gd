extends Control

@onready var timer: Timer = $Timer
@onready var label: Label = $MarginContainer/VBoxContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var game_time := int(timer.time_left)
	label.text = str(game_time)


func _on_timer_timeout() -> void:
	get_tree().quit()
