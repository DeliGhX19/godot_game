extends BaseRoom


# 获取房间数据结构体
func get_room_data() -> RoomData:
	var data = RoomData.new()
	data.width = 19
	data.height = 12
	data.right_opening = 10
	data.left_opening = 2
	data.bottom_opening =2
	return data
