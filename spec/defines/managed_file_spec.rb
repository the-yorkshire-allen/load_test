# frozen_string_literal: true

require 'spec_helper'

describe 'load_test::managed_file' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      if os_facts[:os]['family'] == 'windows'
        let(:title) { 'C:\test\ing' }
      else
        let(:title) { '/test/ing' }
      end

      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to have_file_resource_count(1) }
      it { is_expected.to contain_file(title) }
    end
  end
end
