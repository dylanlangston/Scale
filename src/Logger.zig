const std = @import("std");
const raylib = @import("raylib");
const Shared = @import("Helpers.zig").Shared;

pub const Logger = struct {
    pub fn Trace(text: [:0]const u8) void {
        raylib.traceLog(raylib.TraceLogLevel.log_trace, text);
    }
    pub fn Debug(text: [:0]const u8) void {
        raylib.traceLog(raylib.TraceLogLevel.log_debug, text);
    }
    pub fn Info(text: [:0]const u8) void {
        raylib.traceLog(raylib.TraceLogLevel.log_info, text);
    }
    pub fn Warning(text: [:0]const u8) void {
        raylib.traceLog(raylib.TraceLogLevel.log_warning, text);
    }
    pub fn Error(text: [:0]const u8) void {
        raylib.traceLog(raylib.TraceLogLevel.log_error, text);
    }
    pub fn Fatal(text: [:0]const u8) void {
        raylib.traceLog(raylib.TraceLogLevel.log_fatal, text);
    }

    pub fn Trace_Formatted(comptime format: []const u8, comptime T: type, args: T) void {
        log_formatted(raylib.TraceLogLevel.log_trace, format, args);
    }
    pub fn Debug_Formatted(comptime format: []const u8, args: anytype) void {
        log_formatted(raylib.TraceLogLevel.log_debug, format, args);
    }
    pub fn Info_Formatted(comptime format: []const u8, args: anytype) void {
        log_formatted(raylib.TraceLogLevel.log_info, format, args);
    }
    pub fn Warning_Formatted(comptime format: []const u8, args: anytype) void {
        log_formatted(raylib.TraceLogLevel.log_warning, format, args);
    }
    pub fn Error_Formatted(comptime format: []const u8, args: anytype) void {
        log_formatted(raylib.TraceLogLevel.log_error, format, args);
    }
    pub fn Fatal_Formatted(comptime format: []const u8, args: anytype) void {
        log_formatted(raylib.TraceLogLevel.log_fatal, format, args);
    }

    fn log_formatted(level: raylib.TraceLogLevel, comptime format: []const u8, args: anytype) void {
        const aloc = Shared.GetAllocator();
        const text = std.fmt.allocPrint(aloc, format, args) catch {
            std.debug.print(format, args);
            std.debug.print("\n", .{});
            return;
        };
        defer aloc.free(text);
        const raylib_text = aloc.dupeZ(u8, text) catch {
            std.debug.print(format, args);
            std.debug.print("\n", .{});
            return;
        };
        defer aloc.free(raylib_text);

        raylib.traceLog(level, raylib_text);
    }
};
