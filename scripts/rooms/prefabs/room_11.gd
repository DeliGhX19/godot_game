extends BaseRoom


# 获取房间数据结构体
func get_room_data() -> RoomData:
	var data = RoomData.new()
	data.width = 21
	data.height = 13
	data.right_opening = 1
	data.bottom_opening = 6
	data.left_opening = 1
	return data
