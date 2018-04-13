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
        @my_plugin.message = @default_message
        @my_plugin.inline_message = @default_message
      end

      context 'containing changed files with undocumented symbols' do
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
          expect(@my_plugin.undocumented(:all).length).to eq(4)
        end

        it 'fails only in modified files by default' do
          @my_plugin.check
          expect(@dangerfile.status_report[:errors]).to eq([@default_message])
        end

        it 'does not warn by default' do
          @my_plugin.check
          expect(@dangerfile.status_report[:warnings]).to eq([])
        end

        it 'can fail in all files' do
          @my_plugin.check fail: :all
          expect(@dangerfile.status_report[:errors].length).to eq(4)
        end

        it 'can warn in all files' do
          @my_plugin.check warn: :all
          expect(@dangerfile.status_report[:warnings].length).to eq(4)
        end

        it 'does not fail if there is no undocumented json' do
          @my_plugin.path = 'spec/empty'
          @my_plugin.check
          expect(@dangerfile.status_report[:errors]).to eq([])
        end

        it 'ignores files listed in ignore' do
          @my_plugin.ignore = ['MyFile.swift']
          @my_plugin.check
          expect(@dangerfile.status_report[:errors]).to eq([])
        end

        it 'uses templates for violations' do
          @my_plugin.inline_message = '%<symbol>s in %<file>s'
          @my_plugin.check
          expect(@dangerfile.status_report[:errors]).to eq(
            ['MyClass.doStuff() in MyFile.swift']
          )
        end

        it 'can switch template' do
          @my_plugin.ignore = ['MyFile.swift']
          @my_plugin.message = '%<symbol>s in %<file>s'
          @my_plugin.inline_message = '%<symbol>s'
          @my_plugin.check fail: :all

          fixture = [
            'MyStruct.handleThing()',
            'MyClass in MyExtensionFile.swift',
            'MyClass in MyExtensionFile.swift'
          ]
          expect(@dangerfile.status_report[:errors]).to eq(fixture)
        end
      end
    end
  end
end
