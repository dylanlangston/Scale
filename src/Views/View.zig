const std = @import("std");
const Helpers = @import("../Helpers.zig");
const ViewModel = @import("../ViewModels/ViewModel.zig").ViewModel;
const Views = @import("../ViewLocator.zig").Views;
const Shared = @import("../Helpers.zig").Shared;

pub const View = struct {
    DrawRoutine: *const fn () Views,
    VM: *const ViewModel = undefined,

    // Initialize View Model if needed
    var isInitialized = false;
    pub fn init(self: View) void {
        if (isInitialized == false and @intFromPtr(self.VM) != 0 and @intFromPtr(self.VM.*.Init) != 0) {
            self.VM.*.Init();
            isInitialized = true;
        }
    }
    pub fn deinit(self: View) void {
        if (@intFromPtr(self.VM) != 0 and @intFromPtr(self.VM.*.DeInit) != 0) {
            self.VM.*.DeInit();
            isInitialized = false;
        }
    }
};
