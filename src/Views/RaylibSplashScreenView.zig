const std = @import("std");
const Shared = @import("../Helpers.zig").Shared;
const Helpers = @import("../Helpers.zig");
const View = @import("./View.zig").View;
const ViewModel = @import("../ViewModels/ViewModel.zig").ViewModel;
const raylib = @import("raylib");
const Views = @import("../ViewLocator.zig").Views;

const SplashScreenViewModel = @import("../ViewModels/RaylibSplashScreenViewModel.zig").RaylibSplashScreenViewModel;

const logo_color = raylib.Color.orange;
const screen_color = raylib.Color.white;

fn DrawSplashScreen() Views {
    const vm = SplashScreenViewModel.GetVM(type);

    // Update View Model
    vm.Update();

    raylib.clearBackground(screen_color);

    const screenWidth = raylib.getScreenWidth();
    const screenHeight = raylib.getScreenHeight();

    const logoPositionX = @divTrunc(screenWidth, 2) - 128;
    const logoPositionY = @divTrunc(screenHeight, 2) - 128;

    switch (vm.state) {
        States.Blinking => {
            if (@rem(@divTrunc(vm.framesCounter, 15), 2) == 0)
                raylib.drawRectangle(logoPositionX, logoPositionY, 16, 16, logo_color);
        },
        States.ExpandTopLeft => {
            raylib.drawRectangle(logoPositionX, logoPositionY, vm.topSideRecWidth, 16, logo_color);
            raylib.drawRectangle(logoPositionX, logoPositionY, 16, vm.leftSideRecHeight, logo_color);
        },
        States.ExpandBottomRight => {
            raylib.drawRectangle(logoPositionX, logoPositionY, vm.topSideRecWidth, 16, logo_color);
            raylib.drawRectangle(logoPositionX, logoPositionY, 16, vm.leftSideRecHeight, logo_color);

            raylib.drawRectangle(logoPositionX + 240, logoPositionY, 16, vm.rightSideRecHeight, logo_color);
            raylib.drawRectangle(logoPositionX, logoPositionY + 240, vm.bottomSideRecWidth, 16, logo_color);
        },
        States.Letters => {
            raylib.drawRectangle(logoPositionX, logoPositionY, vm.topSideRecWidth, 16, raylib.fade(logo_color, vm.alpha));
            raylib.drawRectangle(logoPositionX, logoPositionY + 16, 16, vm.leftSideRecHeight - 32, raylib.fade(logo_color, vm.alpha));

            raylib.drawRectangle(logoPositionX + 240, logoPositionY + 16, 16, vm.rightSideRecHeight - 32, raylib.fade(logo_color, vm.alpha));
            raylib.drawRectangle(logoPositionX, logoPositionY + 240, vm.bottomSideRecWidth, 16, raylib.fade(logo_color, vm.alpha));

            raylib.drawRectangle(@divTrunc(screenWidth, 2) - 112, @divTrunc(screenHeight, 2) - 112, 224, 224, raylib.fade(screen_color, vm.alpha));

            raylib.drawText(raylib.textSubtext("raylib-zig", 0, vm.lettersCount), @divTrunc(screenWidth, 2) - 96, @divTrunc(screenHeight, 2) + 57, 41, raylib.fade(logo_color, vm.alpha));
        },
        States.Exit => {
            return Views.Dylan_Splash_Screen;
        },
    }

    return Views.Raylib_Splash_Screen;
}

fn DrawFunction() Views {
    if (Shared.Settings.GetSettings().Debug) {
        return Views.Menu;
    }

    return DrawSplashScreen();
}

pub const States = enum {
    Blinking,
    ExpandTopLeft,
    ExpandBottomRight,
    Letters,
    Exit,
};

pub const RaylibSplashScreenView = View{ .DrawRoutine = DrawFunction, .VM = &SplashScreenViewModel };
