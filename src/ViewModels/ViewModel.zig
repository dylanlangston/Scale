const std = @import("std");

pub const ViewModel = struct {
    Init: ?*const fn () void = null,
    Get: *const fn () void,

    pub fn GetVM(comptime self: ViewModel, comptime T: type) @TypeOf(T) {
        const vm: *const fn () T = @ptrCast(self.Get);
        return vm.*();
    }
};
