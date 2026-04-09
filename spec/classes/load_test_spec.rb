# frozen_string_literal: true

require 'spec_helper'

describe 'load_test' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      base_path = if os_facts[:os]['family'] == 'windows'
                    'c:\tmp\puppet_test'
                  else
                    '/tmp/puppet_test'
                  end

      it do
        is_expected.to contain_class('load_test::random_files').only_with(
          {
            'count'              => 30,
            'base_path'          => base_path,
            'file_ratio'         => 0.7,
            'max_content_length' => 1_000,
            'create_subdirs'     => true,
            'max_depth'          => 3,
          },
        )
      end

      it do
        is_expected.to contain_class('load_test::random_services_packages').only_with(
          {
            'service_count'         => 20,
            'package_count'         => 50,
            'service_ensure_ratio'  => 0.8,
            'package_ensure_ratio'  => 0.9,
            'service_enable_ratio'  => 0.7,
            'multi_provider'        => true,
            'delay_random'          => true,
          },
        )
      end

      it do
        is_expected.to contain_class('load_test::random_users').only_with(
          {
            'user_count'        => 20,
            'group_count'       => 20,
            'create_homes'      => 0.8,
            'system_user_ratio' => 0.3,
            'user_ensure_ratio' => 0.9,
            'password_max_age'  => 90,
            'create_ssh_keys'   => 0.6,
            'uid_gid_min'       => 1_000,
            'uid_gid_max'       => 60_000,
          },
        )
      end
    end
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os} with scaling_facter set to valid 2.0" do
      let(:facts) { os_facts }
      let(:params) { { scale_factor: 2.42 } }

      it { is_expected.to contain_class('load_test::random_files').with_count(73) }
      it { is_expected.to contain_class('load_test::random_services_packages').with_service_count(48) }
      it { is_expected.to contain_class('load_test::random_services_packages').with_package_count(121) }
      it { is_expected.to contain_class('load_test::random_users').with_user_count(48) }
      it { is_expected.to contain_class('load_test::random_users').with_group_count(48) }
    end
  end
end
