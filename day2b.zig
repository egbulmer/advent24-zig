const std = @import("std");
const input = @embedFile("day2_input.txt");

pub fn main() void {
    var safe_reports: u32 = 0;
    var nums1: [8]i32 = [_]i32{0} ** 8;
    var nums2: [7]i32 = [_]i32{0} ** 7;

    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_it.next()) |line| {
        var num_it = std.mem.tokenizeScalar(u8, line, ' ');

        var i: usize = 0;
        while (num_it.next()) |str| {
            nums1[i] = std.fmt.parseInt(i32, str, 10) catch unreachable;
            i += 1;
        }

        if (isSafe(nums1[0..i])) {
            safe_reports += 1;
            continue;
        }

        for (0..i) |index| {
            dampen(nums1[0..i], nums2[0 .. i - 1], index);
            if (isSafe(nums2[0 .. i - 1])) {
                safe_reports += 1;
                break;
            }
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

fn dampen(report: []i32, modified: []i32, index: usize) void {
    var j: usize = 0;
    for (0..report.len) |i| {
        if (i != index) {
            modified[j] = report[i];
            j += 1;
        }
    }
}
