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

        it 'Warns on undocumented symbols' do
          @my_plugin.path_to_docs = 'spec/fixtures'
          @my_plugin.warn_of_undocumented
          expect(@dangerfile.status_report[:warnings]).to eq(['Undocumented symbol.'])
        end
      end
    end
  end
end
