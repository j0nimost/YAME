const std = @import("std");
const scan = @import("./scanner.zig");
const parse = @import("./parser.zig");
const writer = std.io.getStdOut().writer();

pub fn main() !void {
    const MAXINPUTALLOCATIONSIZE = 512;
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const stdIn = std.io.getStdIn();
    const reader = stdIn.reader();

    try writer.print("Welcome to Zalc, a Terminal based Math Calculator\n", .{});
    try writer.print("> ", .{});

    const mathExpression = (try reader.readUntilDelimiterOrEofAlloc(allocator, '\n', MAXINPUTALLOCATIONSIZE)).?;
    const scanner = scan.Scanner.init(mathExpression, allocator);
    const tokens = try scanner.scan();
    const parser = parse.Parser.init(tokens);
    const ans = try parser.parse();
    try writer.print("answer {d}\n", .{ans});
    try writer.print("> ", .{});
}
