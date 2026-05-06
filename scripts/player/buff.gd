class_name PlayerBuffs

const HP_LEVEL_1 = 0
const HP_LEVEL_2 = 1
const HP_LEVEL_3 = 2
const SPEED_LEVEL_1 = 3
const SPEED_LEVEL_2 = 4
const SPEED_LEVEL_3 = 5
const DR_LEVEL_1 = 6
const DR_LEVEL_2 = 7
const DR_LEVEL_3 = 8
const CRIT_LEVEL_1 = 9
const CRIT_LEVEL_2 = 10
const CRIT_LEVEL_3 = 11

const MAGIC_DMG_LEVEL_1 = 12
const MAGIC_DMG_LEVEL_2 = 13
const MAGIC_DMG_LEVEL_3 = 14
const MAGIC_SPD_LEVEL_1 = 15
const MAGIC_SPD_LEVEL_2 = 16
const MAGIC_SPD_LEVEL_3 = 17
const MAGIC_RANGE_LEVEL_1 = 18
const MAGIC_RANGE_LEVEL_2 = 19
const MAGIC_RANGE_LEVEL_3 = 20
const MAGIC_PIERCE = 21

const FIRE_DOT_LEVEL_1 = 22
const FIRE_DOT_LEVEL_2 = 23
const FIRE_DOT_LEVEL_3 = 24
const FIRE_EXPLODE = 25
const FIRE_ERUPTION = 26

const WOOD_HEAL = 27
const WOOD_HEAL_LEVEL_1 = 28
const WOOD_HEAL_LEVEL_2 = 29
const WOOD_HEAL_LEVEL_3 = 30
const WOOD_CONVERT = 31
const WOOD_TREANT = 32
const WOOD_TREANT_AURA = 33

const STONE_KB_LEVEL_1 = 34
const STONE_KB_LEVEL_2 = 35
const STONE_KB_LEVEL_3 = 36
const STONE_STUN = 37
const STONE_METEOR = 38

const ICE_SLOW_LEVEL_1 = 39
const ICE_SLOW_LEVEL_2 = 40
const ICE_SLOW_LEVEL_3 = 41
const ICE_FREEZE = 42
const ICE_EXPLORE = 43

const LIGHTNING_LEVEL_1 = 44
const LIGHTNING_LEVEL_2 = 45
const LIGHTNING_LEVEL_3 = 46
const LIGHTNING_CHAIN = 47
const LIGHTNING_DISASTER = 48

const MELEE_DMG_LEVEL_1 = 100
const MELEE_DMG_LEVEL_2 = 101
const MELEE_DMG_LEVEL_3 = 102
const MELEE_SPD_LEVEL_1 = 103
const MELEE_SPD_LEVEL_2 = 104
const MELEE_SPD_LEVEL_3 = 105
const MELEE_LIFESTEAL_LEVEL_1 = 106
const MELEE_LIFESTEAL_LEVEL_2 = 107
const MELEE_LIFESTEAL_LEVEL_3 = 108
const MELEE_KILL_REFRESH_1 = 109
const MELEE_KILL_REFRESH_2 = 110
const MELEE_KILL_REFRESH_3 = 111

const FLYING_SWORD = 112
const FLYING_SWORD_DAMAGE_1 = 113
const FLYING_SWORD_DAMAGE_2 = 114
const FLYING_SWORD_DAMAGE_3 = 115
const FLYING_SWORD_SPEED_1 = 116
const FLYING_SWORD_SPEED_2 = 117
const FLYING_SWORD_SPEED_3 = 118

const BUFFER_COUNT = 119

var buffs: Array[int]
var wood_convert_timer: float
var wood_treant_aura_timer: float


func initialize() -> void:
	buffs.resize(BUFFER_COUNT)
	buffs.fill(0)
	wood_convert_timer = 0.0
	wood_treant_aura_timer = 0.0


func apply(stats: PlayerStats, delta: float) -> void:
	for i in range(BUFFER_COUNT):
		if buffs[i] == 0:
			continue

		match i:
			HP_LEVEL_1:
				stats.max_hp *= pow(1.1, buffs[i])
			HP_LEVEL_2:
				stats.max_hp *= pow(1.3, buffs[i])
			HP_LEVEL_3:
				stats.max_hp *= pow(1.5, buffs[i])
			SPEED_LEVEL_1:
				stats.move_speed += 20 * buffs[i]
			SPEED_LEVEL_2:
				stats.move_speed += 25 * buffs[i]
				stats.jump_height += 15 * buffs[i]
			SPEED_LEVEL_3:
				stats.move_speed += 30 * buffs[i]
				stats.jump_height += 25 * buffs[i]
			DR_LEVEL_1:
				stats.damage_reduction += 0.0125 * buffs[i]
			DR_LEVEL_2:
				stats.damage_reduction += 0.025 * buffs[i]
			DR_LEVEL_3:
				stats.damage_reduction += 0.05 * buffs[i]
			CRIT_LEVEL_1:
				stats.crit_rate += 0.025 * buffs[i]
			CRIT_LEVEL_2:
				stats.crit_rate += 0.05 * buffs[i]
			CRIT_LEVEL_3:
				stats.crit_rate += 0.075 * buffs[i]
			MAGIC_DMG_LEVEL_1:
				for j in range(PlayerStats.FIRE_MAGIC, PlayerStats.DAMAGE_SOURCE_COUNT):
					stats.damages[j].value *= pow(1.15, buffs[i])
			MAGIC_DMG_LEVEL_2:
				for j in range(PlayerStats.FIRE_MAGIC, PlayerStats.DAMAGE_SOURCE_COUNT):
					stats.damages[j].value *= pow(1.30, buffs[i])
			MAGIC_DMG_LEVEL_3:
				for j in range(PlayerStats.FIRE_MAGIC, PlayerStats.DAMAGE_SOURCE_COUNT):
					stats.damages[j].value *= pow(1.50, buffs[i])
			MAGIC_SPD_LEVEL_1:
				stats.magic_attack_speed += 0.15 * buffs[i]
			MAGIC_SPD_LEVEL_2:
				stats.magic_attack_speed += 0.3 * buffs[i]
			MAGIC_SPD_LEVEL_3:
				stats.magic_attack_speed += 0.5 * buffs[i]
			MAGIC_RANGE_LEVEL_1:
				stats.magic_range_extra += 0.2 * buffs[i]
			MAGIC_RANGE_LEVEL_2:
				stats.magic_range_extra += 0.35 * buffs[i]
			MAGIC_RANGE_LEVEL_3:
				stats.magic_range_extra += 0.5 * buffs[i]
			MAGIC_PIERCE:
				stats.magic_pierce_extra += buffs[i]
			FIRE_EXPLODE:
				stats.damages[PlayerStats.FIRE_EXPLOSION].value *= pow(1.1, buffs[FIRE_EXPLODE])
			WOOD_HEAL:
				var heal_ratio = 0.005 + 0.001 * buffs[WOOD_HEAL_LEVEL_1] + 0.002 * buffs[WOOD_HEAL_LEVEL_2] + 0.005 * buffs[WOOD_HEAL_LEVEL_3]
				var heal_amount = heal_ratio * stats.max_hp
				var missing_hp = stats.max_hp - stats.hp
				var actual_heal = min(heal_amount, missing_hp)
				stats.settle_hp(-actual_heal)
				if stats.hp >= stats.max_hp and buffs[WOOD_CONVERT] > 0:
					wood_convert_timer = 3.0
				buffs[WOOD_HEAL] = 0
			WOOD_CONVERT:
				if wood_convert_timer > 0:
					wood_convert_timer -= delta
					for j in range(PlayerStats.DAMAGE_SOURCE_COUNT):
						stats.damages[j].value *= 1.0 + 0.1 * buffs[WOOD_CONVERT]
					stats.move_speed *= 1.0 + 0.05 * buffs[WOOD_CONVERT]
					stats.jump_height *= 1.0 + 0.05 * buffs[WOOD_CONVERT]
					stats.damage_reduction += 0.005 * buffs[WOOD_CONVERT]
			WOOD_TREANT_AURA:
				for j in range(PlayerStats.DAMAGE_SOURCE_COUNT):
					stats.damages[j].value *= 1.2
				stats.move_speed *= 1.1
				stats.jump_height *= 1.1
				stats.damage_reduction += 0.1
				if wood_treant_aura_timer <= 0:
					wood_treant_aura_timer = 5.0
					var missing_hp = stats.max_hp - stats.hp
					var actual_heal = min(0.01 * stats.max_hp, missing_hp)
					stats.settle_hp(-actual_heal)
				else:
					wood_treant_aura_timer -= delta
			LIGHTNING_LEVEL_1:
				stats.damages[PlayerStats.LIGHTNING_SPLASH].value *= 1.1
			LIGHTNING_LEVEL_2:
				stats.damages[PlayerStats.LIGHTNING_SPLASH].value *= 1.1
			LIGHTNING_LEVEL_3:
				stats.damages[PlayerStats.LIGHTNING_SPLASH].value *= 1.2
			MELEE_DMG_LEVEL_1:
				stats.damages[PlayerStats.PHYSIC_ATTACK].value *= pow(1.1, buffs[i])
			MELEE_DMG_LEVEL_2:
				stats.damages[PlayerStats.PHYSIC_ATTACK].value *= pow(1.25, buffs[i])
			MELEE_DMG_LEVEL_3:
				stats.damages[PlayerStats.PHYSIC_ATTACK].value *= pow(1.5, buffs[i])
			MELEE_SPD_LEVEL_1:
				stats.melee_attack_speed += 0.1 * buffs[i]
			MELEE_SPD_LEVEL_2:
				stats.melee_attack_speed += 0.2 * buffs[i]
			MELEE_SPD_LEVEL_3:
				stats.melee_attack_speed += 0.35 * buffs[i]
			MELEE_LIFESTEAL_LEVEL_1:
				stats.lifesteal += 0.02 * buffs[i]
			MELEE_LIFESTEAL_LEVEL_2:
				stats.lifesteal += 0.04 * buffs[i]
			MELEE_LIFESTEAL_LEVEL_3:
				stats.lifesteal += 0.06 * buffs[i]
			FLYING_SWORD:
				stats.flying_sword_count = max(stats.flying_sword_count, buffs[i])
				stats.flying_sword_damage += 12.0 * buffs[i]
			FLYING_SWORD_DAMAGE_1:
				stats.flying_sword_damage *= pow(1.15, buffs[i])
			FLYING_SWORD_DAMAGE_2:
				stats.flying_sword_damage *= pow(1.3, buffs[i])
			FLYING_SWORD_DAMAGE_3:
				stats.flying_sword_damage *= pow(1.5, buffs[i])
			FLYING_SWORD_SPEED_1:
				stats.flying_sword_move_speed += 60.0 * buffs[i]
				stats.flying_sword_attack_cooldown = max(0.2, stats.flying_sword_attack_cooldown - 0.05 * buffs[i])
			FLYING_SWORD_SPEED_2:
				stats.flying_sword_move_speed += 100.0 * buffs[i]
				stats.flying_sword_attack_cooldown = max(0.2, stats.flying_sword_attack_cooldown - 0.08 * buffs[i])
			FLYING_SWORD_SPEED_3:
				stats.flying_sword_move_speed += 150.0 * buffs[i]
				stats.flying_sword_attack_cooldown = max(0.2, stats.flying_sword_attack_cooldown - 0.12 * buffs[i])
