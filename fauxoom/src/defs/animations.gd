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
				loopIndex = 5,
				frames = [[48,56,57,58,59,60]]
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
	punk_corpse = {
		name = "punk",
		path = "res://assets/sprites/frames/punk_corpse_frames.tres",
		offset = 32,
		anims = {
			pain = {
				frames = [[0],[1],[2],[3],[4],[5],[6],[7]]
			},
			dying = {
				loopIndex = 5,
				frames = [[0,8,9,10,11,12]]
			},
			dead = {
				frames = [[12]]
			},
			headshot_stand = {
				frames = [[22]]
			},
			headshot_dying = {
				loopIndex = 4,
				frames = [[22, 24, 25, 26, 27]]
			},
			dying_gib = {
				loopIndex = 8,
				frames = [[13,14,15,16,17,18,19,20,21]]
			},
			dead_gib = {
				frames = [[21]]
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
			leap = {
				frames = [[48],[49],[50],[51],[52],[53],[54],[55]]
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

	cyclops = {
		name = "cyclops",
		path = "res://assets/sprites/frames/cyclops_frames.tres",
		offset = 64,
		anims = {
			walk = {
				frames = [
					[ 0, 8 ],
					[ 1, 9 ],
					[ 2, 10 ],
					[ 3, 11 ],
					[ 4, 12 ],
					[ 5, 13 ],
					[ 6, 14 ],
					[ 7, 15 ]
				]
			},
			aim = {
				frames = [[16],[17],[18],[19],[20],[21],[22],[23]],
			},
			shoot = {
				frames = [[24],[25],[26],[27],[28],[29],[30],[31]],
			},
			pain = {
				frames = [[40],[41],[42],[43],[44],[45],[46],[47]],
			},
			dying = {
				loopIndex = 5,
				frames = [[48,49,50,51,52,53]]
			},
			dead = {
				frames = [53]
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
					[ 1, 9, 17, 23, 33, 41 ],
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
	
	mob_golem = {
		name = "mob_golem",
		path = "res://assets/sprites/frames/golem_frames.tres",
		offset = 48,
		anims = {
			walk = {
				frames = [
					[ 0, 8, 16, 24, 32, 40 ],
					[ 1, 9, 17, 23, 33, 41 ],
					[ 2, 10, 18, 26, 34, 42 ],
					[ 3, 11, 19, 27, 35, 43 ],
					[ 4, 12, 20, 28, 36, 44 ],
					[ 5, 13, 21, 29, 37, 45 ],
					[ 6, 14, 22, 30, 38, 46 ],
					[ 7, 15, 23, 31, 39, 47 ]
				]
			},
			aim = {
				frames = [
					[48], [49], [50], [51], [52], [53], [54], [55]
				]
			},
			shoot = {
				frames = [
					[56, 64],
					[57, 65],
					[58, 66],
					[59, 67],
					[60, 68],
					[61, 69],
					[62, 70],
					[63, 71]
				]
			},
			pain = {
				frames = [
					[72], [73], [74], [75], [76], [77], [78], [79]
				]
			},
			dying = {
				loopIndex = 9,
				frames = [[80,81,82,83,84,85,86,87,88,89]]
			},
			dead = {
				frames = [[89]]
			}
		}
	},
	
	mob_titan = {
		name = "mob_titan",
		path = "res://assets/sprites/frames/titan_frames.tres",
		offset = 64,
		anims = {
			walk = {
				frames = [
					[ 0, 8, 16, 24, 32 ],
					[ 1, 9, 17, 25, 33 ],
					[ 2, 10, 18, 26, 34 ],
					[ 3, 11, 19, 27, 35 ],
					[ 4, 12, 20, 28, 36 ],
					[ 5, 13, 21, 29, 37 ],
					[ 6, 14, 22, 30, 38 ],
					[ 7, 15, 23, 31, 39 ]
				]
			},
			aim = {
				frames = [
					[ 48 ],
					[ 49 ],
					[ 50 ],
					[ 51 ],

					[ 52 ],
					[ 53 ],
					[ 54 ],
					[ 55 ],
				]
			},
			shoot = {
				frames = [
					[ 40, 48 ],
					[ 41, 49 ],
					[ 42, 50 ],
					[ 43, 51 ],

					[ 44, 52 ],
					[ 45, 53 ],
					[ 46, 54 ],
					[ 47, 55 ],
				]
			},
			pain = {
				frames = [[0],[1],[2],[3],[4],[5],[6],[7]]
			},
			dying = {
				loopIndex = 8,
				frames = [[56,57,58,59,60,61,62,63,64]]
			},
			dead = {
				frames = [[64]]
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
			},
			grenade = {
				frames = [[52, 53]]
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
