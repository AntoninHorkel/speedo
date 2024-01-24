const std    = @import("std");
const tracy  = @import("tracy.zig");
const parser = @import("frontend/parser.zig");

inline fn fmtMsg(
    comptime t:    enum { ok, err },
    comptime name: []const u8,
    comptime msg:  []const u8,
) []const u8 {
    return switch (t) {
        .ok  => "\x1B[0;1;42m ",
        .err => "\x1B[0;1;41m ",
    } ++ name ++ " \x1B[0m " ++ msg;
}

pub fn main() u8 {
    const zone = tracy.Zone.init(@src(), null);
    defer zone.deinit();

    var stderr_buf_writer = std.io.bufferedWriter(std.io.getStdErr().writer());
    defer stderr_buf_writer.flush() catch {};
    const stderr = stderr_buf_writer.writer();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const hash = std.hash.Fnv1a_64.hash;

    const version = "speedo version 0.0.1";
    const build_options =
        \\BUILD OPTIONS:
        \\    -f, --file <path>                     Main project file.
        \\    -t, --target {cuda|vulkan|webgpu}     Target backend.
        \\    -h, --help                            Print help and exit.
        \\
        ;
    const lsp_options =
        \\LANGUAGE SERVER OPTIONS:
        \\    TODO                                  TODO: More options.
        \\    -h, --help                            Print help and exit.
        \\
        ;
    const usage = version ++
        \\
        \\
        \\USAGE:
        \\    speedo [command] [options and parameters]
        \\
        \\COMMANDS:
        \\    build                                 Build project.
        \\    lsp                                   Run language server (LSP).
        \\    help, -h, --help {build|lsp|all|*}    Print help and exit. Defaults to all.
        \\    version, -v, --version                Print version and exit.
        \\
        ++ build_options ++ lsp_options;

    var args = std.process.argsWithAllocator(allocator) catch |err| {
        stderr.print(fmtMsg(.err, "COMPILER ERROR ({s})", "Failed to get process argument."), .{ @errorName(err) }) catch {};
        return 1;
    };
    defer args.deinit();
    _ = args.skip();
    const cmd = args.next() orelse "help";
    switch (hash(cmd)) {
        hash("build") => {
            var filepath: ?[]const u8                    = null;
            var target:   ?enum { cuda, vulkan, webgpu } = null;
            while (args.next()) |opt| switch (hash(opt)) {
                hash("-f"), hash("--file") =>
                    if (filepath != null) {
                        stderr.print(fmtMsg(.err, "ERROR", "Duplicite option '{s}'. Try 'speedo help'."), .{ opt }) catch {};
                        return 1;
                    } else if (args.next()) |arg| {
                        filepath = arg;
                    } else {
                        stderr.print(fmtMsg(.err, "ERROR", "Option '{s}' expects path parameter. Try 'speedo help'."), .{ opt }) catch {};
                        return 1;
                    },
                hash("-t"), hash("--target") =>
                    if (target != null) {
                        stderr.print(fmtMsg(.err, "ERROR", "Duplicite option '{s}'. Try 'speedo help'."), .{ opt }) catch {};
                        return 1;
                    } else if (args.next()) |arg|
                        switch (hash(arg)) {
                            hash("cuda")   => target = .cuda,
                            hash("vulkan") => target = .vulkan,
                            hash("webgpu") => target = .webgpu,
                            else => {
                                stderr.print(fmtMsg(.err, "ERROR", "Unexpected parameter '{s}' for option '{s}'. Try 'speedo help'."), .{ arg, opt }) catch {};
                                return 1;
                            },
                        }
                    else {
                        stderr.print(fmtMsg(.err, "ERROR", "Option '{s}' expects parameter. Try 'speedo help'."), .{ opt }) catch {};
                        return 1;
                    },
                hash("-h"), hash("--help") => {
                    stderr.writeAll(build_options) catch {};
                    return 0; // TODO: Check --help is the only option.
                },
                else => {},
            };
            const file = std.fs.cwd().openFile(filepath orelse {
                stderr.writeAll(fmtMsg(.err, "ERROR", "Command 'build' expects option '-f' or '--file'. Try 'speedo help'.")) catch {};
                return 0;
            }, .{}) catch return 1;
            defer file.close();
            parser.parse(file);
        },
        hash("lsp") => {
            while (args.next()) |opt| switch (hash(opt)) {
                hash("-h"), hash("--help") => {
                    stderr.writeAll(build_options) catch {};
                    return 0; // TODO: Check --help is the only option.
                },
                else => {},
            };
            stderr.print(fmtMsg(.err, "ERROR", "TODO"), .{}) catch {};
            return 1;
        },
        hash("help"),    hash("-h"), hash("--help")    => stderr.writeAll(usage) catch {},
        hash("version"), hash("-v"), hash("--version") => stderr.writeAll(version) catch {},
        else => {
            stderr.print(fmtMsg(.err, "ERROR", "Unknown command '{s}'. Try 'speedo help'."), .{ cmd }) catch {};
            return 1;
        },
    }
    return 0;
}
