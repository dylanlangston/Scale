const std = @import("std");
const builtin = @import("builtin");
const rl = @import("src/Build_raylib.zig");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    var raylib = rl.getModule(b, "src/raylib-zig");
    var raylib_math = rl.math.getModule(b, "src/raylib-zig");
    //web exports are completely separate
    if (target.getOsTag() == .emscripten) {
        const cwd_path = b.build_root.path.?;
        const emscripten_absolute_path = b.pathJoin(&[_][]const u8{
            cwd_path,
            ".",
            "src",
            "emscripten",
            "upstream",
            "emscripten",
        });

        // Set the sysroot folder for emscripten
        b.sysroot = emscripten_absolute_path;

        setupEmscripten(b);

        const exe_lib = rl.compileForEmscripten(b, "Scale", "src/Scale.zig", target, optimize);
        exe_lib.addModule("raylib", raylib);
        exe_lib.addModule("raylib-math", raylib_math);
        const raylib_artifact = rl.getArtifact(b, target, optimize);
        // Note that raylib itself is not actually added to the exe_lib output file, so it also needs to be linked with emscripten.
        exe_lib.linkLibrary(raylib_artifact);
        const link_step = try rl.linkWithEmscripten(b, &[_]*std.Build.Step.Compile{ exe_lib, raylib_artifact });
        b.getInstallStep().dependOn(&link_step.step);
        const run_step = try rl.emscriptenRunStep(b);
        run_step.step.dependOn(&link_step.step);
        const run_option = b.step("run", "Run Scale");
        run_option.dependOn(&run_step.step);

        try copyWASMRunStep(b, &link_step.step, cwd_path);

        return;
    }

    const exe = b.addExecutable(.{ .name = "Scale", .root_source_file = .{ .path = "src/Scale.zig" }, .optimize = optimize, .target = target });

    rl.link(b, exe, target, optimize);
    exe.addModule("raylib", raylib);
    exe.addModule("raylib-math", raylib_math);

    const run_cmd = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run Scale");
    run_step.dependOn(&run_cmd.step);

    // // Add locales
    // b.installDirectory(.{
    //     .source_dir = .{ .path = "./src/Locales" },
    //     .install_dir = .bin,
    //     .install_subdir = "Locales",
    // });

    b.installArtifact(exe);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/Tests.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}

pub fn setupEmscripten(b: *std.build) void {
    std.debug.print("Install Emscripten\n", .{});
    _ = b.exec(&[_][]const u8{
        b.pathJoin(&[_][]const u8{ ".", "src", "emscripten", "emsdk" }),
        "install",
        "latest",
    });

    std.debug.print("Activate Emscripten\n", .{});
    _ = b.exec(&[_][]const u8{
        b.pathJoin(&[_][]const u8{ ".", "src", "emscripten", "emsdk" }),
        "activate",
        "latest",
    });
}

pub fn copyWASMRunStep(b: *std.Build, dependsOn: *std.Build.Step, cwd_path: []const u8) !void {
    const indexjs_step = b.addSystemCommand(&[_][]const u8{
        "cp",
        b.pathJoin(&[_][]const u8{
            cwd_path,
            "zig-out",
            "htmlout",
            "index.js",
        }),
        b.pathJoin(&[_][]const u8{
            cwd_path,
            "src",
            "scale-website",
            "static",
            "emscripten.js",
        }),
    });
    const indexwasm_step = b.addSystemCommand(&[_][]const u8{
        "cp",
        b.pathJoin(&[_][]const u8{
            cwd_path,
            "zig-out",
            "htmlout",
            "index.wasm",
        }),
        b.pathJoin(&[_][]const u8{
            cwd_path,
            "src",
            "scale-website",
            "static",
            "scale.wasm",
        }),
    });
    indexjs_step.step.dependOn(dependsOn);
    indexwasm_step.step.dependOn(dependsOn);

    b.getInstallStep().dependOn(&indexjs_step.step);
    b.getInstallStep().dependOn(&indexwasm_step.step);
}
