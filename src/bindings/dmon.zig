pub const dmon_watch_id = extern struct { id: c_uint };

pub extern fn dmon_init() void;
pub extern fn dmon_deinit() void;
pub extern fn dmon_watch(
	rootdir: [*c]const u8,
	watch_cb: *const fn (
		watch_id: dmon_watch_id,
		action: c_uint,
		root_dir: [*c]const u8,
		file_path: [*c]const u8,
		old_file_path: [*c]const u8,
		data: ?*anyopaque,
	) callconv(.C) void,
	flags: c_uint,
	user_data: ?*anyopaque,
) dmon_watch_id;
pub extern fn dmon_unwatch(id: dmon_watch_id) void;
