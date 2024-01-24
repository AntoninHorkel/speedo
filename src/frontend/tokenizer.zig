const std   = @import("std");
const tracy = @import("../tracy.zig"); // TODO

pub const Token = struct {
    hash: u64,
    tag:  Tag,
    const Tag = enum {
        eof,
        identifier,
        int_literal,
        float_literal,
        string_literal,
        @".",
        @":",
        @"+",
        @"-",
        @"*",
        @"/",
        @"(",
        @")",
        @"[",
        @"]",
    };
    pub inline fn prescedance(self: @This()) u8 {
        return switch (self.tag) {
            .eof,
            .identifier,
            .int_literal,
            .float_literal,
            .string_literal,
            => 0,
        };
    }
};

const State = enum {
    block,
    comment,
    identifier,
    int_literal,
    float_literal,
    string_literal,
};

reader: std.io.AnyReader,
state:  State,
line:   u64,

pub inline fn init(file: std.fs.File) @This() {
    const zone = tracy.Zone.init(@src(), null);
    defer zone.deinit();

    var buf_reader = std.io.bufferedReader(file.reader());
    return .{
        .reader = buf_reader.reader().any(),
        .state  = .block,
        .line   = 1,
    };
}

pub fn next(self: *@This()) !Token {
    const zone = tracy.Zone.init(@src(), null);
    defer zone.deinit();

    while (try self.reader.readByte()) |char| {
        switch (char) {
            '\n' => self.line += 1,
            '#' => {
                switch (self.state) {
                    .comment => self.state = .block,
                    .string_literal => {},
                    else => self.state = .comment,
                }
            }
        }
        switch (self.state) {
            .block => switch (char) {
                '#' => {
                    self.sate = .comment;
                },
                'A'...'Z', '_', 'a'...'z' => {
                    self.state = .identifier;
                },
            },
            .comment => switch (char) {
                '#' => self.state = .block,
                else => {},
            },
            .indentifier => switch (char) {
                '0'...'9', 'A'...'Z', '_', 'a'...'z' => {
                    self.state = .identifier;
                },
            }
        }
    }
}
