const std = @import("std");
const input = @embedFile("day9_input.txt");

// A block is either -1 (free space) or a file ID.
const Block = i16;

// A span of blocks.
const BlockSpan = struct {
    start: usize,
    len: usize,
};

const free_space: Block = -1;

// In this input the total disk size is 95,307.
var disk_buf: [100_000]Block = undefined;
var disk_len: usize = 0;

var free_spans: [10_000]BlockSpan = undefined;
var free_spans_len: usize = 0;

var file_spans: [10_000]BlockSpan = undefined;
var file_spans_len: usize = 0;

pub fn main() !void {
    readInput();
    defragment();

    const answer = checksum(disk_buf[0..disk_len]);
    std.debug.print("Answer = {d}\n", .{answer});
}

fn readInput() void {
    var id: i16 = 0;
    var is_file = true;

    for (0..input.len) |i| {
        const num_blocks = std.fmt.parseInt(u8, input[i .. i + 1], 10) catch continue;
        var block_value = free_space;
        if (is_file) {
            block_value = id;
            id += 1;
        }
        const start = disk_len;
        for (0..num_blocks) |_| {
            disk_buf[disk_len] = block_value;
            disk_len += 1;
        }
        if (is_file) {
            file_spans[file_spans_len] = .{ .start = start, .len = num_blocks };
            file_spans_len += 1;
        } else {
            free_spans[free_spans_len] = .{ .start = start, .len = num_blocks };
            free_spans_len += 1;
        }
        is_file = !is_file;
    }
}

fn spanSlice(span: BlockSpan) []Block {
    return disk_buf[span.start .. span.start + span.len];
}

fn defragment() void {
    var i = file_spans_len;
    while (i > 0) : (i -= 1) {
        const file_span = file_spans[i - 1];
        for (0..free_spans_len) |j| {
            const free_span = free_spans[j];
            // Free span is to the right of the file on disk.
            if (free_span.start > file_span.start) break;
            // If there is enough free space then move the file into the free space.
            if (free_span.len >= file_span.len) {
                const free_blocks = spanSlice(free_span);
                const file_blocks = spanSlice(file_span);
                @memcpy(free_blocks[0..file_span.len], file_blocks);
                @memset(file_blocks, free_space);
                free_spans[j] = .{
                    .start = free_span.start + file_span.len,
                    .len = free_span.len - file_span.len,
                };
                break;
            }
        }
    }
}

fn checksum(disk: []Block) u64 {
    var n: u64 = 0;
    for (disk, 0..) |block, pos| {
        if (block == free_space) continue;
        n += @as(u64, @intCast(pos)) * @as(u64, @intCast(disk[pos]));
    }
    return n;
}
