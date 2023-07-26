const std = @import("std");
const writer = std.io.getStdOut().writer();
const eql = std.meta.eql;
const expect = std.testing.expect;
const scanner = @import("./scanner.zig");
const TokenTag = scanner.TokenTag;

const ParserError = error{
    UnexpectedEOF,
    UnknownToken,
};

pub const Parser = struct {
    const Self = @This();
    tokens: []const TokenTag,

    var pos: usize = 0;

    pub fn init(tokens: []const TokenTag) Parser {
        return Parser{
            .tokens = tokens,
        };
    }

    fn eat(self: Self, tokenTag: TokenTag) ParserError!TokenTag {
        const currentToken: TokenTag = self.tokens[pos];

        // TODO: Figure out how to check expected token is equal to current Token
        _ = tokenTag;
        // if (!eql(&currentToken, &tokenTag)) {
        //     return ParserError.UnknownToken;
        // }

        pos += 1;
        return currentToken;
    }

    pub fn parse(self: Self) !f64 {
        return self.parseExpression(0);
    }

    fn parseExpression(self: Self, precedence: u8) ParserError!f64 {
        var left = try self.prefix();
        while (precedence < try self.infixPrecedence(self.tokens[pos])) {
            left = try self.infix(&left, self.tokens[pos]);
        }
        return left;
    }

    fn prefix(self: Self) ParserError!f64 {
        const numberToken = try self.eat(TokenTag{ .NUM = 0 });
        return numberToken.NUM;
    }

    fn infix(self: Self, left: *f64, tokenTag: TokenTag) ParserError!f64 {
        var token = try self.eat(tokenTag);
        var newPrecedence = try self.infixPrecedence(tokenTag);
        return switch (token) {
            .ADD => left.* + try self.parseExpression(newPrecedence),
            .MINUS => left.* - try self.parseExpression(newPrecedence),
            .MULTIPLY => left.* * try self.parseExpression(newPrecedence),
            else => 0,
        };
    }

    fn infixPrecedence(self: Self, opToken: TokenTag) ParserError!u8 {
        _ = self;
        return switch (opToken) {
            .EOF => 0,
            .ADD, .MINUS => 2,
            .MULTIPLY, .DIVISION => 3,
            else => ParserError.UnknownToken,
        };
    }
};
