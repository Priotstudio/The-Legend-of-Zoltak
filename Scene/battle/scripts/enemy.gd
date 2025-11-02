class_name Enemy extends Sprite2D

var text : String
var atk : int
var def : int
var dex : int
var current_dex : int
var current_atk : int
var current_def : int
var enemy_damage
var current_hp
var current_move : Action
var current_animation
var enemy_name

@export var enemy_data : Enemies_res

@onready var enemy_hp: TextureProgressBar = $"../enemy_hp"
@onready var player: Player = $"../player"
@onready var camera: Camera2D = $"../Camera2D"
@onready var battle_scene: Node2D = $"../.."


# Status effecs
var fire_status : Dictionary = {"active" : false, 'icon_on' : false, 'turn' : 0, 'duration' : 5, 
'texture' : 'res://Scene/battle/img/status_icon/fire_2.png', 'percentage' : 5.0}
var water_status : Dictionary = {"active" : false, 'icon_on' : false, 'turn' : 0, 'duration' : 4, 
'texture' : 'res://Scene/battle/img/status_icon/water.png', 'percentage' : 5.0}
var lightning_status : Dictionary = {"active" : false, 'icon_on' : false, 'turn' : 0, 'duration' : 5, 
'texture' : 'res://Scene/battle/img/status_icon/lightning.png', 'percentage' : 5.0}
var ice_status : Dictionary = {"active" : false, 'icon_on' : false, 'turn' : 0, 'duration' : 2, 
'texture' : 'res://Scene/battle/img/status_icon/ice.png', 'percentage' : 5.0}
var wind_status : Dictionary = {"active" : false, 'icon_on' : false, 'turn' : 0, 'duration' : 4, 
'texture' : 'res://Scene/battle/img/status_icon/wind.png', 'percentage' : 5.0}
var earth_status : Dictionary = {"active" : false, 'icon_on' : false, 'turn' : 0, 'duration' : 4, 
'texture' : 'res://Scene/battle/img/status_icon/earth.png', 'percentage' : 5.0}
var player_heal_status : Dictionary = {"active" : false, 'icon_on' : false, 'turn' : 0, 'duration' : 4, 
'texture' : 'res://Scene/battle/img/status_icon/heal.png', 'percentage' : 5.0, 'value' : 0}


var paralized : bool = false
var frozen : bool = false

@onready var enemy_status_effect: Control = $"../enemy_status_effect"

# status icon



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_enemy_data()
	
	SignalManager.enemy_damaged.connect(take_damage)
	enemy_name = enemy_data.name
	pass # Replace with function body.


func set_enemy_data () -> void:
	# set the HP
	enemy_hp.max_value = enemy_data.hp
	enemy_hp.value = enemy_hp.max_value
	current_hp = enemy_hp.value
	
	# set the stat
	atk = enemy_data.atk
	def = enemy_data.def
	dex = enemy_data.dex
	
	current_dex = dex # store original dex value
	current_atk = atk # store original atk power
	current_def = def # store original def status
	
func attack_player () -> void:
	# while true pick a random action 
	while true:
		var random_index = randi_range(0, enemy_data.actions.size() -1)
		var move = enemy_data.actions[random_index]
		current_move = move
	
		# If the current cooldown is 0 proceed if not pick another action
	
		if move.current_cooldown == 0:
			var move_name : String = move.action_name # move name
			var move_damage : int = move.action_attribute
	
			var damage = move_damage + (move_damage * atk / 100) # new damage with state modifer
		
			var crit_rate = int(move.critical_rate.trim_suffix("%"))
	
			var roll = randi_range(0,100)
			
			
			if roll < crit_rate: # if you lucky higher critical rate
				battle_scene.enemy_critical_hit = true
				damage *= 2
				
			# for the animation for the action
			var anim_name : String
			if random_index == 0:
				anim_name = "attack_1"
				current_animation = anim_name
			elif random_index == 1:
				anim_name = "attack_2"
				current_animation = anim_name
			elif random_index == 2:
				anim_name = "attack_3"
				current_animation = anim_name
			elif random_index == 3:
				anim_name = "attack_4"
				current_animation = anim_name
			elif random_index == 4:
				anim_name = "attack_5"
				current_animation = anim_name
				
			# set cooldown
			move.current_cooldown = move.cooldown
			
			# send signal
			var enemy_name = enemy_data.name
			SignalManager.enemy_attack_data.emit(enemy_name, move_name, damage, anim_name)
			break

func take_damage (damage : int) -> void:
	enemy_damage = damage
	pass

func _on_hitbox_area_entered(_area: Area2D) -> void:
	if battle_scene.player_critical_hit == true:
		GlobalGameSystem.hit_stop(0.05, 0.15) #perform hitstop
		battle_scene.player_critical_hit = false
		$criti.play("show")
		
	#GlobalGameSystem.hit_stop(0.05, 0.2) #perform hitstop
	camera.shake() # shake screen
	$AnimationPlayer.play("hit")
	$"../enemy_dmg hit".text = str (enemy_damage)
	$emeny_dmg.play("dmg")
	current_hp -= enemy_damage
	enemy_hp.value = current_hp
	
	await get_tree().create_timer(0.5).timeout
	player.set_battle_stat()
	
	# check set and control status effect
	
	pass # Replace with function body.


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if _anim_name == "death":
		$AnimationPlayer.stop()
		return
	if frozen == true:
		$AnimationPlayer.stop()
		return
		
	$AnimationPlayer.play("idle")
	$AnimationPlayer.seek(0.0, true)
	pass # Replace with function body.



func perform_action (damage, player_def_mod) -> void:
	
	## Physical modifer
	if current_move.action_type == "Physical":
		$AnimationPlayer.play(current_animation)
		damage = max(0, damage - int((player_def_mod / 2))) # player def deducts damage
		SignalManager.player_damaged.emit(damage)
		
		
	elif current_move.action_type == "Fire":
		pass
	
	elif current_move.action_type == "Water":
		pass
	
	elif current_move.action_type == "Lightling":
		pass
		
	elif current_move.action_type == "Ice":
		pass
		
	elif current_move.action_type == "Wind":
		pass
	
	elif current_move.action_type == "Earth":
		pass
		
	elif current_move.action_type == "Mystic":
		pass
		
	elif current_move.action_type == "Heal":
		pass
		
	elif current_move.action_type == "Defence":
		pass
	
	elif current_move.action_type == "Atk Down":
		pass
		
	elif current_move.action_type == "Def Breaker":
		pass
		
	elif current_move.action_type == "Psychic":
		pass
		
	elif current_move.action_type == "Hex":
		pass
		
	elif current_move.action_type == "Shadow":
		pass
		
	elif current_move.action_type == "Bleed":
		pass
		
	elif current_move.action_type == "Poison":
		pass


func status_effect () -> void:
	## FIRE
	if fire_status.active:
		text = "[center]" + enemy_name + ' has been ' + "[color=red]burned[/color][/center]"
		fire_status.turn += 1
		if fire_status.turn >= fire_status.duration:
			fire_status.active = false
			fire_status.icon_on = false
			fire_status.turn = 0
			clear_status_icon("fire_2.png")
	
		else:
			# deal damage, show status icon plus alart
			if fire_status.icon_on == true:
				var dmg = (fire_status.percentage / 100.0) * enemy_hp.max_value
				deal_status_dmg(dmg, "fire")
				check_if_you_dead()
				
			else:
				check_if_status_icon_is_available(fire_status.texture) # set texture icon
				fire_status.icon_on = true
				battle_scene.announcer_text(text)
				var dmg = (fire_status.percentage / 100) * enemy_hp.max_value
				deal_status_dmg(dmg, "fire")
				check_if_you_dead()
				
		await get_tree().create_timer(2.5).timeout
	
	## WATER
	if water_status.active:
		text = "[center]" + enemy_name  + "[color=blue] mobility[/color] has reduced[/center]"
		water_status.turn += 1
		if water_status.turn >= water_status.duration:
			water_status.active = false
			water_status.icon_on = false
			water_status.turn = 0
			clear_status_icon("water.png")
			dex = current_dex
			
		else:
			# Reduce speed and show status icon plus alart
			if water_status.icon_on == true:
				var dmg = (water_status.percentage / 45.0) * dex
				deal_status_dmg(dmg, "water")
				check_if_you_dead()
				
			else:
				check_if_status_icon_is_available(water_status.texture)
				water_status.icon_on = true
				battle_scene.announcer_text(text)
				var dmg = (water_status.percentage / 45.0) * dex
				deal_status_dmg(dmg, "water")
				check_if_you_dead()
	
		await get_tree().create_timer(2.5).timeout
	
	## LIGHTNING
	if lightning_status.active:
		text = "[center]" + enemy_name + ' has been ' + "[color=yellow]stunned[/color][/center]"
		lightning_status.turn += 1
		if lightning_status.turn >= lightning_status.duration:
			lightning_status.active = false
			lightning_status.icon_on = false
			lightning_status.turn = 0
			paralized = false
			battle_scene.status_active = false # allows status from main game check to be false
			clear_status_icon("lightning.png")
		
		else:
			if lightning_status.icon_on == true:
				# make enemy skip its turn
				check_if_you_dead()
			else:
				check_if_status_icon_is_available(lightning_status.texture)
				lightning_status.icon_on = true
				battle_scene.announcer_text(text)
				deal_status_dmg(0, "lightning")
				paralized = true
				check_if_you_dead()
				
		await get_tree().create_timer(2.5).timeout
	
	## ICE
	if ice_status.active:
		text = "[center]" + enemy_name + " has been[color=lightblue] frozen[/color] and can't move[/center]"
		ice_status.turn += 1
		if ice_status.turn >= ice_status.duration:
			$AnimationPlayer.play("idle")
			modulate = 'white'
			ice_status.active = false
			ice_status.icon_on = false
			ice_status.turn = 0
			frozen = false
			battle_scene.status_active = false # allows status from main game check to be false
			clear_status_icon("ice.png")
		
		else:
			if ice_status.icon_on == true:
				# make enemy skip its turn
				check_if_you_dead()
			else:
				check_if_status_icon_is_available(ice_status.texture)
				ice_status.icon_on = true
				battle_scene.announcer_text(text)
				deal_status_dmg(0, "ice")
				frozen = true
				check_if_you_dead()
				
	## WIND
	if wind_status.active:
		text = "[center]" + enemy_name + " is fighting against strong, pushing[color=lightgreen] wind[/color][/center]"
		wind_status.turn += 1
		if wind_status.turn >= wind_status.duration:
			wind_status.active = false
			wind_status.icon_on = false
			wind_status.turn = 0
			clear_status_icon("wind.png")
			dex = current_dex
		
		else:
			if wind_status.icon_on == true:
				# make enemy speed be reduced
				var dmg = (wind_status.percentage / 25.0) * dex
				deal_status_dmg(dmg, 'wind')
				check_if_you_dead()
			else:
				check_if_status_icon_is_available(wind_status.texture)
				wind_status.icon_on = true
				battle_scene.announcer_text(text)
				var dmg = (wind_status.percentage / 25.0) * dex
				deal_status_dmg(dmg, "wind")
				check_if_you_dead()
		await get_tree().create_timer(2.5).timeout
		
	## EARTH
	if earth_status.active:
		text = "[center]" + enemy_name + " defences have been pierced with [color=brown]rock [/color]shards[/center]"
		earth_status.turn += 1
		if earth_status.turn >= earth_status.duration:
			earth_status.active = false
			earth_status.icon_on = false
			earth_status.turn = 0
			clear_status_icon("earth.png")
			def = current_def
		
		else:
			if earth_status.icon_on == true:
				# make enemy def be reduced
				var dmg = (earth_status.percentage / 25.0) * def
				deal_status_dmg(dmg, 'earth')
				check_if_you_dead()
			else:
				check_if_status_icon_is_available(earth_status.texture)
				earth_status.icon_on = true
				battle_scene.announcer_text(text)
				var dmg = (earth_status.percentage / 25.0) * def
				deal_status_dmg(dmg, "earth")
				check_if_you_dead()
		await get_tree().create_timer(2.5).timeout
		
	





## All status effect func
func check_if_status_icon_is_available (texture_res) -> void:
	if enemy_status_effect.status_1.texture == null:
		enemy_status_effect.status_1.modulate.a = 0.0 # start transparent
		enemy_status_effect.status_1.texture = load( texture_res ) # load texture
		var tween = get_tree().create_tween()
		tween.tween_property(enemy_status_effect.status_1, "modulate:a", 1.0, 1.0) # fade in
	elif enemy_status_effect.status_2.texture == null:
		enemy_status_effect.status_2.modulate.a = 0.0
		enemy_status_effect.status_2.texture = load( texture_res )
		var tween = get_tree().create_tween()
		tween.tween_property(enemy_status_effect.status_2, "modulate:a", 1.0, 1.0)
	elif enemy_status_effect.status_3.texture == null:
		enemy_status_effect.status_3.modulate.a = 0.0
		enemy_status_effect.status_3.texture = load( texture_res )
		var tween = get_tree().create_tween()
		tween.tween_property(enemy_status_effect.status_3, "modulate:a", 1.0, 1.0)
	elif enemy_status_effect.status_4.texture == null:
		enemy_status_effect.status_4.modulate.a = 0.0
		enemy_status_effect.status_4.texture = load( texture_res )
		var tween = get_tree().create_tween()
		tween.tween_property(enemy_status_effect.status_4, "modulate:a", 1.0, 1.0)
	elif enemy_status_effect.status_5.texture == null:
		enemy_status_effect.status_5.modulate.a = 0.0
		enemy_status_effect.status_5.texture = load( texture_res )
		var tween = get_tree().create_tween()
		tween.tween_property(enemy_status_effect.status_5, "modulate:a", 1.0, 1.0)
		
		
func clear_status_icon (filename : String) -> void:
	var status_1 : TextureRect =  enemy_status_effect.status_1
	var status_2 : TextureRect =  enemy_status_effect.status_2
	var status_3 : TextureRect =  enemy_status_effect.status_3
	var status_4 : TextureRect =  enemy_status_effect.status_4
	var status_5 : TextureRect =  enemy_status_effect.status_5
	
	if status_1.texture and status_1.texture.resource_path.get_file() == filename:
		status_1.texture = null
	elif status_2.texture and status_2.texture.resource_path.get_file() == filename:
		status_2.texture = null
	elif status_3.texture and status_3.texture.resource_path.get_file() == filename:
		status_3.texture = null
	elif status_4.texture and status_4.texture.resource_path.get_file() == filename:
		status_4.texture = null
	elif status_5.texture and status_5.texture.resource_path.get_file() == filename:
		status_5.texture = null


func deal_status_dmg (dmg, effect : String) -> void :
	if effect == "fire":
		dmg = int(dmg)
		modulate = "red"
		$AnimationPlayer.play("hit")
		await get_tree().create_timer(0.4).timeout
		modulate = "white"
		$"../enemy_dmg hit".text = str (dmg)
		$emeny_dmg.play("dmg")
		current_hp -= dmg
		enemy_hp.value = current_hp
		
	elif effect == "water":
		dmg = int(dmg)
		modulate = 'blue'
		$AnimationPlayer.play("hit")
		await get_tree().create_timer(0.4).timeout
		modulate = "white"
		$"../enemy_dmg hit".text = str (dmg)
		$emeny_dmg.play("dmg")
		dex -= dmg
	
	elif effect == "lightning":
		dmg = int(dmg)
		modulate = 'yellow'
		$AnimationPlayer.play("hit")
		await get_tree().create_timer(0.4).timeout
		modulate = "white"
	
	elif effect == "ice":
		dmg = int(dmg)
		modulate = 'lightblue'
		$AnimationPlayer.play("hit")
		await get_tree().create_timer(0.5).timeout
		$AnimationPlayer.stop()
		
	elif effect == 'wind':
		dmg = int(dmg)
		modulate = 'lightgreen'
		$AnimationPlayer.play("hit")
		await get_tree().create_timer(0.4).timeout
		modulate = "white"
		$"../enemy_dmg hit".text = str (dmg)
		$emeny_dmg.play("dmg")
		dex -= dmg
		
	elif effect == 'earth':
		dmg = int (dmg)
		modulate = 'brown'
		$AnimationPlayer.play("hit")
		await get_tree().create_timer(0.4).timeout
		modulate = "white"
		$"../enemy_dmg hit".text = str (dmg)
		$emeny_dmg.play("dmg")
		def -= dmg
	
	elif effect == 'heal':
		dmg = int(dmg)
		$"../player_effects/heal".play("show") # play player effect heal
		print (player.current_hp)
		player.current_hp += dmg
		if player.current_hp > player.player_hp.max_value:
			player.current_hp = player.player_hp.max_value
			player.player_hp.value = player.current_hp
			return
		
		player.player_hp.value = player.current_hp


func check_if_you_dead () -> void:
	if current_hp <= 0:
		battle_scene.player_victory()
		## Switch scene to game over menu
		return
	pass
