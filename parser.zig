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
    tokens: []const TokenTag,
    pos: usize,

    pub fn init(tokens: []const TokenTag) Parser {
        return Parser{
            .tokens = tokens,
            .pos = 0,
        };
    }

    fn eat(self: *Parser, tokenTag: TokenTag) ParserError!TokenTag {
        const currentToken: TokenTag = self.tokens[self.pos];

        if (@as(@typeInfo(TokenTag).Union.tag_type.?, tokenTag) != currentToken) {
            return ParserError.UnknownToken;
        }

        self.pos += 1;
        return currentToken;
    }

    pub fn parse(self: *Parser) !f64 {
        return self.parseExpression(0);
    }

    fn parseExpression(self: *Parser, precedence: u8) ParserError!f64 {
        var left = try self.prefix();
        while (precedence < try self.infixPrecedence(self.tokens[self.pos])) {
            left = try self.infix(&left, self.tokens[self.pos]);
        }
        return left;
    }

    fn prefix(self: *Parser) ParserError!f64 {
        const numberToken = try self.eat(TokenTag{ .NUM = 0 });
        return numberToken.NUM;
    }

    fn infix(self: *Parser, left: *f64, tokenTag: TokenTag) ParserError!f64 {
        var token = try self.eat(tokenTag);
        var newPrecedence = try self.infixPrecedence(tokenTag);
        return switch (token) {
            .ADD => left.* + try self.parseExpression(newPrecedence),
            .MINUS => left.* - try self.parseExpression(newPrecedence),
            .MULTIPLY => left.* * try self.parseExpression(newPrecedence),
            .DIVISION => @divExact(left.*, try self.parseExpression(newPrecedence)),
            else => 0,
        };
    }

    fn infixPrecedence(self: *Parser, opToken: TokenTag) ParserError!u8 {
        _ = self;
        return switch (opToken) {
            .EOF => 0,
            .ADD, .MINUS => 2,
            .MULTIPLY, .DIVISION => 3,
            else => ParserError.UnknownToken,
        };
    }
};
