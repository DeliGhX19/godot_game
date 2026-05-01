class_name GameManager

# 伤害类型常量
const TYPE_PHYSIC = 0                     # 物理伤害
const TYPE_FIRE = 1                       # 火焰伤害
const TYPE_WOOD = 2                       # 木伤害
const TYPE_STONE = 3                      # 石伤害
const TYPE_ICE = 4                        # 冰伤害
const TYPE_LIGHTNING = 5                  # 雷伤害
const TYPE_COUNT = 6                      # 所有伤害

# 全局数据
static var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# 玩家
static var player: CharacterBody2D


# 工具方法
static func is_target_blocked_by_wall(from_node: Node2D, to_node: Node2D, mask: int = 1, offset: Vector2 = Vector2(0, -20)) -> bool:
	var space_state = from_node.get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		from_node.global_position + offset,
		to_node.global_position + offset
	)
	query.collision_mask = mask
	query.exclude = [from_node.get_rid()]
	
	var result = space_state.intersect_ray(query)
	return result.size() > 0
