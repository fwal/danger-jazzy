require File.expand_path('../spec_helper', __FILE__)

module Danger
  describe Danger::DangerJazzy do
    it 'should be a plugin' do
      expect(Danger::DangerJazzy.new(nil)).to be_a Danger::Plugin
    end

    #
    # You should test your custom attributes and methods here
    #
    describe 'with Dangerfile' do
      before do
        @dangerfile = testing_dangerfile
        @my_plugin = @dangerfile.jazzy
        @default_message = 'Undocumented symbol.'
        @my_plugin.path = 'spec/fixtures'
      end

      context 'changed files contains undocumented symbols' do
        before do
          modified = Git::Diff::DiffFile.new(
            'base',
            path:  'OldFile.swift',
            patch: '- //old'
          )
          added = Git::Diff::DiffFile.new(
            'base',
            path:  'MyFile.swift',
            patch: '+ //new'
          )

          allow(@dangerfile.git).to receive(:diff_for_file)
            .with('OldFile.swift').and_return(modified)

          allow(@dangerfile.git).to receive(:diff_for_file)
            .with('MyFile.swift').and_return(added)

          allow(@dangerfile.git).to receive(:modified_files)
            .and_return(['OldFile.swift'])

          allow(@dangerfile.git).to receive(:added_files)
            .and_return(['MyFile.swift'])
        end

        it 'finds undocumented symbols only in modified files by default' do
          expect(@my_plugin.undocumented.length).to eq(1)
        end

        it 'can find undocumented symbols in all files' do
          expect(@my_plugin.undocumented(:all).length).to eq(2)
        end

        it 'fails on undocumented symbols only in modified files by default' do
          @my_plugin.check
          expect(@dangerfile.status_report[:errors]).to eq([@default_message])
        end

        it 'does not warn on undocumented symbols by default' do
          @my_plugin.check
          expect(@dangerfile.status_report[:warnings]).to eq([])
        end

        it 'can fail on undocumented symbols in all files' do
          @my_plugin.check fail: :all
          expect(@dangerfile.status_report[:errors]).to eq([@default_message, @default_message])
        end

        it 'can warn on undocumented symbols in all files' do
          @my_plugin.check warn: :all
          expect(@dangerfile.status_report[:warnings]).to eq([@default_message, @default_message])
        end

        it 'does not fail if there is no undocumented json' do
          @my_plugin.path = 'spec/empty'
          @my_plugin.check
          expect(@dangerfile.status_report[:errors]).to eq([])
        end
      end
    end
  end
end
