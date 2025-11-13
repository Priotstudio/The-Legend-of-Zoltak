class_name Main_game extends Node2D

# Stats
@onready var atk: Label = $Control/stat/stat_value/ATK
@onready var def: Label = $Control/stat/stat_value/DEF
@onready var dex: Label = $Control/stat/stat_value/DEX
@onready var con: Label = $Control/stat/stat_value_2/CON
@onready var Int: Label = $Control/stat/stat_value_2/INT
@onready var wis: Label = $Control/stat/stat_value_2/WIS
@onready var cha: Label = $Control/stat/CHA

# Others
@onready var coin: Label = $Control/LittleScroll/coin
@onready var player_name: Label = $Control/profile/Banner/Label
@onready var page: VBoxContainer = $Control/Page
@onready var img: TextureRect = $Control/profile/Img_panel/img
@onready var hp_bar_solid: TextureProgressBar = $Control/HP/Hp_bar_solid
@onready var player_class: Sprite2D = $Control/HP/class
@onready var selected_inventory: Selected_Inventory_Ui = $Control/inventory_border/Control/selected_inventory
@onready var storage_inventory: Inventory_Ui = $Control/inventory_border/Control/GridContainer


@onready var action_container: ActionContainer = $"Control/action display/ScrollContainer/action container"


func _ready() -> void:
	SceneTransition.fade_in()
	load_player_save_file()
	
	 


func _process(_delta: float) -> void:
	pass



func load_player_save_file () -> void:
	var save = FileAccess.open("user://" + GlobalGameSystem.save_name, FileAccess.READ)
	
	# values from the save file
	var player_data = JSON.parse_string(save.get_as_text())["Player"]
	var player_save = JSON.parse_string(save.get_as_text())
	save.close()
	
	# Load current page if one is present
	########
	
	
	# Set those data for the game
	atk.text = str(player_data["Atk"])
	def.text = str(player_data["Def"])
	dex.text = str(player_data["Dex"])
	con.text = str(player_data['Con'])
	Int.text = str(player_data["Int"])
	wis.text = str(player_data["Wis"])
	cha.text = str(player_data["Cha"])
	save_stat_for_battle()
	
	page.current_coin = player_data["currency"]
	GlobalGameSystem.player_coin = player_data["currency"]
	coin.text = str(page.current_coin)
	
	player_name.text = player_data["Name"]
	img.texture = load(player_data["Apperance"])
	
	page.current_hp = player_data["Hp"]
	hp_bar_solid.value = page.current_hp
	GlobalGameSystem.player_hp = page.current_hp
	
	# change player class texture
	#if player_data["Class"] == "Warrior":
		#player_class.texture = load("res://Asset/img/other/warrior.png")
	#else:
		#player_class.texture = null
		
	# save class for shop items
	GlobalGameSystem.player_class = player_data["Class"]
		
	# Load actions if you already have one or use default
	#####
	if !player_save["Action"].is_empty():
		# load player actions from save file
		pass
	else:
		var data1 = load("res://Scene/00_default_class_item_load/warrior/actions/Cleave.tres")
		var data2 = load ("res://Scene/00_default_class_item_load/warrior/actions/Power_Slash.tres")
		var data3 = load ("res://Scene/00_default_class_item_load/warrior/actions/Rage_Blow.tres")
		var data4 = load ("res://Scene/00_default_class_item_load/warrior/actions/slash.tres")
		var data5 = load("res://Scene/00_default_class_item_load/warrior/actions/Thrust.tres")
	
		# for warriors
		if player_data["Class"] == "Warrior":
			
			if action_container.data.actions.size() == 0:
				action_container.data.add_default_action(data1,data2,data3,data4,data5)
				action_container.update_slots()
			else:
				action_container.clear_action_slots()
				action_container.data.add_default_action(data1,data2,data3,data4,data5)
				action_container.update_slots()
			
		# for defenders
		elif player_data["Class"] == "Defender":
			data1 = load ("res://Scene/00_default_class_item_load/defender/actions/bash.tres")
			data2 = load ("res://Scene/00_default_class_item_load/defender/actions/heal.tres")
			data3 = load ("res://Scene/00_default_class_item_load/defender/actions/mending_bulwark.tres")
			data4 = load ("res://Scene/00_default_class_item_load/defender/actions/shield_slam.tres")
			data5 = load ("res://Scene/00_default_class_item_load/defender/actions/skull_cracker.tres")
			if action_container.data.actions.size() == 0:
				action_container.data.add_default_action(data1,data2,data3,data4,data5)
				action_container.update_slots()
			else:
				action_container.clear_action_slots()
				action_container.data.add_default_action(data1,data2,data3,data4,data5)
				action_container.update_slots()
	
		# for mages
		elif player_data["Class"] == "Mage":
			data1 = load ("res://Scene/00_default_class_item_load/mages/actions/fireball.tres")
			data2 = load ("res://Scene/00_default_class_item_load/mages/actions/gale_shot.tres")
			data3 = load ("res://Scene/00_default_class_item_load/mages/actions/lighting_blot.tres")
			data4 = load ("res://Scene/00_default_class_item_load/mages/actions/meteor_strike.tres")
			data5 = load ("res://Scene/00_default_class_item_load/mages/actions/water_vortex.tres")
			if action_container.data.actions.size() == 0:
				action_container.data.add_default_action(data1,data2,data3,data4,data5)
				action_container.update_slots()
			else:
				action_container.clear_action_slots()
				action_container.data.add_default_action(data1,data2,data3,data4,data5)
				action_container.update_slots()
			
		# for summoners
		elif player_data ["Class"] == "Summoner":
			data1 = load ("res://Scene/00_default_class_item_load/summoner/actions/astral_barrage.tres")
			data2 = load ("res://Scene/00_default_class_item_load/summoner/actions/mental_shard.tres")
			data3 = load ("res://Scene/00_default_class_item_load/summoner/actions/mind_spike.tres")
			data4 = load ("res://Scene/00_default_class_item_load/summoner/actions/psychic_wave.tres")
			data5 = load ("res://Scene/00_default_class_item_load/summoner/actions/soul_hound.tres")
			if action_container.data.actions.size() == 0:
				action_container.data.add_default_action(data1,data2,data3,data4,data5)
				action_container.update_slots()
			else:
				action_container.clear_action_slots()
				action_container.data.add_default_action(data1,data2,data3,data4,data5)
				action_container.update_slots()
			
		# for rangers
		elif player_data["Class"] == "Ranger":
			data1 = load ("res://Scene/00_default_class_item_load/ranger/action/armor_pierce.tres")
			data2 = load ("res://Scene/00_default_class_item_load/ranger/action/barrage_shot.tres")
			data3 = load ("res://Scene/00_default_class_item_load/ranger/action/charge_shot.tres")
			data4 = load ("res://Scene/00_default_class_item_load/ranger/action/quick_shot.tres")
			data5 = load ("res://Scene/00_default_class_item_load/ranger/action/stormragee.tres")
			if action_container.data.actions.size() == 0:
				action_container.data.add_default_action(data1,data2,data3,data4,data5)
				action_container.update_slots()
			else:
				action_container.clear_action_slots()
				action_container.data.add_default_action(data1,data2,data3,data4,data5)
				action_container.update_slots()
			
		# for rouges
		elif  player_data["Class"] == "Rogue":
			data1 = load ("res://Scene/00_default_class_item_load/rogue/actions/bomb.tres")
			data2 = load ("res://Scene/00_default_class_item_load/rogue/actions/execution.tres")
			data3 = load ("res://Scene/00_default_class_item_load/rogue/actions/hex_strike.tres")
			data4 = load ("res://Scene/00_default_class_item_load/rogue/actions/poison_venin.tres")
			data5 = load ("res://Scene/00_default_class_item_load/rogue/actions/quick_slash.tres")
			if action_container.data.actions.size() == 0:
				action_container.data.add_default_action(data1,data2,data3,data4,data5)
				action_container.update_slots()
			else:
				action_container.clear_action_slots()
				action_container.data.add_default_action(data1,data2,data3,data4,data5)
				action_container.update_slots()
				
	# Load journals if you have
	#####
	
	# Load inventory if you have
	# check if main inventory is empty from the save file
	
	if player_save["Main_Inventory"].is_empty():
		var inventory = selected_inventory.data.slots
		var headgear = load ("res://Scene/00_default_class_item_load/all/Bronze_helmet.tres")
		var chestplate = load ("res://Scene/00_default_class_item_load/all/brown cape.tres")
		var leggings = load ("res://Scene/00_default_class_item_load/all/Leather_boots.tres")
		var relics = load ("res://Scene/00_default_class_item_load/all/Bronze_ring.tres")
	
		var slot_1 := Slot_data.new()
		slot_1.item_data = headgear
		inventory[0] = slot_1
	
		var slot_2 := Slot_data.new()
		slot_2.item_data = chestplate
		inventory[1] = slot_2
	
		var slot_3 := Slot_data.new()
		slot_3.item_data = relics
		inventory[2] = slot_3
	
		var slot_4 := Slot_data.new()
		slot_4.item_data = leggings
		inventory[3] = slot_4
	
		var slot_5 := Slot_data.new()
	
		# Set conditions for weapons depending on your class
		var warrior = load ("res://Scene/00_default_class_item_load/all/long_sword.tres")
		var defender = load ("res://Scene/00_default_class_item_load/all/wooden_shield.tres")
		var summoner = load ("res://Scene/00_default_class_item_load/all/summoning_staff.tres")
		var mage = load ("res://Scene/00_default_class_item_load/all/mage_staff.tres")
		var ranger = load ("res://Scene/00_default_class_item_load/all/wodden_bow.tres")
		var rogue = load ("res://Scene/00_default_class_item_load/all/dagger.tres")
	
		if player_data["Class"] == "Warrior":
			slot_5.item_data = warrior
			inventory[4] = slot_5
		elif  player_data["Class"] == "Defender":
			slot_5.item_data = defender
			inventory[4] = slot_5
		elif  player_data["Class"] == "Summoner":
			slot_5.item_data = summoner
			inventory[4] = slot_5
		elif player_data["Class"] == "Mage":
			slot_5.item_data = mage
			inventory[4] = slot_5
		elif player_data["Class"] == "Ranger":
			slot_5.item_data = ranger
			inventory[4] = slot_5
		elif player_data["Class"] == "Rogue":
			slot_5.item_data = rogue
			inventory[4] = slot_5
	else:
		# load the inventory item from save data for both main and storage
		pass
	####
	
	
	# Load achievements if you have
	####
	pass


func save_player_data () -> void:
	pass
	
func save_stat_for_battle () -> void:
	GlobalGameSystem.player_atk = int(atk.text)
	GlobalGameSystem.player_def = int(def.text)
	GlobalGameSystem.player_dex = int(dex.text)
	GlobalGameSystem.player_int = int(Int.text)
	GlobalGameSystem.player_con = int(con.text)
	GlobalGameSystem.player_wis = int(wis.text)
	pass
