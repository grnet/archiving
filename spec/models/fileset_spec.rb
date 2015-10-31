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

  context 'when duplicate exclude_directions are given' do
    let(:fileset) { FactoryGirl.create(:fileset, exclude_directions: [:foo, :foo, :bar]) }

    it 'keeps its exclude_directions uniq' do
      expect(fileset.exclude_directions).to eq([:foo, :bar])
    end
  end

  context 'when exclude_directions are given' do
    let(:fileset) { FactoryGirl.create(:fileset, exclude_directions: [:foo, :foo, :bar, '']) }

    it 'rejects them' do
      expect(fileset.exclude_directions).to eq([:foo, :bar])
    end
  end
end
