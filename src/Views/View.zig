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
        if (isInitialized == false and self.VM != undefined and self.VM.*.Init != undefined) {
            self.VM.*.Init();
            isInitialized = true;
        }
    }
    pub fn deinit(self: View) void {
        defer Shared.GetAllocator().destroy(&self);
        defer Shared.GetAllocator().destroy(self.VM);

        if (self.VM != undefined and self.VM.*.DeInit != undefined) {
            self.VM.*.DeInit();
            isInitialized = false;
        }
    }
};
