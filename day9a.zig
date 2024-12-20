const std = @import("std");
const input = @embedFile("day9_input.txt");

pub fn main() !void {
    const free_space: u64 = 0;

    // In this input the total disk size is 95,307.
    var disk: [100_000]u64 = undefined;
    var len: usize = 0;
    // Use 1-based indexing and treat 0s as free blocks. We can fix up the ID later when
    // calculating the checksum.
    var id: u64 = 1;
    var is_file = true;

    for (0..input.len) |i| {
        const num = std.fmt.parseInt(u8, input[i .. i + 1], 10) catch continue;
        var block_value = free_space;
        if (is_file) {
            block_value = id;
            id += 1;
        }
        for (0..num) |_| {
            disk[len] = block_value;
            len += 1;
        }
        is_file = !is_file;
    }

    var left: usize = 0;
    var right: usize = len - 1;

    while (true) {
        while (disk[left] != free_space) left += 1;
        while (disk[right] == free_space) right -= 1;
        if (left >= right) break;
        disk[left] = disk[right];
        disk[right] = free_space;
    }

    var checksum: u64 = 0;
    for (0..right + 1) |pos| {
        const file_id = disk[pos] - 1; // Adjust back to 0-based indexing.
        checksum += pos * file_id;
    }

    std.debug.print("Answer = {d}\n", .{checksum});
}
