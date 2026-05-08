extends BaseRoom


# 获取房间数据结构体
func get_room_data() -> RoomData:
	var data = RoomData.new()
	data.width = 18
	data.height = 5
	data.left_opening = 2
	data.right_opening = 2
	return data
