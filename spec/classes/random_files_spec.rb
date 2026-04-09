# frozen_string_literal: true

require 'spec_helper'

describe 'load_test::random_files' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to have_load_test__managed_file_resource_count(30) }

      base_path = if os_facts[:os]['family'] == 'windows'
                    'c:\tmp\puppet_test'
                  else
                    '/tmp/puppet_test'
                  end

      it { is_expected.to contain_file(base_path).only_with_ensure('directory') }
    end
  end
end
