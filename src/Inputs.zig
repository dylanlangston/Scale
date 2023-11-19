const std = @import("std");
const raylib = @import("raylib");
const Logger = @import("Logger.zig").Logger;

pub const Inputs = struct {
    pub fn Up_Held() bool {
        var gamepad: i8 = 0;
        while (raylib.isGamepadAvailable(gamepad)) {
            const y_axis = raylib.getGamepadAxisMovement(gamepad, @intFromEnum(raylib.GamepadAxis.gamepad_axis_left_y));
            if (y_axis < 0) return true;
            gamepad += 1;
        }

        if (raylib.isKeyDown(raylib.KeyboardKey.key_w)) return true;
        if (raylib.isKeyDown(raylib.KeyboardKey.key_up)) return true;

        return false;
    }
    pub fn Down_Held() bool {
        var gamepad: i8 = 0;
        while (raylib.isGamepadAvailable(gamepad)) {
            const y_axis = raylib.getGamepadAxisMovement(gamepad, @intFromEnum(raylib.GamepadAxis.gamepad_axis_left_y));
            if (y_axis > 0) return true;
            gamepad += 1;
        }

        if (raylib.isKeyDown(raylib.KeyboardKey.key_s)) return true;
        if (raylib.isKeyDown(raylib.KeyboardKey.key_down)) return true;

        return false;
    }
    pub fn Left_Held() bool {
        var gamepad: i8 = 0;
        while (raylib.isGamepadAvailable(gamepad)) {
            const x_axis = raylib.getGamepadAxisMovement(gamepad, @intFromEnum(raylib.GamepadAxis.gamepad_axis_left_x));
            if (x_axis < 0) return true;
            gamepad += 1;
        }

        if (raylib.isKeyDown(raylib.KeyboardKey.key_a)) return true;
        if (raylib.isKeyDown(raylib.KeyboardKey.key_left)) return true;

        return false;
    }
    pub fn Right_Held() bool {
        var gamepad: i8 = 0;
        while (raylib.isGamepadAvailable(gamepad)) {
            const x_axis = raylib.getGamepadAxisMovement(gamepad, @intFromEnum(raylib.GamepadAxis.gamepad_axis_left_x));
            if (x_axis > 0) return true;
            gamepad += 1;
        }

        if (raylib.isKeyDown(raylib.KeyboardKey.key_d)) return true;
        if (raylib.isKeyDown(raylib.KeyboardKey.key_right)) return true;

        return false;
    }
    pub fn A_Held() bool {
        if (raylib.isKeyDown(raylib.KeyboardKey.key_enter)) return true;

        return false;
    }
    pub fn B_Held() bool {}
    pub fn X_Held() bool {}
    pub fn Y_Held() bool {}
    pub fn Start_Held() bool {}

    pub fn Up_Pressed() bool {
        var gamepad: i8 = 0;
        while (raylib.isGamepadAvailable(gamepad)) {
            const y_axis = raylib.getGamepadAxisMovement(gamepad, @intFromEnum(raylib.GamepadAxis.gamepad_axis_left_y));
            if (y_axis < 0) return true;
            gamepad += 1;
        }

        if (raylib.isKeyPressed(raylib.KeyboardKey.key_w)) return true;
        if (raylib.isKeyPressed(raylib.KeyboardKey.key_up)) return true;

        return false;
    }
    pub fn Down_Pressed() bool {
        var gamepad: i8 = 0;
        while (raylib.isGamepadAvailable(gamepad)) {
            const y_axis = raylib.getGamepadAxisMovement(gamepad, @intFromEnum(raylib.GamepadAxis.gamepad_axis_left_y));
            if (y_axis > 0) return true;
            gamepad += 1;
        }

        if (raylib.isKeyPressed(raylib.KeyboardKey.key_s)) return true;
        if (raylib.isKeyPressed(raylib.KeyboardKey.key_down)) return true;

        return false;
    }
    pub fn Left_Pressed() bool {
        var gamepad: i8 = 0;
        while (raylib.isGamepadAvailable(gamepad)) {
            const x_axis = raylib.getGamepadAxisMovement(gamepad, @intFromEnum(raylib.GamepadAxis.gamepad_axis_left_x));
            if (x_axis < 0) return true;
            gamepad += 1;
        }

        if (raylib.isKeyPressed(raylib.KeyboardKey.key_a)) return true;
        if (raylib.isKeyPressed(raylib.KeyboardKey.key_left)) return true;

        return false;
    }
    pub fn Right_Pressed() bool {
        var gamepad: i8 = 0;
        while (raylib.isGamepadAvailable(gamepad)) {
            const x_axis = raylib.getGamepadAxisMovement(gamepad, @intFromEnum(raylib.GamepadAxis.gamepad_axis_left_x));
            if (x_axis > 0) return true;
            gamepad += 1;
        }

        if (raylib.isKeyPressed(raylib.KeyboardKey.key_d)) return true;
        if (raylib.isKeyPressed(raylib.KeyboardKey.key_right)) return true;

        return false;
    }
    pub fn A_Pressed() bool {
        const button = raylib.isGamepadButtonPressed(0, @as(raylib.GamepadButton, @enumFromInt(6)));
        if (button) return true;
        //Logger.Info_Formatted("Button: {}", .{@intFromEnum(raylib.getGamepadButtonPressed())});

        if (raylib.isKeyPressed(raylib.KeyboardKey.key_enter)) return true;

        return false;
    }
    pub fn B_Pressed() bool {
        const button = raylib.isGamepadButtonPressed(0, @as(raylib.GamepadButton, @enumFromInt(7)));
        if (button) return true;
        //Logger.Info_Formatted("Button: {}", .{@intFromEnum(raylib.getGamepadButtonPressed())});

        if (raylib.isKeyPressed(raylib.KeyboardKey.key_space)) return true;

        return false;
    }
    pub fn X_Pressed() bool {}
    pub fn Y_Pressed() bool {}
    pub fn Start_Pressed() bool {
        const button = raylib.isGamepadButtonPressed(0, @as(raylib.GamepadButton, @enumFromInt(17)));
        if (button) return true;

        if (raylib.isKeyPressed(raylib.KeyboardKey.key_escape)) return true;
        return false;
    }
};
