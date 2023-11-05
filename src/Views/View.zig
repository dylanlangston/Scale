const std = @import("std");
const Helpers = @import("../Helpers.zig");
const ViewModel = @import("../ViewModels/ViewModel.zig").ViewModel;
const Views = @import("../ViewLocator.zig").Views;

pub const View = struct { DrawRoutine: *const fn () Views, VM: ?*const ViewModel = null };
