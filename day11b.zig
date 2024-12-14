const std = @import("std");
const input = @embedFile("day11_input.txt");

const num_blinks = 75;

const CountParams = struct {
    stone: u64,
    blinks: u64,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        _ = gpa.deinit();
    }
    const allocator = gpa.allocator();

    var stones = std.ArrayList(u64).init(allocator);
    defer stones.deinit();

    var num_it = std.mem.tokenizeScalar(u8, input, ' ');
    while (num_it.next()) |num_str| {
        const num = std.fmt.parseInt(u64, num_str, 10) catch continue;
        try stones.append(num);
    }

    var memo = std.AutoHashMap(CountParams, u64).init(allocator);
    defer memo.deinit();

    var count: u64 = 0;
    for (stones.items) |stone| {
        count += try countStones(stone, num_blinks, &memo);
    }

    std.debug.print("Answer = {d}\n", .{count});
}

fn numDigits(x: u64) u64 {
    var count: u64 = 1;
    var n = x;
    while (n > 9) : (n /= 10) count += 1;
    return count;
}

fn countStones(stone: u64, blinks: u64, memo: *std.AutoHashMap(CountParams, u64)) !u64 {
    const params = CountParams{ .stone = stone, .blinks = blinks };
    if (memo.get(params)) |result| {
        return result;
    }

    if (blinks == 0) {
        return 1; // A single stone remains.
    }

    var result: u64 = 0;

    if (stone == 0) {
        result = try countStones(1, blinks - 1, memo);
    } else if (numDigits(stone) % 2 == 0) {
        const stones = try split(stone);
        result = try countStones(stones[0], blinks - 1, memo) + try countStones(stones[1], blinks - 1, memo);
    } else {
        result = try countStones(stone * 2024, blinks - 1, memo);
    }

    try memo.put(params, result);
    return result;
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
