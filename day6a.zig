const std = @import("std");
const input = @embedFile("day6_input.txt");

const max_size: usize = 130;

var width: usize = 0;
var height: usize = 0;

var map: [max_size * max_size]u8 = undefined;

const Direction = enum { N, S, E, W };

const MoveResult = enum { success, blocked, oob };

const Guard = struct {
    x: i32,
    y: i32,
    dir: Direction,

    pub fn move(self: *Guard) MoveResult {
        var next_x = self.x;
        var next_y = self.y;

        switch (self.dir) {
            .N => next_y -= 1,
            .E => next_x += 1,
            .S => next_y += 1,
            .W => next_x -= 1,
        }

        const ch = at(next_x, next_y) orelse return .oob;
        if (ch == '#') return .blocked;

        self.x = next_x;
        self.y = next_y;

        return .success;
    }

    pub fn turn(self: *Guard) void {
        self.dir = switch (self.dir) {
            .N => .E,
            .E => .S,
            .S => .W,
            .W => .N,
        };
    }

    pub fn patrol(self: *Guard) void {
        while (true) {
            const result = self.move();
            switch (result) {
                .success => {
                    const i = index(self.x, self.y) orelse unreachable;
                    map[i] = 'X';
                },
                .blocked => self.turn(),
                .oob => return,
            }
        }
    }
};

var guard: Guard = .{ .x = 0, .y = 0, .dir = .N };
var path_buf: [1024]usize = undefined;

pub fn main() void {
    var row_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (row_it.next()) |row| : (height += 1) {
        if (row.len > width) width = row.len;
        std.mem.copyForwards(u8, map[height * width ..], row);

        if (std.mem.indexOf(u8, row, "^")) |x| {
            guard.x = @intCast(x);
            guard.y = @intCast(height);
        }
    }

    guard.patrol();

    var count: u32 = 1; // Include starting position.
    for (map) |tile| {
        if (tile == 'X') count += 1;
    }

    std.debug.print("Answer = {d}\n", .{count});
}

fn index(x: i32, y: i32) ?usize {
    if (x < 0 or x >= width or y < 0 or y >= height) return null;
    return @as(usize, @intCast(y)) * width + @as(usize, @intCast(x));
}

fn at(x: i32, y: i32) ?u8 {
    const i = index(x, y) orelse return null;
    return map[i];
}
