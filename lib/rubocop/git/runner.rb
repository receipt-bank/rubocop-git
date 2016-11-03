require 'shellwords'

module RuboCop
  module Git
    # ref. https://github.com/thoughtbot/hound/blob/d2f3933/app/services/build_runner.rb
    class Runner
      def run(options)
        options = Options.new(options) unless options.is_a?(Options)

        @options = options
        @files = DiffParser.parse(git_diff(options))

        display_violations($stdout)

        exit(1) if violations.any?
      end

      private

      def violations
        @violations ||= style_checker.violations
      end

      def style_checker
        StyleChecker.new(pull_request.pull_request_files,
                         @options.rubocop,
                         @options.config_file,
                         pull_request.config)
      end

      def pull_request
        @pull_request ||= PseudoPullRequest.new(@files, @options)
      end

      def git_diff(options)
        args = %w(diff --diff-filter=AMCR --find-renames --find-copies)

        args << '--cached' if options.cached
        if options.file
          args << (options.commit_first ? options.commit_first.shellescape : 'master')
          args << "--"
          args << options.file
        else
          args << options.commit_first.shellescape if options.commit_first
          args << options.commit_last.shellescape if options.commit_last
        end

        `git #{args.join(' ')}`
      end

      def display_violations(io)
        formatter = rubocop_formatter.new(io)
        formatter.started(nil)

        violations.map do |violation|
          formatter.file_finished(
            violation.filename,
            violation.offenses.compact.reject(&:disabled?).sort.freeze
          )
        end

        formatter.finished(@files.map(&:filename).freeze)
      end

      def rubocop_formatter
        if @options.format
          formatter = RuboCop::Formatter.constants.detect { |c|
            c.to_s.match /#{@options.format}/i
          }
          RuboCop::Formatter.const_get formatter
        else
          RuboCop::Formatter::ClangStyleFormatter
        end
      end
    end
  end
end
