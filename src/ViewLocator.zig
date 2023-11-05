const std = @import("std");
const BaseViewModel = @import("./ViewModels/ViewModel.zig").ViewModel;
const BaseView = @import("./Views/View.zig").View;

pub const ViewLocator = struct {
    fn GetView(view: Views) BaseView {
        switch (view) {
            Views.Raylib_Splash_Screen => {
                return @import("./Views/RaylibSplashScreenView.zig").RaylibSplashScreenView;
            },
            Views.Menu => {
                return @import("./Views/MenuView.zig").MenuView;
            },
        }
    }

    pub fn Build(view: Views) BaseView {
        const BuiltView = GetView(view);
        return BuiltView;
    }
};

pub const Views = enum { Raylib_Splash_Screen, Menu };
