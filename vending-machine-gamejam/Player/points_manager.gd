extends Control

@onready var points := 0:
	set(value):
		points = value

@onready var texture_progress_bar: TextureProgressBar = $MarginContainer/VBoxContainer/TextureProgressBar
@onready var label: Label = $MarginContainer/VBoxContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.small_points.connect(small_points)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func small_points():
	points += 50
	label.text = str(points)
	texture_progress_bar.value += points
