const std = @import("std");
const ViewModel = @import("./ViewModel.zig").ViewModel;
const Shared = @import("../Helpers.zig").Shared;
const raylib = @import("raylib");

fn VM() type {
    return struct {
        pub var selection = Selection.None;
        pub var Rectangles: [3]raylib.Rectangle = undefined;
    };
}

pub const Selection = enum { Start, Settings, Quit, None };

pub const MenuViewModel = ViewModel{ .Get = @constCast(@ptrCast(&VM)) };
