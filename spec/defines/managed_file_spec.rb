# frozen_string_literal: true

require 'spec_helper'

describe 'load_test::managed_file' do

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      if os_facts[:os]['name'] == 'windows'
        let(:title) { 'C:\test\ing' }
      else
        let(:title) { '/test/ing' }
      end
      let(:facts) { os_facts }
      let(:params) do
        {}
      end

      it { is_expected.to compile }
    end
  end
end
