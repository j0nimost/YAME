const std = @import("std");
const scan = @import("./scanner.zig");
const parse = @import("./parser.zig");
const writer = std.io.getStdOut().writer();

pub fn main() !void {
    const MAXINPUTALLOCATIONSIZE = 512;

    const stdIn = std.io.getStdIn();
    const reader = stdIn.reader();

    try writer.print("Welcome to Zalc, a Terminal based Math Calculator\n", .{});
    try writer.print("> ", .{});

    while (true) {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

        const allocator = arena.allocator();

        const mathExpression = (try reader.readUntilDelimiterOrEofAlloc(allocator, '\n', MAXINPUTALLOCATIONSIZE)).?;
        const scanner = scan.Scanner.init(mathExpression, allocator);
        const tokens = try scanner.scan();
        var parser = parse.Parser.init(tokens);
        const ans = try parser.parse();
        try writer.print("answer {d}\n", .{ans});
        try writer.print("> ", .{});
        arena.deinit();
    }
}
