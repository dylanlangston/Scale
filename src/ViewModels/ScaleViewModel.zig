const std = @import("std");
const ViewModel = @import("./ViewModel.zig").ViewModel;
const Shared = @import("../Helpers.zig").Shared;
const States = @import("../Views/RaylibSplashScreenView.zig").States;
const Logger = @import("../Logger.zig").Logger;
const raylib = @import("raylib");
const Colors = @import("../Colors.zig").Colors;
const Views = @import("../ViewLocator.zig").Views;
const WorldModel = @import("../Models/World.zig").World;
const RndGen = std.rand.DefaultPrng;

pub const ScaleViewModel = ViewModel.Create(
    struct {
        pub var elapsedSeconds: f64 = 0;
        pub var offset_y: f32 = 0;
        pub var introShown: bool = false;
    },
    .{
        .Init = init,
        .DeInit = deinit,
    },
);

fn init() void {
    const vm = ScaleViewModel.GetVM();
    vm.elapsedSeconds = 0;
    vm.offset_y = 0;
    vm.introShown = false;

    WorldModel.Init() catch {
        Logger.Error("Failed to Init World!");
    };
}

fn deinit() void {
    WorldModel.Deinit();
}
