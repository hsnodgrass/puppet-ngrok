require 'spec_helper'

describe 'ngrok' do
  let(:facts) do
    {
      'kernel' => 'Linux',
    }
  end

  # With the default parameters, it should manage and notify the service.
  context 'with service_manage => true' do
    it do
      is_expected.to contain_concat('/etc/ngrok.yml').that_notifies('Service[ngrok]')
      is_expected.to contain_service('ngrok')
    end
  end

  # But with service_manage set to false, don't manage the service or notify it
  context 'with service_manage => false' do
    let(:params) { { 'service_manage' => false } }
    it do
      is_expected.to contain_concat('/etc/ngrok.yml').without('notify')
    end
  end

end

