class_name RoomData

var position: Vector2i             # 左上角位置
var width: int                     # 宽度（图格数）
var height: int                    # 高度（图格数）

var top_opening: int = -1          # 顶部开口索引（-1表示无开口，从左向右，起始索引0表示最左格））
var bottom_opening: int = -1       # 底部开口索引（-1表示无开口，从左向右，起始索引0表示最左格）
var left_opening: int = -1         # 左部开口索引（-1表示无开口，从上向下，起始索引0表示最左格）
var right_opening: int = -1        # 右部开口索引（-1表示无开口，从上向下，起始索引0表示最左格）

var top_connected: bool = false    # 顶部连接状态
var bottom_connected: bool = false # 底部连接状态
var left_connected: bool = false   # 左部连接状态
var right_connected: bool = false  # 右部连接状态
