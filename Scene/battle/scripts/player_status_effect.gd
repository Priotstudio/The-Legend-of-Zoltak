extends Control


@onready var status_1: TextureRect = $"HBoxContainer/status 1"
@onready var status_2: TextureRect = $"HBoxContainer/status 2"
@onready var status_3: TextureRect = $"HBoxContainer/status 3"
@onready var status_4: TextureRect = $"HBoxContainer/status 4"
@onready var status_5: TextureRect = $"HBoxContainer/status 5"





# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	status_1.texture = null
	status_2.texture = null
	status_3.texture = null
	status_4.texture = null
	status_5.texture = null
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
