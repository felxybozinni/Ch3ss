extends AnimationPlayer

@onready var animation_player: AnimationPlayer = $"."
@onready var animated_sprite_2d: AnimatedSprite2D = $".."
func _ready():
	animated_sprite_2d.play("default")
