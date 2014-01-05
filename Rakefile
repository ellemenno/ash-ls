# encoding: utf-8

require 'etc'
require 'fileutils'
require 'json'
require 'rake/clean'

@lib_loom_config = nil
@test_loom_config = nil

CLEAN.include ["lib/build/**", "test/bin/**", "test/build/**"]


task :default => :list_targets

task :list_targets do |t, args|
	puts "Ash Rakefile running on Ruby #{RUBY_VERSION}"
	system("rake -T")
	puts ''
end

file "lib/build/Ash.loomlib" do |t, args|
	sdk_version = lib_config['sdk_version']
	Dir.chdir("lib") do
		cmd = %Q[#{sdk_root}/#{sdk_version}/tools/lsc ash.build]
		abort("◈ failed to compile .loomlib") if (exec_with_echo(cmd) != 0)
	end
end

file "test/bin/Main.loom" => "lib/build/Ash.loomlib" do |t, args|
	sdk_version = test_config['sdk_version']
	file_installed = "#{sdk_root}/#{sdk_version}/libs/Ash.loomlib"
	file_built = ["lib/build/Ash.loomlib"]

	Rake::Task["lib:install"].invoke unless FileUtils.uptodate?(file_installed, file_built)

	Dir.chdir("test") do
		cmd = %Q[#{sdk_root}/#{sdk_version}/tools/lsc]
		abort("◈ failed to compile .loom") if (exec_with_echo(cmd) != 0)
	end
end

namespace :lib do

	desc "builds Ash.loomlib for the SDK specified in lib/loom.config"
	task :build => "lib/build/Ash.loomlib" do |t, args|
		puts "[#{t.name}] task completed, find .loomlib in lib/build/"
		puts ''
	end

	desc "prepares sdk-specific Ash.loomlib for release"
	task :release => "lib/build/Ash.loomlib" do |t, args|
		lib = 'lib/build/Ash.loomlib'
		sdk = test_config['sdk_version']
		ext = '.loomlib'
		release_dir = 'releases'

		Dir.mkdir(release_dir) unless File.exists?(release_dir)

		lib_release = %Q[#{File.basename(lib, ext)}-#{sdk}#{ext}]
		FileUtils.copy(lib, "#{release_dir}/#{lib_release}")

		puts "[#{t.name}] task completed, find #{lib_release} in #{release_dir}/"
		puts ''
	end

	desc "installs Ash.loomlib into the SDK specified in lib/loom.config"
	task :install => "lib/build/Ash.loomlib" do |t, args|
		lib = 'lib/build/Ash.loomlib'
		sdk_version = lib_config['sdk_version']
		libs_path = "#{sdk_root}/#{sdk_version}/libs"

		cmd = %Q[cp #{lib} #{libs_path}]
		abort("◈ failed to install lib") if (exec_with_echo(cmd) != 0)

		puts "[#{t.name}] task completed, Ash.loomlib installed for #{sdk_version}"
		puts ''
	end

	desc "removes Ash.loomlib from the SDK specified in lib/loom.config"
	task :uninstall do |t, args|
		sdk_version = lib_config['sdk_version']
		lib = "#{sdk_root}/#{sdk_version}/libs/Ash.loomlib"

		if (File.exists?(lib))
			cmd = %Q[rm -f #{lib}]
			abort("◈ failed to remove lib") if (exec_with_echo(cmd) != 0)
			puts "[#{t.name}] task completed, Ash.loomlib removed from #{sdk_version}"
		else
			puts "[#{t.name}] nothing to do;  no Ash.loomlib found in #{sdk_version} sdk"
		end
		puts ''
	end

	desc "lists libs installed for the SDK specified in lib/loom.config"
	task :show do |t, args|
		sdk_version = lib_config['sdk_version']
		cmd = %Q[ls -l #{sdk_root}/#{sdk_version}/libs]
		abort("◈ failed to list contents of #{sdk_version} libs directory") if (exec_with_echo(cmd) != 0)
		puts ''
	end

end

namespace :test do

	desc "builds AshTest as Main.loom with the SDK specified in test/loom.config"
	task :build => "test/bin/Main.loom" do |t, args|
		puts "[#{t.name}] task completed, find .loom in test/bin/"
		puts ''
	end

	desc "runs AshTest (Main.loom)"
	task :run => "test/bin/Main.loom" do |t, args|
		sdk_version = test_config['sdk_version']

		Dir.chdir("test") do
			# magically, this binary loads bin/Main.loom from the current directory
			cmd = %Q[#{sdk_root}/#{sdk_version}/bin/LoomDemo.app/Contents/MacOS/LoomDemo]
			abort("◈ failed to run .loom") if (exec_with_echo(cmd) != 0)
		end
	end

end


def lib_config
	@lib_loom_config || (@lib_loom_config = JSON.parse(File.read('lib/loom.config')))
end

def test_config
	@test_loom_config || (@test_loom_config = JSON.parse(File.read('test/loom.config')))
end

def sdk_root
	"/Users/#{Etc.getlogin}/.loom/sdks"
end

def exec_with_echo(cmd)
	puts(cmd)
	stdout = %x[#{cmd}]
	puts(stdout) unless stdout.empty?
	$?.exitstatus
end