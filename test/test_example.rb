require_relative './helper'

# 1. Prepare example/your-project-000.json
# 2. embulk bundle
# 3. bundle exec ruby test/test_example.rb

unless File.exist?(JSON_KEYFILE)
  puts "#{JSON_KEYFILE} is not found. Skip test/test_example.rb"
else
  class TestExample < Test::Unit::TestCase
    def embulk_path
      if File.exist?("#{ENV['PATH']}/.embulk/bin/embulk")
        "#{ENV['PATH']}/.embulk/bin/embulk"
      elsif File.exist?("/usr/local/bin/embulk")
        "/usr/local/bin/embulk"
      else
        "embulk"
      end
    end

    def embulk_run(config_path)
      Bundler.with_clean_env do
        cmd = "#{embulk_path} run -X page_size=1 -b . -l trace #{config_path}"
        puts "=" * 64
        puts cmd
        system(cmd)
      end
    end

    files = Dir.glob("#{APP_ROOT}/example/config_*.yml").reject {|file| File.symlink?(file) }.sort
    files.each do |config_path|
      if %w[
        config_expose_errors.yml
        config_prevent_duplicate_insert.yml
        ].include?(File.basename(config_path))
        define_method(:"test_#{File.basename(config_path, ".yml")}") do
          assert_false embulk_run(config_path)
        end
      else
        define_method(:"test_#{File.basename(config_path, ".yml")}") do
          assert_true embulk_run(config_path)
        end
      end
    end
  end
end
