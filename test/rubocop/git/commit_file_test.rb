require_relative '../../test_helper'
require 'rubocop/git/commit_file'

describe RuboCop::Git::CommitFile do
  describe 'ruby files check' do
    it 'returns true for .rb files' do
      assert ruby_commit_file('filename.rb')
    end

    it 'returns true for .rake files' do
      assert ruby_commit_file('filename.rake')
    end

    it 'returns true for Gemfile' do
      assert ruby_commit_file('Gemfile')
    end

    it 'returns true for Rakefile' do
      assert ruby_commit_file('Rakefile')
    end

    it 'returns true for Guardfile' do
      assert ruby_commit_file('Guardfile')
    end

    it 'returns true for Procfile' do
      assert ruby_commit_file('Procfile')
    end

    it 'returns nil for Gemfile.lock' do
      assert_nil ruby_commit_file('Gemfile.lock')
    end
  end

  def double(*args)
    OpenStruct.new(*args)
  end

  def ruby_commit_file(filename)
    file = double filename: filename

    RuboCop::Git::CommitFile.new(file, nil).ruby?
  end
end
