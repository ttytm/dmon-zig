# dmon-zig

[badge__build-status]: https://img.shields.io/github/actions/workflow/status/ttytm/dmon-zig/ci.yml?branch=main&logo=github&logoColor=C0CAF5&labelColor=333
[badge__version-lib]: https://img.shields.io/github/v/tag/ttytm/dmon-zig?logo=task&logoColor=C0CAF5&labelColor=333&color=
[badge__version-zig]: https://img.shields.io/badge/Zig-0.13.0-cc742f?logo=zig&logoColor=C0CAF5&labelColor=333

[![][badge__build-status]](https://github.com/ttytm/dmon-zig/actions?query=branch%3Amain)
[![][badge__version-lib]](https://github.com/ttytm/dmon-zig/releases/latest)
![][badge__version-zig]

Cross-platform Zig module to monitor changes in directories.
It utilizes the [dmon](https://github.com/septag/dmon?tab=readme-ov-file) C99 library.

## Installation

```sh
# ~/<ProjectsPath>/your-awesome-projct
zig fetch --save https://github.com/ttytm/dmon-zig/archive/main.tar.gz
```

```zig
// your-awesome-projct/build.zig
const std = @import("std");

pub fn build(b: *std.Build) void {
	// ..
	const dmon_dep = b.dependency("dmon", .{});
	const exe = b.addExecutable(.{
		.name = "your-awesome-projct",
		// ..
	});
	exe.root_module.addImport("dmon", dmon_dep.module("dmon"));
	// ...
}
```

## Usage Example

```v
const std = @import("std");
const dmon = @import("dmon");
const print = std.debug.print;

const Context = struct {
	triggerCount: u32 = 0,
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
	context.triggerCount += 1;
}

pub fn main() !void {
	dmon.init();
	defer dmon.deinit();

	const watch_path = "/home/user/Documents";
	const id = dmon.watch(Context, watch_path, watchCb, .{ .recursive = true }, &ctx);
	print("Starting to watch: {s}; Watcher ID: {d}\n", .{ watch_path, id });

	while (true) {
		if (ctx.triggerCount >= 3) break;
	}
}
```

Simple example watching the cwd: [`dmon-zig/examples/src/main.zig`](https://github.com/ttytm/dmon-zig/blob/main/examples/src/main.zig)

```sh
# dmon-zig/examples
zig build run
```
