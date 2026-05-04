extends BaseRoom


# 获取房间数据结构体
func get_room_data() -> RoomData:
	var data = RoomData.new()
	data.width = 12
	data.height = 10
	data.left_opening = 4
	data.top_opening = 5
	data.right_opening = 4
	return data
