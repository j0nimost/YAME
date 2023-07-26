const std = @import("std");
const writer = std.io.getStdOut().writer();
const expect = std.testing.expect;
const testAllocation = std.testing.allocator;

const Token = enum {
    NUM,
    ADD,
    MINUS,
    MULTIPLY,
    DIVISION,
    LEFTPAREN,
    RIGHTPAREN,
    EOF,
};

pub const TokenTag = union(Token) {
    NUM: f64,
    ADD: u8,
    MINUS: u8,
    MULTIPLY: u8,
    DIVISION: u8,
    LEFTPAREN: u8,
    RIGHTPAREN: u8,
    EOF: u8,
};

pub const Scanner = struct {
    buffer: []const u8,
    allocator: std.mem.Allocator,

    pub fn init(buffer: []const u8, allocator: std.mem.Allocator) Scanner {
        return Scanner{
            .buffer = buffer,
            .allocator = allocator,
        };
    }

    pub fn scan(self: Scanner) ![]const TokenTag {
        var arrayList = std.ArrayList(TokenTag).init(self.allocator);

        var index: usize = 0;

        while (index < self.buffer.len) : (index += 1) {
            var tag = try arrayList.addOne();
            switch (self.buffer[index]) {
                '0'...'9' => {
                    tag.* = try parseNumber(self.buffer, &index);
                },
                '+' => {
                    tag.* = TokenTag{ .ADD = '+' };
                },
                '-' => {
                    tag.* = TokenTag{ .MINUS = '-' };
                },
                '/' => {
                    tag.* = TokenTag{ .DIVISION = '/' };
                },
                '*' => {
                    tag.* = TokenTag{ .MULTIPLY = '*' };
                },
                '(' => {
                    tag.* = TokenTag{ .LEFTPAREN = '(' };
                },
                ')' => {
                    tag.* = TokenTag{ .RIGHTPAREN = ')' };
                },
                ' ' => {
                    continue;
                },
                else => return error.InvalidCharacter,
            }
        }
        _ = try arrayList.append(TokenTag{ .EOF = '0' });
        return arrayList.toOwnedSlice();
    }

    fn parseNumber(buff: []const u8, index: *usize) !TokenTag {
        var commaCount: u32 = 0;
        var numLength: usize = 0;
        const buffIndex = index.*;

        for (buff[buffIndex..]) |value, i| {
            if (value >= '0' and value <= '9') {
                numLength += 1;
            } else if (value == '.' and commaCount < 1) {
                commaCount += 1;
                numLength += 1;
            } else {
                break;
            }
            index.* = buffIndex + i;
        }
        const num = try std.fmt.parseFloat(f64, buff[buffIndex .. buffIndex + numLength]);

        return TokenTag{ .NUM = num };
    }
};

test "test scanner" {
    const buff: []const u8 = "45+45";
    var scanner = Scanner.init(buff, testAllocation);

    var tokens = try scanner.scan();
    defer testAllocation.free(tokens);
    try expect(tokens.len == 4);

    for (tokens) |value| {
        switch (value) {
            TokenTag.NUM => |num| try expect(num == 45),
            TokenTag.ADD => |op| try expect(op == '+'),
            TokenTag.EOF => |eof| try expect(eof == '0'),
            else => unreachable,
        }
    }
}
