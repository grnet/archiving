require 'spec_helper'

describe Fileset do
  describe '#to_bacula_config_array' do
    let(:fileset) do
      FactoryGirl.create(:fileset, name: 'Test Fileset',
                         exclude_directions: Fileset::DEFAULT_EXCLUDED,
                         include_directions: { options: Fileset::DEFAULT_INCLUDE_OPTIONS,
                                               file: Fileset::DEFAULT_INCLUDE_FILE_LIST }
                        )
    end

    subject { fileset.to_bacula_config_array }

    it 'is a Fileset type resource' do
      expect(subject.first).to eq('FileSet {')
      expect(subject.last).to eq('}')
    end

    it 'contains the name' do
      expect(subject).to include("  Name = \"#{fileset.name}\"")
    end
  end
end
