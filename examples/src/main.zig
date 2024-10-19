const std = @import("std");
const dmon = @import("dmon");
const print = std.debug.print;

const Context = struct {
	triggerCount: u32 = 0,
};

pub fn watchCb(
	watch_id: dmon.WatchId,
	action: dmon.Action,
	root_dir: [*:0]const u8,
	file_path: [*:0]const u8,
	old_file_path: ?[*:0]const u8,
	context: ?*anyopaque,
) void {
	_ = watch_id;
	print("Action: {}\n", .{action});
	print("Root: {s}\n", .{root_dir});
	print("File path: {s}\n", .{file_path});
	print("Old file path: {s}\n", .{old_file_path orelse ""});
	var ctx: *Context = @ptrCast(@alignCast(context));
	ctx.triggerCount += 1;
}

pub fn main() void {
	dmon.init();
	defer dmon.deinit();

	var ctx = Context{ .triggerCount = 0 };
	const id = dmon.watch("/home/t/Sync/Dev/Zig", watchCb, .{ .recursive = true }, &ctx);
	print("Watch ID: {d}\n", .{id});

	while (true) {
		if (ctx.triggerCount >= 3) break;
		// Slow down loop interval, reduce load.
		std.time.sleep(100 * std.time.ms_per_s);
	}
}
