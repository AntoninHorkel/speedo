const std = @import("std");

pub fn build(builder: *std.Build) void {
    const exe = builder.addExecutable(.{
        .name             = "speedo",
        .target           = builder.standardTargetOptions(.{}),
        .root_source_file = .{ .path = "src/main.zig" },
        .version          = .{
            .major = 0,
            .minor = 0,
            .patch = 1,
        },
        .optimize         = builder.standardOptimizeOption(.{ .preferred_optimize_mode = .ReleaseFast }),
        .code_model       = .small, // .default
        .linkage          = .static,
        .strip            = true,
        .unwind_tables    = false,
        .use_llvm         = true,
        .use_lld          = true,
    });
    // _ = builder.addInstallArtifact(exe, .{
    //     // .dest_dir  =
    //     // .pdb_dir   =
    //     // .h_dir     =
    //     // .mplib_dir =
    // });
    builder.installArtifact(exe);
}
