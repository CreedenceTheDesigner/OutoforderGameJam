@tool
extends TextureRect

# Draw a circular reticle in the center of the screen.
func _draw() -> void:
	draw_circle(Vector2.ZERO, 3, Color.DIM_GRAY)
	draw_circle(Vector2.ZERO, 2, Color.WHITE_SMOKE)
