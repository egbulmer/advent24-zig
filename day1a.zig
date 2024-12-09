const std = @import("std");
const input = @embedFile("day1_input.txt");

pub fn main() void {
    const max_items = 1024;

    var left: [max_items]i32 = [_]i32{0} ** max_items;
    var right: [max_items]i32 = [_]i32{0} ** max_items;

    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    var i: usize = 0;

    while (line_it.next()) |line| {
        var num_it = std.mem.tokenizeScalar(u8, line, ' ');

        const left_field = num_it.next() orelse unreachable;
        const right_field = num_it.next() orelse unreachable;

        left[i] = std.fmt.parseInt(i32, left_field, 10) catch unreachable;
        right[i] = std.fmt.parseInt(i32, right_field, 10) catch unreachable;

        i += 1;
    }

    const count = i + 1;

    std.mem.sort(i32, left[0..count], {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, right[0..count], {}, comptime std.sort.asc(i32));

    var distance: u32 = 0;

    for (0..count) |j| {
        distance += @abs(left[j] - right[j]);
    }

    std.debug.print("Answer = {d}\n", .{distance});
}
