extends BaseRoom


# 获取房间数据结构体
func get_room_data() -> RoomData:
	var data = RoomData.new()
	data.width = 10
	data.height = 6
	data.right_opening = 3
	return data
