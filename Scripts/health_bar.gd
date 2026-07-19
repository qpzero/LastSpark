extends Control

@onready var player : Player = $"../../../Player"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if size.x != (85* get_child_count()) + (20*(get_child_count()-1)):
		size.x = (85* get_child_count()) + (20*(get_child_count()-1))
	updateHPBar()
	for i in get_child_count()-(player.HPMax-player.HP):
		var heart = get_child(i)
		heart.texture.region.position = Vector2(3300.0, 0.0) 
	for i in get_child_count()-player.HP:
		var heart = get_child(i+player.HP)
		heart.texture.region.position = Vector2(3000.0, 0.0) 

func updateHPBar() -> void:
	if get_child_count() != player.HPMax: 
		var a = get_child_count() #number of hearts before clearing
		for i in get_child_count(): #clear all hearts
			get_child(i).queue_free()
			  
		#currentHealthMax = player.HPMax
		for i in player.HPMax: #add correct amount of hearts
			var heart = TextureRect.new() #replace with texture rect when texture is ready
			add_child(heart)
		for i in get_child_count(): #set to the correct size and color
			var heart = get_child(i)
			#heart.size_flags_horizontal=Control.SIZE_EXPAND_FILL
			#heart.modulate = Color(1,0,0,1) 
			heart.texture = AtlasTexture.new()
			heart.texture.set_atlas(load("res://Assets/LastSparkSpriteSheet.png"))
			heart.texture.region.position = Vector2(3300.0, 0.0)
			heart.texture.region.size = Vector2(300.0, 300.0)
			heart.texture.filter_clip = true
			heart.expand_mode= 3
		#get heart count after new ones added (this includes the ones removed because they delete at the begining of next frame)
		var b = get_child_count() 
		size.x = (85*(b-a)) + (5*(b-a-1)) #set size of health bar to fit all hearts properly
		#print(player.HPMax, " ", b-a, " ",  (85*(b-a)) + (20*(b-a-1)) ) 
