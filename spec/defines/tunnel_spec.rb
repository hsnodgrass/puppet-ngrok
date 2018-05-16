require 'spec_helper'

describe 'ngrok::tunnel' do
  let(:title) { 'webhook' }
  let(:params) do
    {
      'tunnel_name' => 'webhook',
      'proto'       => 'tcp',
      'addr'        => '8170',
    }
  end
  let(:node_params) do
    {
      'ngrok::conf_dir' => '/etc',
    }
  end

  # Does it get the heading fragment right?
  it do
    is_expected.to contain_concat_fragment('tunnels heading').with({
      'target'  => '/etc/ngrok.yml',
      'order'   => '50',
      'content' => "tunnels:\n",
    })
  end

  # And does it get the body fragment right?
  it do
    is_expected.to contain_concat_fragment("define ngrok tunnel 'webhook'").with({
      'target' => '/etc/ngrok.yml',
      'order'  => '51',
      'content' => /webhook/,
      'content' => /tcp/,
      'content' => /8170/,
    })
  end

end
