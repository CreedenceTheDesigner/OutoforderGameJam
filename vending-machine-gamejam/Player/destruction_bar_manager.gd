extends Control


enum {LEVEL_ONE, LEVEL_TWO, LEVEL_THREE}
@onready var level = LEVEL_ONE

@export var destruction_add := 300
@export var decrease_bar := .00003
@export var starting_bar_value := 800
@onready var level_one_bar_value := starting_bar_value:
	set(value):
		level_one_bar_value = value
		level_one_bar.value = level_one_bar_value
		if level_one_bar_value > 1000:
			var pass_value = level_one_bar_value - 1000
			level_two_bar_value = pass_value
			level = LEVEL_TWO
			level_one_bar_value = 1000

@onready var level_two_bar_value := 0:
	set(value):
		level_two_bar_value = value
		level_two_bar.value = level_two_bar_value
		if level_two_bar_value > 1000:
			var pass_value = level_two_bar_value - 1000
			level_three_bar_value = pass_value
			level = LEVEL_THREE
			level_two_bar_value = 1000

@onready var level_three_bar_value := 0:
	set(value):
		level_three_bar_value = value
		level_three_bar.value = level_three_bar_value

@onready var destruction_level_label: Label = %DestructionLevelLabel
@onready var level_one_bar: TextureProgressBar = $CenterContainer/MarginContainer/VBoxContainer/CenterContainer/LevelOneBar
@onready var level_two_bar: TextureProgressBar = $CenterContainer/MarginContainer/VBoxContainer/CenterContainer/LevelTwoBar
@onready var level_three_bar: TextureProgressBar = $CenterContainer/MarginContainer/VBoxContainer/CenterContainer/LevelThreeBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.destruction_up.connect(increase_destruction)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match level:
		LEVEL_ONE:
			first_level(delta)
		LEVEL_TWO:
			second_level(delta)
		LEVEL_THREE:
			third_level(delta)

func increase_destruction():
	match level:
		LEVEL_ONE:
			level_one_bar_value += destruction_add
		LEVEL_TWO:
			level_two_bar_value += destruction_add
		LEVEL_THREE:
			level_three_bar_value += destruction_add

func first_level(delta: float):
	destruction_level_label.text = str("Level 1")
	level_one_bar_value -= decrease_bar * delta * decrease_bar
	level_one_bar.visible = true
	level_two_bar.visible = false
	level_three_bar.visible = false
	
func second_level(delta: float):
	level_two_bar_value -= decrease_bar * delta * decrease_bar
	destruction_level_label.text = str("Level 2")
	print("Level Two")
	level_one_bar.visible = false
	level_two_bar.visible = true
	level_three_bar.visible = false
	if level_two_bar_value <= 0:
		level = LEVEL_ONE
	
func third_level(delta: float):
	level_three_bar_value -= decrease_bar * delta * decrease_bar
	destruction_level_label.text = str("Level 3")
	print ("Level Three")
	level_one_bar.visible = false
	level_two_bar.visible = false
	level_three_bar.visible = true
	if level_three_bar_value <= 0:
		level = LEVEL_TWO
