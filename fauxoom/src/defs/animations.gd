class_name Animations

# path = "res://assets/sprites/sheets/64x64_projectiles.png",

const data = {
	# new format
	player = {
		name = "player",
		path = "res://assets/sprites/frames/player_frames.tres",
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
			}
		}
	},
	
	# old format - rewrite
	player_old = {
		name = "player_old",
		framesPath = "res://assets/sprites/frames/player_frames.tres",
		anims = [
			{
				name = "walk",
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
			{
				name = "aim",
				frames = [[32],[33],[34],[35],[36],[37],[38],[39]]
			},
			{
				name = "shoot",
				frames = [[40],[41],[42],[43],[44],[45],[46],[47]]
			},
			{
				name = "pain",
				frame = [[48],[49],[50],[51],[52],[53],[54],[55]]
			},
			{
				name = "die",
				frame = [[56,57,58,59,60,61,62]]
			},
			{
				name = "gib",
				frame = [[63,64,65,66,67,68,69,70,71]]
			}
		]
	},
	punk_old = {
		name = "punk_old",
		framesPath = "res://assets/sprites/frames/punk_frames.tres",
		anims = [
			{
				name = "walk",
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
			{
				name = "aim",
				frames = [[32],[33],[34],[35],[36],[37],[38],[39]]
			},
			{
				name = "shoot",
				frames = [[40],[41],[42],[43],[44],[45],[46],[47]]
			},
			{
				name = "pain",
				frame = [[48],[49],[50],[51],[52],[53],[54],[55]]
			},
			{
				name = "die",
				frame = [[56,57,58,59,60]]
			},
			{
				name = "gib",
				frame = [[61,62,63,64,65,66,67,68,69]]
			}
		]
	},
	items = {
		name = "items",
		framesPath = "res://assets/sprites/frames/item_frames.tres",
		anims = [
			{ name = "shotgun", frame = [[0]] },
			{ name = "super_shotgun", frame = [[1]] },
			{ name = "chaingun", frame = [[2]] },
			{ name = "rocket_launcher", frame = [[3]] },
			{ name = "plasmagun", frame = [[4]] },
			{ name = "bfg", frame = [[5]] },
			{ name = "chainsaw", frame = [[6]] },
			{ name = "flame_launcher", frame = [[8]] },
			{ name = "that_gun", frame = [[9]] },
			{ name = "shotgun_alt", frame = [[10]] },
			{ name = "bullets_small", frame = [[16]] },
			{ name = "bullets_large", frame = [[17]] },
			{ name = "shells_small", frame = [[18]] },
			{ name = "shells_large", frame = [[19]] },
			{ name = "rockets_small", frame = [[20]] },
			{ name = "rockets_large", frame = [[21]] },
			{ name = "cells_small", frame = [[22]] },
			{ name = "cells_large", frame = [[23]] },
			{ name = "backpack", frame = [[24]] },
			{ name = "health_tiny", frame = [[32], [33], [34], [35]] },
			{ name = "armour_tiny", frame = [[36], [37], [38], [39]] },
			{ name = "health_small", frame = [[40]] },
			{ name = "health_large", frame = [[41]] },
			{ name = "armour_green", frame = [[42], [43]] },
			{ name = "armour_red", frame = [[44], [45]] },
		]
	}
}
