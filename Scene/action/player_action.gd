class_name Player_Action extends Resource


@export var actions : Array[Actions]

func add_items (data : Action) -> void:
	actions.resize(actions.size() + 1)
	var new_action := Actions.new()
	new_action.action_data = data
	actions[actions.size() - 1] = new_action
	pass

func add_default_action (data1: Action, data2: Action, data3: Action, data4: Action, data5: Action) -> void:
	 # Step 1: grow the array by 5 slots
	actions.resize(0)
	var old_size := actions.size()
	actions.resize(old_size + 5)
	
	# Step 2: create 5 new Action resources
	var new_action1 := Actions.new()
	new_action1.action_data = data1
	actions[old_size + 0] = new_action1

	var new_action2 := Actions.new()
	new_action2.action_data = data2
	actions[old_size + 1] = new_action2

	var new_action3 := Actions.new()
	new_action3.action_data = data3
	actions[old_size + 2] = new_action3

	var new_action4 := Actions.new()
	new_action4.action_data = data4
	actions[old_size + 3] = new_action4

	var new_action5 := Actions.new()
	new_action5.action_data = data5
	actions[old_size + 4] = new_action5
	pass
	
