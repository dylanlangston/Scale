const std = @import("std");
const ViewModel = @import("./ViewModel.zig").ViewModel;
const Shared = @import("../Helpers.zig").Shared;

fn VM() type {
    return struct {
        pub fn GetTitle() [:0]const u8 {
            return Shared.Locale.GetLocale().?.Title;
        }
    };
}

pub const MenuViewModel = ViewModel{ .Get = @constCast(@ptrCast(&VM)) };
