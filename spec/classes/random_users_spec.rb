# frozen_string_literal: true

require 'spec_helper'

describe 'load_test::random_users' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to have_user_resource_count(20) }
      it { is_expected.to have_group_resource_count(20) }
      it { is_expected.to have_ssh_authorized_key_resource_count(10) } # count based on fqdn_random()
    end
  end
end
