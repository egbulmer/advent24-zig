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

            if (scan(x, y)) count += 1;
        }
    }

    std.debug.print("Answer = {d}\n", .{count});
}

fn at(x: i32, y: i32) ?u8 {
    if (x < 0 or x >= width or y < 0 or y >= height) return null;
    const index: usize = @as(usize, @intCast(y)) * width + @as(usize, @intCast(x));
    return map[index];
}

fn scan(x: i32, y: i32) bool {
    const center = at(x, y) orelse return false;
    if (center != 'A') return false;

    const nw = at(x - 1, y + 1) orelse return false; // NW
    const ne = at(x + 1, y + 1) orelse return false; // NE
    const sw = at(x - 1, y - 1) orelse return false; // SW
    const se = at(x + 1, y - 1) orelse return false; // SE

    return isMAS(nw, se) and isMAS(ne, sw);
}

fn isMAS(a: u8, b: u8) bool {
    return (a == 'M' and b == 'S') or (a == 'S' and b == 'M');
}
