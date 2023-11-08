const std = @import("std");
const raylib = @import("raylib");
const Logger = @import("Logger.zig").Logger;

pub const Inputs = struct {
    pub fn Up() bool {
        var gamepad: i8 = 0;
        while (raylib.isGamepadAvailable(gamepad)) {
            var totalAxis: i32 = raylib.getGamepadAxisCount(gamepad);
            while (totalAxis >= 0) {
                const axis = raylib.getGamepadAxisMovement(gamepad, totalAxis);
                if (axis != 0) Logger.Info_Formatted("Axis-{}: {}", .{ totalAxis, axis });
                totalAxis -= 1;
            }

            if (raylib.isGamepadButtonDown(0, raylib.GamepadButton.gamepad_button_left_face_up)) return true;
            gamepad += 1;
        }

        if (raylib.getGamepadButtonPressed() != raylib.GamepadButton.gamepad_button_unknown) return true;
        if (raylib.isKeyDown(raylib.KeyboardKey.key_w)) return true;
        if (raylib.isKeyDown(raylib.KeyboardKey.key_up)) return true;

        return false;
    }
    pub fn Down() bool {
        if (raylib.isKeyDown(raylib.KeyboardKey.key_s)) return true;
        if (raylib.isKeyDown(raylib.KeyboardKey.key_down)) return true;

        return false;
    }
    pub fn Left() bool {
        if (raylib.isKeyDown(raylib.KeyboardKey.key_a)) return true;
        if (raylib.isKeyDown(raylib.KeyboardKey.key_left)) return true;

        return false;
    }
    pub fn Right() bool {
        if (raylib.isKeyDown(raylib.KeyboardKey.key_d)) return true;
        if (raylib.isKeyDown(raylib.KeyboardKey.key_right)) return true;

        return false;
    }
    pub fn A() bool {}
    pub fn B() bool {}
    pub fn X() bool {}
    pub fn Y() bool {}
    pub fn Start() bool {}
};
