extends Node2D

const TILE_SIZE = 64     # 图格大小（64*64）

@onready var start_room_instance = $StartRoom
@onready var end_room_instance = $EndRoom

var room_template_dir: String = "res://scenes/rooms/prefabs/"     # 房间模板路径
var room_count: int = 3                                          # 房间模板数量
var max_rooms: int = 15                                          # 最多生成房间数
var min_rooms_before_end: int = 12                               # 生成结束房间前的最近房间数

var room_templates: Array[PackedScene] = []
var placed_nodes: Array[Node2D] = []
var placed_rooms: Array[RoomData] = []

signal next_level


# 生成关卡
func generate_level() -> void:
	clear_previous_level()
	load_templates()
	while true:
		if generate(): break
		clear_previous_level()

# 返回所有敌人生成点
func get_all_enemy_points() -> Array[Marker2D]:
	var all_points: Array[Marker2D] = []
	for room_node in placed_nodes:
		var room_pts = room_node.get_enemy_points()
		all_points.append_array(room_pts)
	return all_points


# 清理关卡
func clear_previous_level() -> void:
	for node in placed_nodes:
		if node != start_room_instance and node != end_room_instance:
			node.queue_free()
	placed_nodes.clear()
	placed_rooms.clear()

# 加载房间模板
func load_templates() -> void:
	room_templates.clear()
	for i in range(room_count):
		room_templates.append(load(room_template_dir + "room_%02d.tscn" % i))

# 拼接房间
func generate() -> bool:
	# 放置初始房间（左上角在(0,0)）
	var start_room = start_room_instance.get_room_data()
	start_room.position = Vector2i.ZERO
	start_room_instance.position = Vector2i.ZERO
	placed_nodes.append(start_room_instance) 
	placed_rooms.append(start_room)
	
	# 放置普通房间或结束房间
	var end_placed = false    # 是否放置结束房间
	var attempts = 0          # 尝试数
	while placed_nodes.size() < max_rooms and not end_placed:
		if ++attempts > 500: break
		
		# 尝试放置结束房间
		if placed_nodes.size() >= min_rooms_before_end and try_place_end():
			end_placed = true
			continue
		
		# 查找所有房间的未使用开口
		var free_idx = []
		for i in placed_rooms.size():
			if not get_free_openings(placed_rooms[i]).is_empty():
				free_idx.append(i)
		if free_idx.is_empty():
			continue
		# 选择一个房间的未使用的开口
		var a_idx = free_idx[randi() % free_idx.size()]
		var room_a = placed_rooms[a_idx]
		var dir_a = get_free_openings(room_a).pick_random()
		var dir_b = opposite_dir(dir_a)
		
		# 查找拥有对向未使用开口的房间
		var valid_templates = []
		for t in room_templates:
			var dummy = t.instantiate()
			var d = dummy.get_room_data()
			if has_opening(d, dir_b):
				valid_templates.append(t)
			dummy.queue_free()
		if valid_templates.is_empty():
			continue
		# 选择一个房间
		var template = valid_templates[randi() % valid_templates.size()]
		var instance_b = template.instantiate()
		var room_b = instance_b.get_room_data()
		var pos_b = calculate_position(room_a, dir_a, room_b)
		room_b.position = pos_b
		# 检查是否重叠
		if is_overlapping(room_b):
			instance_b.queue_free()
			continue
		# 放置普通房间
		add_child(instance_b)
		instance_b.position = Vector2(pos_b) * TILE_SIZE
		set_connected(room_a, dir_a, true)
		set_connected(room_b, dir_b, true)
		placed_nodes.append(instance_b)
		placed_rooms.append(room_b)
	
	# 如果没有放置结束房间则失败
	if not end_placed:
		return false
	
	# 更新所有房间开口状态
	for i in placed_nodes.size():
		placed_nodes[i].apply_room_data(placed_rooms[i])
	
	return true

# 尝试放置结束房间
func try_place_end() -> bool:
	# 创建结束房间实例
	var end_room = end_room_instance.get_room_data()
	var end_dirs = get_free_openings(end_room)

	#查找可以使用的开口
	var candidates: Array[Dictionary] = []
	for i in placed_rooms.size():
		var temp_a = placed_rooms[i]
		for dir_a in get_free_openings(temp_a):
			var temp_dir_b = opposite_dir(dir_a)
			if temp_dir_b in end_dirs:
				candidates.append({"idx": i, "dir_a": dir_a, "dir_b": temp_dir_b})
	if candidates.is_empty():
		return false

	# 选择合适的开口与房间
	var chosen = candidates[randi() % candidates.size()]
	var a = placed_rooms[chosen.idx]
	var dir_a: int = chosen.dir_a
	var dir_b: int = chosen.dir_b
	
	# 尝试放置结束房间
	var pos_end = calculate_position(a, dir_a, end_room)
	end_room.position = pos_end
	# 检查是否重叠
	if is_overlapping(end_room):
		return false
	# 放置结束房间
	end_room_instance.position = Vector2(pos_end) * TILE_SIZE
	set_connected(a, dir_a, true)
	set_connected(end_room, dir_b, true)
	placed_nodes.append(end_room_instance)
	placed_rooms.append(end_room)
	return true


# 获取房间所有未使用的开口
func get_free_openings(r: RoomData) -> Array:
	var dirs = []
	if r.top_opening != -1 and not r.top_connected:    dirs.append(0)
	if r.bottom_opening != -1 and not r.bottom_connected: dirs.append(1)
	if r.left_opening != -1 and not r.left_connected:   dirs.append(2)
	if r.right_opening != -1 and not r.right_connected:  dirs.append(3)
	return dirs

# 获取对向开口方向
func opposite_dir(dir: int) -> int:
	return [1, 0, 3, 2][dir]

# 检验房间是否有特定开口
func has_opening(r: RoomData, dir: int) -> bool:
	match dir:
		0: return r.top_opening != -1
		1: return r.bottom_opening != -1
		2: return r.left_opening != -1
		3: return r.right_opening != -1
	return false

# 设置房间开口参数
func set_connected(r: RoomData, dir: int, val: bool) -> void:
	match dir:
		0: r.top_connected = val
		1: r.bottom_connected = val
		2: r.left_connected = val
		3: r.right_connected = val

# 计算左上角位置
func calculate_position(a: RoomData, dir_a: int, b: RoomData) -> Vector2i:
	match dir_a:
		0: return Vector2i(a.position.x + a.top_opening - b.bottom_opening, a.position.y - b.height)
		1: return Vector2i(a.position.x + a.bottom_opening - b.top_opening, a.position.y + a.height)
		2: return Vector2i(a.position.x - b.width, a.position.y + a.left_opening - b.right_opening)
		3: return Vector2i(a.position.x + a.width, a.position.y + a.right_opening - b.left_opening)
	return Vector2i.ZERO

# 检查是否重叠
func is_overlapping(room: RoomData) -> bool:
	var r = Rect2i(room.position.x, room.position.y, room.width, room.height)
	for other in placed_rooms:
		var o = Rect2i(other.position.x, other.position.y, other.width, other.height)
		if r.intersects(o):
			return true
	return false


func _on_end_room_next_level() -> void:
	next_level.emit()
