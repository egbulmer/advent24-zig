const std = @import("std");
const input = @embedFile("day6_input.txt");

const max_size: usize = 130;

var width: usize = 0;
var height: usize = 0;

var map: [max_size * max_size]u8 = undefined;
var orig_map: [max_size * max_size]u8 = undefined;

const Direction = enum { N, S, E, W };
const MoveResult = enum { moved, oob, looped };
const VisitedMap = std.AutoHashMap(usize, Direction);

const Guard = struct {
    x: i32,
    y: i32,
    dir: Direction,
    visited: *VisitedMap,

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

        if (ch == '#') {
            self.turn();
            return self.move();
        }

        const idx = index(next_x, next_y) orelse unreachable;
        if (self.visited.get(idx)) |dir| {
            if (dir == self.dir) return .looped;
        }

        self.x = next_x;
        self.y = next_y;
        self.visited.put(idx, self.dir) catch unreachable;

        return .moved;
    }

    pub fn turn(self: *Guard) void {
        self.dir = switch (self.dir) {
            .N => .E,
            .E => .S,
            .S => .W,
            .W => .N,
        };
    }

    pub fn patrol(self: *Guard, x: i32, y: i32, dir: Direction, visited: *VisitedMap) MoveResult {
        const idx = index(x, y) orelse unreachable;

        self.visited = visited;
        self.visited.put(idx, .N) catch unreachable;
        self.x = x;
        self.y = y;
        self.dir = dir;

        while (true) {
            const result = self.move();
            switch (result) {
                .oob, .looped => return result,
                else => {},
            }
        }
    }
};

var guard: Guard = undefined;

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        _ = gpa.deinit();
    }
    const allocator = gpa.allocator();

    var init_x: i32 = 0;
    var init_y: i32 = 0;

    var row_it = std.mem.tokenizeScalar(u8, input, '\n');

    while (row_it.next()) |row| : (height += 1) {
        if (row.len > width) width = row.len;
        std.mem.copyForwards(u8, map[height * width ..], row);

        if (std.mem.indexOf(u8, row, "^")) |x| {
            init_x = @intCast(x);
            init_y = @intCast(height);
        }
    }

    orig_map = map;

    var visited1: VisitedMap = VisitedMap.init(allocator);
    defer visited1.deinit();

    var visited2: VisitedMap = VisitedMap.init(allocator);
    defer visited2.deinit();

    // Patrol until the guard is out-of-bounds, tracking all visited positions.
    _ = guard.patrol(init_x, init_y, .N, &visited1);

    var loop_count: u32 = 0;

    // Iterate over every position in the patrol route.
    var idx_it = visited1.keyIterator();
    while (idx_it.next()) |idx| {
        // Place an obstacle and test if the guard gets stuck in a loop.
        map[idx.*] = '#';
        const result = guard.patrol(init_x, init_y, .N, &visited2);
        if (result == .looped) loop_count += 1;

        // Restore the map to it's original state and clear second visit map.
        map = orig_map;
        visited2.clearRetainingCapacity();
    }

    std.debug.print("Answer = {d}\n", .{loop_count});
}

fn index(x: i32, y: i32) ?usize {
    if (x < 0 or x >= width or y < 0 or y >= height) return null;
    return @as(usize, @intCast(y)) * width + @as(usize, @intCast(x));
}

fn at(x: i32, y: i32) ?u8 {
    const i = index(x, y) orelse return null;
    return map[i];
}
