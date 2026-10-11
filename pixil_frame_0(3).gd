extends Sprite2D

@onready var label: Label = $"../../Label"


func _ready() -> void:
	texture.get_width()
	label.text = str(texture.get_width())
