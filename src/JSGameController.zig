const std = @import("std");
const Logger = @import("Logger.zig").Logger;

var keyPressed = false;

export fn js_key_pressed(button: usize) void {
    keyPressed = true;
    Logger.Info_Formatted("Pressed: {}", .{button});
}

export fn js_key_released(button: usize) void {
    keyPressed = false;
    Logger.Info_Formatted("Release: {}", .{button});
}

pub fn GetKeyPressed() bool {
    return keyPressed;
}
