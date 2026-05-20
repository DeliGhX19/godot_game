extends Control


func _on_saves_profile_selected(profile: PlayerProfile) -> void:
	var camp_scene = load("res://scenes/main/camp.tscn")
	var camp_instance = camp_scene.instantiate()
	camp_instance.profile = profile
	
	get_tree().root.add_child(camp_instance)
	queue_free()
