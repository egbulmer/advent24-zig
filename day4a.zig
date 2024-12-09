const std = @import("std");
const input = @embedFile("day4_input.txt");

const max_size = 140;
const xmas = "XMAS";

var width: usize = 0;
var height: usize = 0;

var map = [_]u8{'.'} ** (max_size * max_size);

pub fn main() void {
    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    var i: usize = 0;

    var count: u32 = 0;

    while (line_it.next()) |line| {
        if (width < line.len) width = line.len;
        std.mem.copyForwards(u8, map[i..], line);
        i += width;
        height += 1;
    }

    for (0..height) |iy| {
        for (0..width) |ix| {
            const x: i32 = @intCast(ix);
            const y: i32 = @intCast(iy);

            if (scan(x, y, 0, -1)) count += 1; // N
            if (scan(x, y, 1, -1)) count += 1; // NE
            if (scan(x, y, 1, 0)) count += 1; // E
            if (scan(x, y, 1, 1)) count += 1; // SE
            if (scan(x, y, 0, 1)) count += 1; // S
            if (scan(x, y, -1, 1)) count += 1; // SW
            if (scan(x, y, -1, 0)) count += 1; // W
            if (scan(x, y, -1, -1)) count += 1; // NW
        }
    }

    std.debug.print("Answer = {d}\n", .{count});
}

fn at(x: i32, y: i32) ?u8 {
    if (x < 0 or x >= width or y < 0 or y >= height) return null;
    const index: usize = @as(usize, @intCast(y)) * width + @as(usize, @intCast(x));
    return map[index];
}

fn scan(x: i32, y: i32, dx: i32, dy: i32) bool {
    var px = x;
    var py = y;
    for (xmas) |letter| {
        const ch = at(px, py) orelse return false;
        if (ch != letter) return false;
        px += dx;
        py += dy;
    }
    return true;
}
