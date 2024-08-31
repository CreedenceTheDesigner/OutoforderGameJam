extends Control

@onready var points := 0:
	set(value):
		points = value
		
enum {SINGLE, DOUBLE, TRIPLE}

@onready var multiplier_state := SINGLE:
	set(value):
		multiplier_state = value
		match multiplier_state:
			SINGLE:
				multiplier = 1
			DOUBLE:
				multiplier = 2
			TRIPLE:
				multiplier = 3
		
@onready var multiplier := 1

@onready var texture_progress_bar: TextureProgressBar = $MarginContainer/VBoxContainer/TextureProgressBar
@onready var label: Label = $MarginContainer/VBoxContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.small_points.connect(small_points)
	SignalManager.medium_points.connect(medium_points)
	SignalManager.large_points.connect(large_points)
	SignalManager.extra_large_points.connect(extra_large_points)
	SignalManager.destruction_one.connect(single_multiplier)
	SignalManager.destruction_two.connect(double_multiplier)
	SignalManager.destruction_three.connect(triple_multiplier)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func small_points():
	points += 500 * multiplier
	label.text = str(points)
	texture_progress_bar.value += points 
	
func medium_points():
	points += 1000 * multiplier
	label.text = str(points)
	texture_progress_bar.value += points 
	
func large_points():
	points += 2000 * multiplier
	label.text = str(points)
	texture_progress_bar.value += points 
	
func extra_large_points():
	points += 4000 * multiplier
	label.text = str(points)
	texture_progress_bar.value += points 

func single_multiplier():
	multiplier_state = SINGLE
	
func double_multiplier():
	multiplier_state = DOUBLE
	
func triple_multiplier():
	multiplier_state = TRIPLE
