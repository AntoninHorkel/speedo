const std     = @import("std");
const builtin = @import("builtin");

comptime {
    if (.windows == builtin.os.tag) @export(wWinMainCRTStartup, .{ .name = "wWinMainCRTStartup"                                   })
    else                            @export(_start,             .{ .name = if (builtin.cpu.arch.isMIPS()) "__start" else "_start" });
}

pub fn wWinMainCRTStartup() callconv(std.os.windows.WINAPI) noreturn {
    @setAlignStack(16);
    // TODO: Something to do with TLS idrk..
    // if(!builtin.single_threaded and !builtin.link_libc) _ = std.start_windows_tls;
    // std.debug.maybeEnableSegfaultHandler();
    std.os.windows.kernel32.ExitProcess(main());
}

pub fn _start() callconv(.C) noreturn { std.os.exit(main()); }

inline fn main() if (.windows == builtin.os.tag) std.os.windows.UINT else u8 { return 0; }
