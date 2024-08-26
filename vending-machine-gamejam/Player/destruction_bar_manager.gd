extends Control


enum {LEVEL_ONE, LEVEL_TWO, LEVEL_THREE}
@onready var level = LEVEL_ONE

@export var destruction_add := 30
@export var decrease_bar := 3
@export var starting_bar_value := 80
@onready var current_bar_value := starting_bar_value:
	set(value):
		current_bar_value = value
		print(str(current_bar_value))
		if current_bar_value >= 100:
			level = LEVEL_TWO
		if current_bar_value >= 200:
			level = LEVEL_THREE
		else:
			level = LEVEL_ONE

@onready var destruction_level_label: Label = $CenterContainer/MarginContainer/VBoxContainer/TextureProgressBar/CenterContainer/DestructionLevelLabel
@onready var texture_progress_bar: TextureProgressBar = $CenterContainer/MarginContainer/VBoxContainer/TextureProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.destruction_up.connect(increase_destruction)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match level:
		LEVEL_ONE:
			first_level()
		LEVEL_TWO:
			second_level()
		LEVEL_THREE:
			third_level()
	# Decrease bar over time
	current_bar_value -= decrease_bar * delta
	# Update Bar Value
	texture_progress_bar.value = current_bar_value

func increase_destruction():
	current_bar_value += destruction_add

func first_level():
	texture_progress_bar.min_value = 0
	texture_progress_bar.max_value = 100
	destruction_level_label.text = str("Level 1")
	
func second_level():
	texture_progress_bar.min_value = 100
	texture_progress_bar.max_value = 200
	destruction_level_label.text = str("Level 2")
	print("Level Two")
	
func third_level():
	texture_progress_bar.min_value = 200
	texture_progress_bar.max_value = 300
	destruction_level_label.text = str("Level 3")
