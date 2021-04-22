class_name Animations

const data = {
	# new format
	player = {
		name = "player",
		path = "res://assets/sprites/frames/player_frames.tres",
		offset = 32,
		anims = {
			walk = {
				frames = [
					[ 0, 8, 16, 24 ],
					[ 1, 9, 17, 25 ],
					[ 2, 10, 18, 26 ],
					[ 3, 11, 19, 27 ],
					[ 4, 12, 20, 28 ],
					[ 5, 13, 21, 29 ],
					[ 6, 14, 22, 30 ],
					[ 7, 15, 23, 31 ]
				]
			},
			aim = {
				frames = [[32],[33],[34],[35],[36],[37],[38],[39]]
			}
		}
	},
	punk = {
		name = "punk",
		path = "res://assets/sprites/frames/punk_frames.tres",
		offset = 32,
		anims = {
			walk = {
				frames = [
					[ 0, 8, 16, 24 ],
					[ 1, 9, 17, 25 ],
					[ 2, 10, 18, 26 ],
					[ 3, 11, 19, 27 ],
					[ 4, 12, 20, 28 ],
					[ 5, 13, 21, 29 ],
					[ 6, 14, 22, 30 ],
					[ 7, 15, 23, 31 ]
				]
			},
			aim = {
				frames = [[32],[33],[34],[35],[36],[37],[38],[39]]
			},
			shoot = {
				frames = [[40],[41],[42],[43],[44],[45],[46],[47]]
			},
			pain = {
				frames = [[48],[49],[50],[51],[52],[53],[54],[55]]
			},
			dying = {
				loopIndex = 4,
				frames = [[56,57,58,59,60]]
			},
			dead = {
				frames = [[60]]
			},
			dying_gib = {
				frames = [[61,62,63,64,65,66,67,68,69]]
			},
			dead_gib = {
				frames = [[69]]
			}
		}
	},
	flesh_worm = {
		name = "flesh_worm",
		path = "res://assets/sprites/frames/worm_frames.tres",
		offset = 32,
		anims = {
			walk = {
				frames = [
					[ 0, 8, 16, 24 ],
					[ 1, 9, 17, 25 ],
					[ 2, 10, 18, 26 ],
					[ 3, 11, 19, 27 ],
					[ 4, 12, 20, 28 ],
					[ 5, 13, 21, 29 ],
					[ 6, 14, 22, 30 ],
					[ 7, 15, 23, 31 ]
				]
			},
			aim = {
				frames = [[32],[33],[34],[35],[36],[37],[38],[39]]
			},
			shoot = {
				frames = [
					[ 32, 40, 48 ],
					[ 33, 41, 49 ],
					[ 34, 42, 50 ],
					[ 35, 43, 51 ],
					[ 36, 44, 52 ],
					[ 37, 45, 53 ],
					[ 38, 46, 54 ],
					[ 39, 47, 55 ]
				]
			},
			pain = {
				frames = [[56],[57],[58],[59],[60],[61],[62],[63]]
			},
			dying = {
				loopIndex = 5,
				frames = [[64,65,66,67,68,69]]
			},
			dead = {
				frames = [[60]]
			},
			dying_gib = {
				frames = [[61,62,63,64,65,66,67,68,69]]
			},
			dead_gib = {
				frames = [[69]]
			}
		}
	},
	serpent = {
		name = "serpent",
		path = "res://assets/sprites/frames/serpent_frames.tres",
		offset = 32,
		anims = {
			walk = {
				frames = [
					[ 0, 8, 16, 24 ],
					[ 1, 9, 17, 25 ],
					[ 2, 10, 18, 26 ],
					[ 3, 11, 19, 27 ],
					[ 4, 12, 20, 28 ],
					[ 5, 13, 21, 29 ],
					[ 6, 14, 22, 30 ],
					[ 7, 15, 23, 31 ]
				]
			},
			aim = {
				frames = [[32],[33],[34],[35],[36],[37],[38],[39]]
			},
			shoot = {
				frames = [
					[ 32, 40, 48 ],
					[ 33, 41, 49 ],
					[ 34, 42, 50 ],
					[ 35, 43, 51 ],
					[ 36, 44, 52 ],
					[ 37, 45, 53 ],
					[ 38, 46, 54 ],
					[ 39, 47, 55 ]
				]
			},
			pain = {
				frames = [[56],[57],[58],[59],[60],[61],[62],[63]]
			},
			dying = {
				loopIndex = 4,
				frames = [[64,65,66,67,68]]
			},
			dead = {
				frames = [[68]]
			},
			dying_gib = {
				frames = [[69,70,71,72,73,74,75,76]]
			},
			dead_gib = {
				frames = [[76]]
			}
		}
	},
	mob_spider = {
		name = "mob_spider",
		path = "res://assets/sprites/frames/spider_frames.tres",
		offset = 32,
		anims = {
			walk = {
				frames = [
					[ 0, 8, 16, 24, 32, 40 ],
					[ 1, 9, 17, 25, 33, 41 ],
					[ 2, 10, 18, 26, 34, 42 ],
					[ 3, 11, 19, 27, 35, 43 ],
					[ 4, 12, 20, 28, 36, 44 ],
					[ 5, 13, 21, 29, 37, 45 ],
					[ 6, 14, 22, 30, 38, 46 ],
					[ 7, 15, 23, 31, 39, 47 ]
				]
			},
			shoot = {
				frames = [
					[ 48, 56 ],
					[ 49, 57 ],
					[ 50, 58 ],
					[ 51, 59 ],					

					[ 52, 60 ],
					[ 53, 61 ],
					[ 54, 62 ],
					[ 55, 63 ],
				]
			},
			pain = {
				frames = [[64],[65],[66],[67],[68],[69],[70],[71]]
			},
			dying = {
				loopIndex = 6,
				frames = [[72,73,74,75,76,77,78]]
			},
			dead = {
				frames = [[78]]
			}
		}
	},
	projectiles = {
		name = "projectiles",
		path = "res://assets/sprites/frames/64x64_projectile_frames.tres",
		offset = 0,
		anims = {
			green_ball = {
				frames = [[0, 1]]
			},
			yellow = {
				frames = [[7, 8]]
			},
			rocket = {
				frames = [[17],[18],[19],[20],[21],[22],[23],[24]]
			}
		}
	},
	
	items = {
		name = "items",
		framesPath = "res://assets/sprites/frames/item_frames.tres",
		anims = {
			shotgun = { frames = [[0]] },
			super_shotgun = { frames = [[1]] },
			chaingun = { frame = [[2]] },
			rocket_launcher = { frame = [[3]] },
			plasmagun = { frame = [[4]] },
			bfg = { frame = [[5]] },
			chainsaw = { frame = [[6]] },
			flame_launcher = { frame = [[7]] },
		}
	}
}
