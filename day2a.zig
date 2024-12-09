const std = @import("std");
const input = @embedFile("day2_input.txt");

pub fn main() void {
    var safe_reports: u32 = 0;
    var nums: [8]i32 = [_]i32{0} ** 8;

    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_it.next()) |line| {
        var num_it = std.mem.tokenizeScalar(u8, line, ' ');

        var i: usize = 0;
        while (num_it.next()) |str| {
            nums[i] = std.fmt.parseInt(i32, str, 10) catch unreachable;
            i += 1;
        }

        if (isSafe(nums[0..i])) {
            safe_reports += 1;
        }
    }

    std.debug.print("Answer = {d}\n", .{safe_reports});
}

fn isSafe(nums: []i32) bool {
    const dir = nums[0] - nums[1];
    for (0..nums.len - 1) |i| {
        const delta = nums[i] - nums[i + 1];
        if (delta == 0 or (delta < 0 and dir > 0) or (delta > 0 and dir < 0)) return false;

        const n = @abs(delta);
        if (n < 1 or n > 3) return false;
    }
    return true;
}
