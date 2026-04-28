extends BaseRoom


# 获取房间数据结构体
func get_room_data() -> RoomData:
	var data = RoomData.new()
	data.width = 26
	data.height = 18
	data.right_opening = 3
	data.top_opening = 2
	data.left_opening = 15
	return data
