extends CanvasLayer


@onready var animation_player: AnimationPlayer = $AnimationPlayer

func fade_in () -> void:
	animation_player.play("fade_in")
	
	

func fade_out () -> void:
	animation_player.play("fade_out")
	
func battle_open () -> void:
	animation_player.play("battle_open")
	
func battle_close () -> void:
	animation_player.play("battle_close")
