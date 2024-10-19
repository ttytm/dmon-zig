const std = @import("std");
const dmon = @import("dmon");
const print = std.debug.print;

const Context = struct {
	trigger_count: u32 = 0,
};

pub fn watchCb(
	comptime Ctx: type,
	_: dmon.WatchId,
	action: dmon.Action,
	root_dir: [*:0]const u8,
	file_path: [*:0]const u8,
	old_file_path: ?[*:0]const u8,
	context: *Ctx,
) void {
	print("Action: {}\n", .{action});
	print("Root: {s}\n", .{root_dir});
	print("File path: {s}\n", .{file_path});
	print("Old file path: {s}\n", .{old_file_path orelse ""});
	context.trigger_count += 1;
}

pub fn main() !void {
	var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
	defer arena.deinit();
	const alloc = arena.allocator();

	dmon.init();
	defer dmon.deinit();

	var ctx = Context{ .trigger_count = 0 };
	const cwd_path = try std.fs.cwd().realpathAlloc(alloc, ".");
	const z_path = try alloc.dupeZ(u8, cwd_path);

	const id = dmon.watch(Context, z_path, watchCb, .{ .recursive = true }, &ctx);
	print("Starting to watch: {s}; Watcher ID: {d}\n", .{ z_path, id });

	while (true) {
		if (ctx.trigger_count >= 3) break;
		// Slow down loop interval, reduce load.
		std.time.sleep(100 * std.time.ms_per_s);
	}
}
