extends BaseRoom


# 获取房间数据结构体
func get_room_data() -> RoomData:
	var data = RoomData.new()
	data.width = 12
	data.height = 10
	data.top_opening = 2
	data.bottom_opening = 8
	return data
