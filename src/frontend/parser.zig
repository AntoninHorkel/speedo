const std       = @import("std");
const tracy     = @import("../tracy.zig"); // TODO
const Tokenizer = @import("tokenizer.zig");

pub inline fn parse(file: std.fs.File) void {
    const zone = tracy.Zone.init(@src(), null);
    defer zone.deinit();

    const tokenizer = Tokenizer.init(file);
    _ = tokenizer;
}
