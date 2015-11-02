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
      name_for_config = [fileset.host.name, fileset.name].join(' ')
      expect(subject).to include("  Name = \"#{name_for_config}\"")
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

  context 'when no include_files are given' do
    let(:fileset) { FactoryGirl.build(:fileset, include_files: []) }

    it 'does not save the fileset' do
      expect(fileset).to have(1).errors_on(:include_files)
    end
  end

  context 'when blank include_files are given' do
    let(:fileset) { FactoryGirl.create(:fileset, include_files: [:foo, '']) }
    it 'rejects them' do
      expect(fileset.include_directions['file']).to eq(['foo'])
    end
  end
end
