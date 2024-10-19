const std = @import("std");
const bindings = @import("bindings/dmon.zig");

// Ref.: `dmon_action_t`
pub const Action = enum(c_uint) {
	create = 1,
	delete,
	modify,
	move,
};

// Ref.: `dmon_watch_flags_t`
pub const WatchFlags = packed struct {
	recursive: bool = false,
	follow_symlinks: bool = false,
};

pub const WatchId = u32;

pub fn init() void {
	bindings.dmon_init();
}

pub fn deinit() void {
	bindings.dmon_deinit();
}

/// Starts to watch the `root_dir` and triggers the given `callback` on changes.
pub fn watch(
	comptime Context: type,
	root_dir: [*:0]const u8,
	callback: fn (
		comptime Context: type,
		WatchId,
		action: Action,
		root_dir: [*:0]const u8,
		file_path: [*:0]const u8,
		old_file_path: ?[*:0]const u8,
		data: *Context,
	) void,
	flags: WatchFlags,
	context: *Context,
) WatchId {
	const cbHandler = struct {
		fn handle(
			watch_id: bindings.dmon_watch_id,
			action: c_uint,
			root_dir_: [*c]const u8,
			file_path: [*c]const u8,
			old_file_path: [*c]const u8,
			user_data: ?*anyopaque,
		) callconv(.C) void {
			const ptr: *Context = @alignCast(@ptrCast(user_data));
			callback(Context, watch_id.id, @enumFromInt(action), root_dir_, file_path, old_file_path, ptr);
		}
	};
	var c_flags: c_uint = 0;
	if (flags.recursive) c_flags |= 0x1;
	if (flags.follow_symlinks) c_flags |= 0x2;
	return bindings.dmon_watch(root_dir, cbHandler.handle, c_flags, context).id;
}

/// Stops watching the given `WatchId`.
pub fn unwatch(id: WatchId) void {
	bindings.dmon_unwatch(bindings.dmon_watch_id{id});
}
