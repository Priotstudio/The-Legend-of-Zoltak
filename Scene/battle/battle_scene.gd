class_name Battle_Scene extends Node2D

var turn_counter : int = 0
var player_roll
var enemy_roll
var text
var battling : bool = false
var current_action : Actions
var enemy_take_turn : bool = false
var player_take_turn : bool = false

# modifers
var player_atk_mod 
var player_def_mod
var player_dex_mod
var player_critical_hit : bool = false
var enemy_critical_hit : bool = false


@onready var player: Player = $Control/player
@onready var enemy: Enemy = $Control/enemy
@onready var announcer: RichTextLabel = $"Control/top info/announcer"
@onready var timer: Timer = $"Control/top info/Timer"
@onready var enemy_animation: AnimationPlayer = $Control/enemy/AnimationPlayer
@onready var player_dmg_hit: Label = $"Control/player/dmg hit"
@onready var player_dmg_info: AnimationPlayer = $Control/player/dmg_info
@onready var attack: TextureButton = $Control/attack
@onready var inventory: TextureButton = $Control/inventory
@onready var battle_surge: TextureButton = $Control/battle_surge
@onready var action_container: ActionContainer = $"Control/action display/ScrollContainer/action container"
@onready var results: CanvasLayer = $results

@onready var player_inv: Inventory_Ui = $Control/inventory_border/Control/GridContainer

# info board
@onready var item_icon: TextureRect = $Control/inventory_border/Control/Info_board/item_icon
@onready var item_name: Label = $Control/inventory_border/Control/Info_board/name
@onready var item_attribute: Label = $Control/inventory_border/Control/Info_board/attribute
@onready var item_type: Label = $Control/inventory_border/Control/Info_board/item_type
@onready var item_discription: Label = $Control/inventory_border/Control/Info_board/discription
@onready var info_board: Sprite2D = $Control/inventory_border/Control/Info_board
@onready var buff_texture: TextureRect = $"Control/inventory_border/Control/Info_board/buff texture"
@onready var buff_texture_2: TextureRect = $"Control/inventory_border/Control/Info_board/buff texture2"
@onready var notification: CanvasLayer = $Control/notification

@onready var inv_action: TextureButton = $Control/inventory_border/Control/inv_action
@onready var full_stat_anim: AnimationPlayer = $Control/full_stats_info/full_stat_anim

## var for full stats
var stat_conter : int = 0
@onready var full_stats: TextureButton = $Control/full_stats_info/full_stats

@onready var hp: Label = $Control/full_stats_info/Panel/stat/hp
@onready var atk: Label = $Control/full_stats_info/Panel/stat/atk
@onready var def: Label = $Control/full_stats_info/Panel/stat/def
@onready var dex: Label = $Control/full_stats_info/Panel/stat/dex
@onready var con: Label = $Control/full_stats_info/Panel/stat2/con

@onready var hp__: Label = $Control/full_stats_info/Panel/stat/hp__
@onready var atk__: Label = $Control/full_stats_info/Panel/stat/atk__
@onready var def__: Label = $Control/full_stats_info/Panel/stat/def__
@onready var dex__: Label = $Control/full_stats_info/Panel/stat/dex__
@onready var con__: Label = $Control/full_stats_info/Panel/stat2/con__

@onready var wep_dmg: Label = $Control/full_stats_info/Panel/stat2/wep_dmg
@onready var arm_def: Label = $Control/full_stats_info/Panel/stat2/arm_def
@onready var itm_tp: Label = $Control/full_stats_info/Panel/stat2/itm_tp
@onready var crit: Label = $Control/full_stats_info/Panel/stat2/crit

## Battle gauge
@onready var battle_gauge: Sprite2D = $Control/battle_gauge



# signal
signal show
signal hide

## Player effects
@onready var heal: AnimatedSprite2D = $Control/player_effects/heal

## for status
var status_active := false



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_player_actions()
	load_player_inv()
	
	
	text = "[center]YOU ENCOINTERED THE [color=red]RAGING KNIGHT[/color][/center]"
	enable_button()
	SceneTransition.fade_in()
	announcer_text(text)
	randomize()
	SignalManager.player_attack_data.connect(player_attack)
	SignalManager.enemy_attack_data.connect(enemy_attack)
	SignalManager.player_attack.connect(show_and_store_attack)
	SignalManager.show_item_info_board.connect(show_item_info)
	
	## for full stats display
	player.show_full_stat(hp, atk, def, dex, con)
	player.show_full_mod_stat(hp__, atk__, def__, dex__, con__, wep_dmg, arm_def, itm_tp, crit)
	

func disable_button () -> void:
	attack.disabled = true
	inventory.disabled = true
	battle_surge.disabled = true
	full_stats.disabled = true

func enable_button () -> void:
	attack.disabled = false
	inventory.disabled = false
	battle_surge.disabled = false
	full_stats.disabled = false

func _on_attack_pressed() -> void:
	
	if battling == true:
		disable_button()
	else:
		enable_button()
		$"Control/action display".visible = true
	pass # Replace with function body.


func _on_roll_pressed() -> void:
	battling = true
	$overlay/roll.visible = false
	$overlay/Sprite2D/AnimationPlayer.play("roll_animation")
	await  get_tree().create_timer(1.2).timeout
	
	# roll
	player_roll = randi_range(1,20)
	player_roll_modifer(player_roll)
	enemy_roll = randi_range(1,20)
	
	$overlay/Sprite2D/counter.text = str(player_roll)
	await get_tree().create_timer(1.5).timeout
	$overlay.visible = false
	
	#reset
	$overlay/roll.visible = true
	$overlay/Sprite2D/counter.text = str(20)
	
	# if the full start panel is showing hide it
	if $Control/full_stats_info/Panel.visible == true:
		full_stat_anim.play("hide")
	

	start_battle()
	
	
func player_roll_modifer (roll : int) -> void:
	player_atk_mod = int(player.final_atk * (0.5 + (roll/20.0)))
	
	var critical_rate = int(current_action.action_data.critical_rate.trim_suffix("%"))
	var chance = randi_range(0,100)
	if chance < critical_rate: ## For critical hits
		player_critical_hit = true
		player_atk_mod *= 2
		
	player_atk_mod += current_action.action_data.action_attribute + player.weapon_atk
	
	player_def_mod = int(player.final_def * (0.5 + (roll/20.0))) + player.armor_def
	player_dex_mod = int(player.final_dex * (0.5 + (roll/20.0)))
	pass
	
	player.set_roll_stat_view(player_atk_mod,player_def_mod,player_def_mod)
	
	
	
func start_battle () -> void:
	
	var p_speed = player_roll + player_dex_mod
	var e_speed = enemy_roll + enemy.dex
	
	if e_speed > p_speed:
		enemy.attack_player()
		enemy_take_turn = true
	else:
		player_attack()
		player_take_turn = true



func enemy_attack (enemy_name, move_name, damage, anim_name) -> void:
	battling = true
	if battling == true:
		disable_button()
		
	await get_tree().create_timer(1).timeout
	
	## Some status checks will be added here
	await enemy_status_check(enemy_name)
	if status_active == true:
		print ('status active')
		if player_take_turn == true:
			enemy_process()
		return
	
	
	text = "[center]" + "[color=red]"+ enemy_name + "[/color]" + " USED " + move_name + "[/center]"
	announcer_text(text)
	await get_tree().create_timer(2).timeout
	
	## Perform action type
	await enemy.perform_action(damage, player_def_mod)
	
	
	await get_tree().create_timer(0.5).timeout
	# Check if player has no hp left
	if player.current_hp <= 0:
		game_over()
		## Switch scene to game over menu
		return
		
	
	if player_take_turn == false:
		await get_tree().create_timer(1.5).timeout
		text = "[center]You took damage, now it's your turn[/center]"
		announcer_text(text)
		player_attack()
		return
	
	
	enemy_process()
	
		

### for modularity
func enemy_process () -> void:
	## increase counter
	turn_counter += 1
	if battle_gauge.frame == 0:
		pass
	else:
		battle_gauge.frame -= 1
		_battle_gauge()
	
	
	
	
	player_take_turn = false
	text = "[center]The air grew thick filled with a strange ominous aura[/center]" # announer for turn end
	await announcer_text(text)
	
	await get_tree().create_timer(2).timeout
	enemy.status_effect() # check for status effect
	player.status_effect() # check for player status
	battling = false
	
	
	if battling == false:
		enable_button()
		
func enemy_status_check (enemy_name) -> void:
	## Some status checks will be added here
	if enemy.paralized == true:
		enemy.deal_status_dmg(0, 'lightning')
		text = "[center]" + "[color=red]" + enemy_name + "[/color]"+ " is paralazied and can't move[/center]"
		announcer_text(text)
		await get_tree().create_timer(3).timeout
		if player_take_turn == false:
			enemy_take_turn = true
			await get_tree().create_timer(1.5).timeout
			text = "[center]You took the advantage and prepared to attack[/center]"
			announcer_text(text)
			await get_tree().create_timer(1.5).timeout
			player_attack()
		#else:
			#enemy_process() # to contunie with enemy battle logic
		status_active = true
	
	if enemy.frozen == true:
		enemy.deal_status_dmg(0, 'ice')
		text = "[center]" + "[color=red]" + enemy_name + "[/color]"+ " is frozen and can't move[/center]"
		announcer_text(text)
		await get_tree().create_timer(3).timeout
		if player_take_turn == false:
			enemy_take_turn = true
			await get_tree().create_timer(1.5).timeout
			text = "[center]You took the advantage and prepared to attack[/center]"
			announcer_text(text)
			await get_tree().create_timer(1.5).timeout
			player_attack()
		#else:
			#enemy_process()
		status_active = true
		
	
	






func player_attack() -> void:
	battling = true
	if battling == true:
		disable_button()
		
	var action : Action = current_action.action_data
	var damage = player_atk_mod
	
	await get_tree().create_timer(2).timeout
	text = "[center]You used " +"[color=green]" + action.action_name + "[/color][/center]"
	announcer_text(text)
	await get_tree().create_timer(2).timeout
	
	## This is where the move type gets checked to perform it properties
	## Eg if it a stun or poisen type move it does it work rather than just dmg
	await player.perform_action (damage, action)
	await get_tree().create_timer(3).timeout
	
	
	## Check if enemy has no hp left
	if enemy.current_hp <= 0:
		player_victory()
		## Switch scene to game over menu
		return
	
	if enemy_take_turn == false: # check if enemy hasn't attacked
		player_take_turn = true
		await get_tree().create_timer(1).timeout
		text = "[center]Opponent takes their turn[/center]"
		announcer_text(text)
		await get_tree().create_timer(1).timeout
		enemy.attack_player()
		return
	else:
		
		## increase counter
		turn_counter += 1
		if battle_gauge.frame == 0:
			pass
		else:
			battle_gauge.frame -= 1
			_battle_gauge()
		
		text = "[center]The air grew thick filled with a strange ominous aura[/center]" # after turn text
		announcer_text(text)
		
		enemy.status_effect() # check for status effect
		player.status_effect() # check for player effect
		battling = false
		if battling == false:
			enable_button()
	
		enemy_take_turn = false




func announcer_text (text) -> void:
	announcer.visible_characters = 0
	announcer.text = text
	timer.start()
	
func _on_timer_timeout() -> void:
	announcer.visible_characters += 1
	
	if announcer.text.length() == announcer.visible_characters:
		timer.stop()
		


# for action
func _on_exit_pressed() -> void:
	$"Control/action display".visible = false
	pass # Replace with function body.



func load_player_actions () -> void:
	var actions_container = action_container.data.actions
	actions_container.clear()
	actions_container.resize(GlobalGameSystem.current_player_actions.size())
	for i in range(GlobalGameSystem.current_player_actions.size()):
		actions_container[i] = GlobalGameSystem.current_player_actions[i]
		action_container.update_slots()


# for using attacks 
func show_and_store_attack (action_data) -> void:
	$"Control/action display/use_action".visible = true # make the use button visible 
	current_action = action_data # store the action selected in a var


func _on_use_action_pressed() -> void:
	$"Control/action display".visible = false
	$"Control/action display/use_action".visible = false
	$overlay.visible = true
	pass # Replace with function body.
	


# for inventory
func load_player_inv () -> void:
	var inv_container = player_inv.data.slots
	var storage = GlobalGameSystem.storage_inv
	
	## Safety, ensure the inv has 16 elements
	if inv_container.size() < 16:
		inv_container.resize(16)
	elif inv_container.size() > 16:
		inv_container = inv_container.slice(0, 16)
	
	## fill inventory with consumable items from global
	for i in range(16):
		if i < storage.size():
			inv_container[i] = storage[i]
		else:
			inv_container[i] = null
			
	## Update UI
	player_inv.update_inventory()



func show_item_info () -> void:
	if GlobalGameSystem.button_data_inv == null or GlobalGameSystem.button_data_inv.item_data == null:
		info_board.visible = false
		return
	
	item_icon.texture = GlobalGameSystem.button_data_inv.item_data.texture
	buff_texture.texture = GlobalGameSystem.button_data_inv.item_data.buff_texture
	buff_texture_2.texture = GlobalGameSystem.button_data_inv.item_data.buff_texture2
	item_name.text = GlobalGameSystem.button_data_inv.item_data.name
	item_type.text = GlobalGameSystem.button_data_inv.item_data.item_type
	item_discription.text = GlobalGameSystem.button_data_inv.item_data.discription
	item_attribute.text = (GlobalGameSystem.button_data_inv.item_data.attribute + " " + "+" + str(GlobalGameSystem.button_data_inv.item_data.attribute_value))
	
	
	info_board.visible = true
	
	if GlobalGameSystem.button_data_inv.item_data.item_type != "Consumable" or GlobalGameSystem.button_data_inv == null:
		inv_action.visible = false
	else:
		inv_action.visible = true

func _on_exit_info_pressed() -> void:
	info_board.visible = false
	pass # Replace with function body





func _on_inventory_pressed() -> void:
	$Control/inventory_border/Control/AnimationPlayer.play("show")
	show.emit()
	pass # Replace with function body.


func _on_exit_inv_pressed() -> void:
	$Control/inventory_border/Control/AnimationPlayer.play("close")
	info_board.visible = false
	inv_action.visible = false
	pass # Replace with function body.


func _on_inv_action_pressed() -> void:
	use_item()
	$Control/inventory_border/Control/AnimationPlayer.play("close")
	info_board.visible = false
	inv_action.visible = false
	pass # Replace with function body.



# function to use item
func use_item () -> void:
	var item = GlobalGameSystem.button_data_inv.item_data
	
	# For healing
	if item.attribute == "Heal":
		if player.current_hp == player.player_hp.max_value:
			show_notification() # Show alart that hp is full already
		elif player.current_hp < player.player_hp.max_value:
			text = "[center]You used " + item.name + "[/center]"
			announcer_text(text)
			heal.modulate = "4df936" # change color to green
			heal.visible = true
			heal.play("show") # play heal animation
			player.modulate_player(100,100,100,1) # flash player white
			await get_tree().create_timer(0.3).timeout # wait 0.3 sec
			player.modulate_player(1,1,1,1) # return player to normal
			
			player.set_hp(item.attribute_value) # set player hp
			remove_item_slot() # remove the slot
			pass # increase hp and update the value
		




func remove_item_slot () -> void: ## Remove selected item from the inventory
	## Remove from storage but keep the slot
	var slot = GlobalGameSystem.button_data_inv
	var index = player_inv.data.slots.find(slot)
	if index != -1:
		player_inv.data.slots[index] = null
		
	player_inv.update_inventory()
	info_board.visible = false
	pass



func show_notification () -> void:
	notification.visible = true
	$Control/notification/Control/TextureRect/Label.text = "HP is already at maximum"
	$Control/notification/Control/AnimationPlayer.play("show")

func _on_exit_n_pressed() -> void:
	notification.visible = false
	pass # Replace with function body.



# function for battle gauge
func _battle_gauge () -> void:
	if battle_gauge.frame == 0:
		$Control/battle_gauge/AnimationPlayer.play("ready")
		
	pass






# Game over function
func game_over () -> void:
	player.stop()
	player.modulate = "0000007f"
	$results/result_text.text = "DEFEAT"
	results.visible = true
		
	await  get_tree().create_timer(2).timeout
	results.visible = false
	SceneTransition.battle_open()
	await get_tree().create_timer(1.5).timeout
		
	LevelManager.load_new_level = "res://Scene/game_over.tscn"
	LevelManager.load_level()
	pass

# victory function
func player_victory () -> void:
	GlobalGameSystem.results = "victory"
	GlobalGameSystem.player_hp = player.current_hp

	enemy_animation.play("death")
	await get_tree().create_timer(0.84).timeout
	enemy.visible = false
	$results/result_text.text = "VICTORY"
	results.visible = true
	
	await  get_tree().create_timer(2).timeout
	results.visible = false
	SceneTransition.battle_open()
	await get_tree().create_timer(1.5).timeout
	SignalManager.battle_won.emit()
	pass



## To show additional stats information through button
func _on_full_stats_pressed() -> void:
	stat_conter += 1
	if stat_conter == 1:
		full_stat_anim.play("show")
	elif stat_conter > 1:
		full_stat_anim.play("hide")
		stat_conter = 0
	pass # Replace with function body.
