const std = @import("std");
const ViewModel = @import("./ViewModel.zig").ViewModel;

fn VM() type {
    return struct {
        pub var Message: [:0]const u8 = "Scale Game!";
    };
}

pub const MenuViewModel = ViewModel{ .Get = @constCast(@ptrCast(&VM)) };
