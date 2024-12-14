const std = @import("std");
const input = @embedFile("day10_input.txt");

var map: [width * width]u8 = undefined;

const width: usize = 56;
var height: usize = 0;

const trail_head: u8 = 9;
const trail_start: u8 = 0;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        _ = gpa.deinit();
    }
    const allocator = gpa.allocator();

    var row_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (row_it.next()) |row| : (height += 1) {
        const map_row = map[height * width ..];
        for (0..row.len) |i| {
            map_row[i] = try std.fmt.parseInt(u8, row[i .. i + 1], 10);
        }
    }

    var start_positions = std.ArrayList(usize).init(allocator);
    defer start_positions.deinit();

    var result: usize = 0;

    for (0..height) |y_index| {
        for (0..width) |x_index| {
            const x: i32 = @intCast(x_index);
            const y: i32 = @intCast(y_index);
            const h = at(x, y).?;
            if (h == trail_head) {
                try search(x, y, trail_head + 1, &start_positions);
                result += start_positions.items.len;
                start_positions.clearRetainingCapacity();
            }
        }
    }

    std.debug.print("Answer = {d}\n", .{result});
}

fn at(x: i32, y: i32) ?u8 {
    if (x < 0 or x >= width or y < 0 or y >= height) return null;
    return map[index(x, y)];
}

fn index(x: i32, y: i32) usize {
    return @intCast(x * @as(i32, @intCast(height)) + y);
}

fn search(x: i32, y: i32, prev_height: u8, start_positions: *std.ArrayList(usize)) !void {
    const curr_height = at(x, y) orelse return;
    if (prev_height <= curr_height or (prev_height - curr_height) != 1) return;
    if (curr_height == trail_start) {
        try start_positions.append(index(x, y));
    } else {
        try search(x - 1, y, curr_height, start_positions);
        try search(x + 1, y, curr_height, start_positions);
        try search(x, y - 1, curr_height, start_positions);
        try search(x, y + 1, curr_height, start_positions);
    }
}
