package game

import rl "vendor:raylib"
import "core:fmt"
import "core:math/rand"

Fish :: struct {
	pos: rl.Vector2,
	color: rl.Color, 
	shark: bool
}

movement_coefficient: f32 = .01
shark_scare_multiplier: f32 = 25

fish_count := 200
fish_size: f32 = 3.0

fish_comfort_distance: f32 = 20
fish_comfort_range: f32 = fish_comfort_distance * 3

fish_start_x := 500
fish_start_y := 300
fish_start_variance := 100

main :: proc() {
	rl.InitWindow(1280, 720, "Shart and Minus")

	// Initialize fish collection
	fishes: [dynamic]Fish

	mouse_fish: Fish = Fish {
		rl.Vector2 { 0, 0 },
		rl.WHITE, 
		true
	}

	append(&fishes, mouse_fish)

	for i := 0; i < fish_count; i += 1 {
		fish_x := cast(f32)fish_start_x + ( (rand.float32() - .5) * cast(f32)fish_start_variance )
		fish_y := cast(f32)fish_start_y + ( (rand.float32() - .5) * cast(f32)fish_start_variance )

		fish := Fish {
			rl.Vector2 {
				fish_x,
				fish_y
			},
			get_random_color(),
			false
		}

		append(&fishes, fish)
	}

	timer: f32 = 0
	average_fish_position: rl.Vector2

	// Game Loop
	for !rl.WindowShouldClose() { 
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)	

		{ // Keyboard input
			keycode_pressed := rl.GetKeyPressed()

			#partial switch keycode_pressed {

			}	
		}

		{ // Mouse input
			if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
				new_fish: Fish = Fish {
					// +2 here becuase they're sticking to the mouse fish
					rl.Vector2 { cast(f32)rl.GetMouseX() + 2, cast(f32)rl.GetMouseY() + 2}, 
					get_random_color(),
					false
				}

				append(&fishes, new_fish)
			}
		}

		main_processing(&fishes, &average_fish_position, &timer)

		rl.EndDrawing()
	}

	rl.CloseWindow()
}

main_processing :: proc(fishes: ^[dynamic]Fish, average_fish_position: ^rl.Vector2, timer: ^f32) {
		// Draw all fish 
		for i := 0; i < len(fishes); i += 1 {
			fish_x := cast(i32)fishes[i].pos.x
			fish_y := cast(i32)fishes[i].pos.y

			rl.DrawCircle(fish_x, fish_y, fish_size, fishes[i].color)
		}

		// Call Update
		timer^ += rl.GetFrameTime()

		if (timer^ > 0.1 || true) {
			average_fish_position := update(fishes)

			timer^ = 0
		}

		fishes[0].pos = rl.Vector2 { cast(f32)rl.GetMouseX(), cast(f32)rl.GetMouseY() }

		rl.DrawCircle(cast(i32)average_fish_position.x, cast(i32)average_fish_position.y, 5, rl.WHITE)
}

update :: proc(fishes: ^[dynamic]Fish) -> rl.Vector2 {
	// Get average position
	average_pos := get_average_position(fishes)

	for i := 1; i < len(fishes); i += 1 {
		current_fish := fishes[i]

		closest_fish: Fish
		closest_distance: f32 = 10000
		for j := 0; j < len(fishes); j += 1 {
			if (j != i) {
				distance := rl.Vector2Distance(current_fish.pos, fishes[j].pos)

				if (distance < closest_distance) {
					closest_distance = distance
					closest_fish = fishes[j]
				}
			}
		}

		if (closest_distance < fish_comfort_distance) { // Too close, move away from closest fish
			movement: rl.Vector2 = closest_fish.pos - current_fish.pos
			movement *= -1 * movement_coefficient

			if closest_fish.shark {
				movement *= shark_scare_multiplier
			}

			fishes[i].pos = current_fish.pos + movement
		} else if (rl.Vector2Distance(current_fish.pos, average_pos) > (fish_comfort_distance + fish_comfort_range)) { // Too far away, move towards average postion
			movement: rl.Vector2 = average_pos - current_fish.pos
			movement *= movement_coefficient

			fishes[i].pos = current_fish.pos + movement
		}
	}

	return average_pos
}

get_average_position :: proc(fishes: ^[dynamic]Fish) -> rl.Vector2 {
	average_x: f32 = 0.0
	average_y: f32 = 0.0

	for i := 1; i < len(fishes); i += 1 {
		average_x += fishes[i].pos.x
		average_y += fishes[i].pos.y
	}

	average_x /= f32(len(fishes))
	average_y /= f32(len(fishes))

	return rl.Vector2 {
		average_x,
		average_y
	}
}

get_random_color :: proc() -> rl.Color {
	return rl.Color {
		cast(u8)(rand.float32() * 255.0),
		cast(u8)(rand.float32() * 255.0),
		cast(u8)(rand.float32() * 255.0),
		255
	}
}
