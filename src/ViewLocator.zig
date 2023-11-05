const std = @import("std");
const BaseViewModel = @import("./ViewModels/ViewModel.zig").ViewModel;
const BaseView = @import("./Views/View.zig").View;

pub const ViewLocator = struct {
    fn GetView(view: Views) BaseView {
        switch (view) {
            Views.Splash_Screen => {
                return @import("./Views/SplashScreenView.zig").SplashScreenView;
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

pub const Views = enum { Splash_Screen, Menu };
