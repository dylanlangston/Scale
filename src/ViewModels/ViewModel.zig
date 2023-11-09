const std = @import("std");

pub const ViewModel = struct {
    Init: *const fn () void = undefined,
    DeInit: *const fn () void = undefined,
    Get: *const fn () void,

    pub fn Create(comptime view_model: type, options: ?VMCreationOptions) ViewModel {
        const Inner = struct {
            fn func() type {
                return view_model;
            }
        };

        if (options != null) {
            const init = options.?.Init;
            const deinit = options.?.DeInit;
            return ViewModel{
                .Get = @constCast(@ptrCast(&Inner.func)),
                .Init = init,
                .DeInit = deinit,
            };
        }

        return ViewModel{
            .Get = @constCast(@ptrCast(&Inner.func)),
        };
    }

    pub fn GetVM(comptime self: ViewModel) type {
        const vm: *const fn () type = @ptrCast(self.Get);
        return vm.*();
    }
};

pub const VMCreationOptions = struct {
    Init: *const fn () void = undefined,
    DeInit: *const fn () void = undefined,
};
