require 'diffy'
require 'csv'
require "csv_diff/version"

module CsvDiff
  class Detector
    def call(old_file, new_file)
      group_changes(changed_lines(old_file, new_file))
    end

  private

    def changed_lines(old_file, new_file)
      Diffy::Diff.new(old_file, new_file, source: 'files', include_diff_info: false, context: false)
        .map { |line| line[/^[+-]/] ? line : nil }
        .compact.flatten
    end

    def group_changes(changed_lines)
      changed_lines
        .group_by { |line| line[/\d+/] }
        .map { |_id, data| parse_changes(data) }
    end

    def parse_changes(data)
      hash = {}
      data.each do |line|
        case line[0]
        when '+' then hash[:new] = parse_change(line)
        when '-' then hash[:old] = parse_change(line)
        end
      end
      hash
    end

    def parse_change(line)
      return unless line
      CSV.parse(line[1..-1]).first
    end
  end
end

