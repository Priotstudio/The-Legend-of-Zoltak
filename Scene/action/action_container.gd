class_name ActionContainer extends VBoxContainer

const ACTION_SLOT = preload("res://Scene/action/action_slot.tscn")

@export var data : Player_Action

#Onready var
@onready var action_name: Label = $"../../action-info/name"
@onready var type_name: Label = $"../../action-info/type/type_name"
#@onready var element_name: Label = $"../../action-info/element/element_name"
@onready var damage: Label = $"../../action-info/damage/damage"
@onready var critical_rate: Label = $"../../action-info/critical rate/critical rate"
@onready var info: Label = $"../../action-info/info"
@onready var texture_rect: TextureRect = $"../../action-info/TextureRect"
#@onready var main: Main_game = $"../../../.."
@onready var cooldown: Label = $"../../action-info/cooldown/cooldown"


func _ready() -> void:
	SignalManager.show_action_info.connect(display_action_info)
	clear_action_slots()
	await get_tree().process_frame
	#main.load_defualt_actions()
	#update_slots()
	#add_action_to_slot()
	pass


func clear_action_slots () -> void:
	var padding = $PADDING
	
	for chid in self.get_children():
		if chid != padding:
			chid.queue_free()
			
			
func add_action_to_slot () -> void:
	var added_data = load("res://Scene/00_default_class_item_load/warrior/actions/slash.tres")
	data.add_items(added_data)
	update_slots()
	
func update_slots () -> void:
	var padding = $PADDING
	clear_action_slots()
	for s in data.actions:
		var new_slot = ACTION_SLOT.instantiate()
		add_child(new_slot)
		move_child(padding, get_child_count() - 1)
		new_slot.action_data = s


# Display the action info
func display_action_info () -> void:
	var slot_action = GlobalGameSystem.action_data_inv.action_data
	action_name.text = slot_action.action_name
	texture_rect.texture = slot_action.action_img
	type_name.text = slot_action.action_type
	damage.text = str(slot_action.action_attribute)
	critical_rate.text = slot_action.critical_rate
	cooldown.text = str(slot_action.cooldown)
	info.text = slot_action.action_info
	
	$"../../action-info".visible = true
	pass


func _on_exit_pressed() -> void:
	$"../..".visible = false
	pass # Replace with function body.
