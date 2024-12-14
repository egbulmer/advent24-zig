const std = @import("std");
const input = @embedFile("day11_input.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        _ = gpa.deinit();
    }
    const allocator = gpa.allocator();

    var stones1 = std.ArrayList(u64).init(allocator);
    defer stones1.deinit();

    var stones2 = std.ArrayList(u64).init(allocator);
    defer stones2.deinit();

    var num_it = std.mem.tokenizeScalar(u8, input, ' ');
    while (num_it.next()) |num_str| {
        const num = std.fmt.parseInt(u64, num_str, 10) catch continue;
        try stones1.append(num);
    }

    var stones_in = &stones1;
    var stones_out = &stones2;

    for (0..25) |_| {
        for (stones_in.items) |stone| {
            try update(stone, stones_out);
        }
        const tmp = stones_in;
        stones_in = stones_out;
        stones_out = tmp;
        stones_out.clearRetainingCapacity();
    }

    std.debug.print("Answer = {d}\n", .{stones_in.items.len});
}

fn numDigits(x: u64) u64 {
    var count: u64 = 1;
    var n = x;
    while (n > 9) : (n /= 10) count += 1;
    return count;
}

fn update(stone: u64, result: *std.ArrayList(u64)) !void {
    if (stone == 0) {
        try result.append(1);
    } else if (numDigits(stone) % 2 == 0) {
        const stones = try split(stone);
        try result.append(stones[0]);
        try result.append(stones[1]);
    } else {
        try result.append(stone * 2024);
    }
}

// The largest number an unsigned 64-bit integer can hold is 20 digits long.
var fmt_buf: [20]u8 = undefined;

fn split(stone: u64) ![2]u64 {
    // FIXME: Must be a faster way?
    const str = try std.fmt.bufPrint(&fmt_buf, "{d}", .{stone});
    const a = try std.fmt.parseInt(u64, str[0 .. str.len / 2], 10);
    const b = try std.fmt.parseInt(u64, str[str.len / 2 ..], 10);
    return [_]u64{ a, b };
}
