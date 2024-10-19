const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
	const target = b.standardTargetOptions(.{});
	const optimize = b.standardOptimizeOption(.{});

	const module = b.addModule("dmon", .{
		.root_source_file = b.path("src/lib.zig"),
		.target = target,
		.optimize = optimize,
		.link_libc = true,
	});
	module.addCSourceFile(.{ .file = b.path("src/bindings/dmon.c"), .flags = &[_][]const u8{"-DDMON_IMPL"} });
	module.addIncludePath(b.path("src/bindings/dmon"));
	if (builtin.os.tag.isDarwin()) {
		module.linkFramework("CoreServices", .{});
	}
}
