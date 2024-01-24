const std     = @import("std");
const builtin = @import("builtin");
// TODO: Better detection of compiling with Tracy. This is a massive hack.
const c       = if (builtin.link_libcpp) @cImport({
    @cDefine("TRACY_ENABLE", "1");
    @cInclude("tracy/public/tracy/TracyC.h");
});

// TODO: Cleanup
pub const Zone = if (builtin.link_libcpp) struct {
    ctx: c.___tracy_c_zone_context, // c.TracyCZoneCtx

    pub inline fn init(
        comptime src:  std.builtin.SourceLocation,
        comptime name: ?[*:0]const u8,
    ) Zone {
        const src_loc = &c.___tracy_source_location_data {
            .name     = name,
            .function = src.fn_name.ptr,
            .file     = src.file.ptr,
            .line     = src.line,
            .color    = 0,
        };
        return 
            Zone {
                .ctx = if (@hasDecl(c, "TRACY_HAS_CALLSTACK"))
                    c.___tracy_emit_zone_begin_callstack(src_loc, 16, 1)
                else
                    c.___tracy_emit_zone_begin(src_loc, 1),
            };
    }

    pub inline fn deinit(self: @This()) void { c.___tracy_emit_zone_end(self.ctx); }
} else struct {
    pub inline fn init(
        comptime _: std.builtin.SourceLocation,
        comptime _: ?[*:0]const u8,
    ) Zone {
        return Zone {};
    }

    pub inline fn deinit(_: @This()) void {}
};
