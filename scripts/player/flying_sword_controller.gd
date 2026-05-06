extends Node2D

var flying_sword_scene: PackedScene = preload("res://scenes/player/flying_sword.tscn")

var player: CharacterBody2D = null
var swords: Array[Node2D] = []
var desired_count: int = 0
var sword_damage: float = 0.0
var detect_radius: float = 220.0
var attack_radius: float = 40.0
var orbit_radius: float = 48.0
var orbit_speed: float = 2.0
var move_speed: float = 520.0
var attack_cooldown: float = 0.6


func initialize(belonging_player: CharacterBody2D) -> void:
	player = belonging_player


func _physics_process(_delta: float) -> void:
	if player == null or not is_instance_valid(player):
		queue_free()
		return

	_cleanup_swords()


func _cleanup_swords() -> void:
	var valid_swords: Array[Node2D] = []
	for sword in swords:
		if sword != null and is_instance_valid(sword):
			valid_swords.append(sword)
	swords = valid_swords


func sync_from_player_stats() -> void:
	if player == null or not is_instance_valid(player):
		return

	desired_count = player.stats.flying_sword_count
	sword_damage = player.stats.flying_sword_damage
	detect_radius = player.stats.flying_sword_detect_radius
	attack_radius = player.stats.flying_sword_attack_radius
	orbit_radius = player.stats.flying_sword_orbit_radius
	orbit_speed = player.stats.flying_sword_orbit_speed
	move_speed = player.stats.flying_sword_move_speed
	attack_cooldown = player.stats.flying_sword_attack_cooldown

	_sync_sword_count()


func _sync_sword_count() -> void:
	while swords.size() < desired_count:
		var sword = flying_sword_scene.instantiate()
		add_child(sword)
		sword.initialize(self, player, swords.size())
		swords.append(sword)

	while swords.size() > desired_count:
		var sword = swords.pop_back()
		if sword != null and is_instance_valid(sword):
			sword.queue_free()

	for i in range(swords.size()):
		if swords[i] != null and is_instance_valid(swords[i]):
			swords[i].sword_index = i
			swords[i].orbit_angle = TAU * float(i) / max(1.0, float(swords.size()))
