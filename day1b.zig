const std = @import("std");
const input = @embedFile("day1_input.txt");

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        _ = gpa.deinit();
    }

    const allocator = gpa.allocator();
    const max_items = 1024;

    var left: [max_items]i32 = [_]i32{0} ** max_items;

    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    var i: usize = 0;

    var counts = std.AutoHashMap(i32, i32).init(allocator);
    defer counts.deinit();

    while (line_it.next()) |line| {
        var num_it = std.mem.tokenizeScalar(u8, line, ' ');

        const left_num = std.fmt.parseInt(i32, num_it.next().?, 10) catch unreachable;
        const right_num = std.fmt.parseInt(i32, num_it.next().?, 10) catch unreachable;

        const n = counts.get(right_num) orelse 0;
        counts.put(right_num, n + 1) catch unreachable;

        left[i] = left_num;
        i += 1;
    }

    const count = i + 1;
    var similarity_score: i32 = 0;

    for (0..count) |j| {
        const score = left[j] * (counts.get(left[j]) orelse 0);
        similarity_score += score;
    }

    std.debug.print("Answer = {d}\n", .{similarity_score});
}
