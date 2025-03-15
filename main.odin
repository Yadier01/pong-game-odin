package main

import "core:fmt"
import "core:math/rand"
import "core:strconv"
import strings "core:strings"
import rb "vendor:raylib"

gameState :: struct {
	isGameRunning: bool,
	cpuScore:      int,
	userScore:     int,
}

cpuState :: struct {
	cpuPosition: [2]i32,
}
ballState :: struct {
	circlePos:       [2]i32,
	ballSpeedX:      i32,
	ballSpeedY:      i32,
	circleRadius:    f32,
	ballStartCenter: [2]i32,
}
windowHight :: 800
windowW :: 1280
main :: proc() {

	rb.InitWindow(windowW, windowHight, "Window")


	defer rb.CloseWindow()
	ballStartCenter := [2]i32{windowW / 2, windowHight / 2}
	gameState := gameState {
		isGameRunning = false,
		userScore     = 0,
		cpuScore      = 100,
	}
	cpuState := cpuState {
		cpuPosition = {windowW - 30, 20},
	}
	ballState := ballState {
		circlePos       = ballStartCenter,
		ballSpeedX      = -6,
		ballSpeedY      = -6,
		circleRadius    = 20,
		ballStartCenter = ballStartCenter,
	}

	playerRecPos := [2]i32{10, 100}
	recHight: i32 = 150
	recWidth: i32 = 20
	rb.SetTargetFPS(60)
	text: cstring = "player"
	cpu: cstring = "cpu"
	fontSize := 20
	for !rb.WindowShouldClose() {
		rb.BeginDrawing()
		rb.ClearBackground(rb.BLACK)
		if rb.IsKeyDown(rb.KeyboardKey.W) && playerRecPos.y > 0 {
			playerRecPos.y = playerRecPos.y - 10
		}
		if rb.IsKeyDown(rb.KeyboardKey.S) && playerRecPos.y + recHight < windowHight {
			playerRecPos.y = playerRecPos.y + 10
		}

		ballState.circlePos.x += ballState.ballSpeedX
		ballState.circlePos.y += ballState.ballSpeedY

		//check collision ball and recUser
		if rb.CheckCollisionCircleRec(
			{auto_cast ballState.circlePos.x, auto_cast ballState.circlePos.y},
			ballState.circleRadius,
			{
				auto_cast playerRecPos.x,
				auto_cast playerRecPos.y,
				auto_cast recWidth,
				auto_cast recHight,
			},
		) {
			randomVal := rand.float32()
			ballState.ballSpeedX = -ballState.ballSpeedX
			if randomVal < 0.5 {
				ballState.ballSpeedY = -ballState.ballSpeedY
			}
		}
		//check collision ball with rec cpu
		if rb.CheckCollisionCircleRec(
			{auto_cast ballState.circlePos.x, auto_cast ballState.circlePos.y},
			ballState.circleRadius,
			{
				auto_cast cpuState.cpuPosition.x,
				auto_cast cpuState.cpuPosition.y,
				auto_cast recWidth,
				auto_cast recHight,
			},
		) {
			ballState.ballSpeedX = -ballState.ballSpeedX
			randomVal := rand.float32()
			if randomVal < 0.5 {
				ballState.ballSpeedY = +ballState.ballSpeedY
			}
		}
		ballCollisionWithWall(&ballState, &gameState)

		if ballState.circlePos.y > cpuState.cpuPosition.y &&
		   cpuState.cpuPosition.y + recHight < windowHight {
			cpuState.cpuPosition.y = cpuState.cpuPosition.y + 6
		}
		if ballState.circlePos.y < cpuState.cpuPosition.y {
			cpuState.cpuPosition.y = cpuState.cpuPosition.y - 6
		}


		rb.DrawCircle(ballState.circlePos.x, ballState.circlePos.y, ballState.circleRadius, rb.RED)

		//player
		rb.DrawRectangle(playerRecPos.x, playerRecPos.y, recWidth, recHight, rb.RED)
		//cpu
		rb.DrawRectangle(
			cpuState.cpuPosition.x,
			cpuState.cpuPosition.y,
			recWidth,
			recHight,
			rb.RED,
		)


		//Player and Score
		player_x := 50
		centered_text_str(player_x, 10, text, fontSize)
		centered_text_int(player_x, 40, gameState.userScore, fontSize)

		//CPU and Score
		cpu_x: int = auto_cast windowW - 50
		centered_text_str(cpu_x, 10, cpu, fontSize)
		centered_text_int(cpu_x, 40, gameState.cpuScore, fontSize)

		rb.EndDrawing()
	}
}

centered_text_str :: proc(x: int, y: int, text: cstring, fontSize: int) {
	textWidth := rb.MeasureText(text, auto_cast fontSize)
	rb.DrawText(text, auto_cast x - (textWidth / 2), auto_cast y, auto_cast fontSize, rb.WHITE) // Centered
}
centered_text_int :: proc(x: int, y: int, value: int, fontSize: int) {
	buf: [32]byte
	text_str := strconv.itoa(buf[:], value)
	text_cstr := strings.clone_to_cstring(text_str)
	defer delete(text_cstr)
	textWidth := rb.MeasureText(text_cstr, auto_cast fontSize)
	rb.DrawText(
		text_cstr,
		auto_cast x - (textWidth / 2),
		auto_cast y,
		auto_cast fontSize,
		rb.WHITE,
	)
}
ballCollisionWithWall :: proc(ballState: ^ballState, gameState: ^gameState) {
	if ballState.circlePos.y - auto_cast ballState.circleRadius < 0 {
		fmt.println("hit top")
		ballState.ballSpeedY = -ballState.ballSpeedY
	}
	if ballState.circlePos.y + auto_cast ballState.circleRadius > windowHight {
		fmt.println("hit bttom")
		ballState.ballSpeedY = -ballState.ballSpeedY
	}
	if ballState.circlePos.x + auto_cast ballState.circleRadius > windowW {
		gameState.cpuScore += 1
		ballState.circlePos = ballState.ballStartCenter
	}
	if ballState.circlePos.x - auto_cast ballState.circleRadius < 0 {
		fmt.println("hit left")
		gameState.cpuScore += 1
		ballState.circlePos = ballState.ballStartCenter
	}

}
