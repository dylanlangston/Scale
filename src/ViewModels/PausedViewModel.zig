const std = @import("std");
const ViewModel = @import("./ViewModel.zig").ViewModel;
const Shared = @import("../Helpers.zig").Shared;
const States = @import("../Views/RaylibSplashScreenView.zig").States;
const Logger = @import("../Logger.zig").Logger;
const raylib = @import("raylib");
const Colors = @import("../Colors.zig").Colors;
const Views = @import("../ViewLocator.zig").Views;
const RndGen = std.rand.DefaultPrng;

pub const PausedViewModel = ViewModel.Create(
    struct {
        pub var View: Views = undefined;
        pub var BackgroundTexture: ?raylib.Texture = null;

        pub fn PauseView(v: Views) void {
            if (BackgroundTexture != null) {
                BackgroundTexture.?.unload();
            }

            raylib.endDrawing();
            const img = raylib.loadImageFromScreen();
            defer img.unload();
            BackgroundTexture = img.toTexture();
            View = v;
        }
    },
    .{},
);
