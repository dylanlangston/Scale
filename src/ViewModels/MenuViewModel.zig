const std = @import("std");
const ViewModel = @import("./ViewModel.zig").ViewModel;
const Shared = @import("../Scale.zig").Shared;

fn VM() type {
    return struct {
        pub fn GetMessage() [:0]const u8 {
            return Shared.GetLocale().?.Title;
        }
    };
}

pub const MenuViewModel = ViewModel{ .Get = @constCast(@ptrCast(&VM)) };
