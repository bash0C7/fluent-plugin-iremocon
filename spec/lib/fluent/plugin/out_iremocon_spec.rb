require 'spec_helper'

describe do

  describe 'emit' do
    let(:record) {{ 'field1' => 50, 'otherfield' => 99}}
    let(:time) {0}
    let(:posted) {
      any_instance_of(Fluent::IremoconOutput) do |obj|
        mock(obj).send_command(50)
      end

      d = Fluent::Test::OutputTestDriver.new(Fluent::IremoconOutput, 'test.metrics').configure(config)
      d.emit(record, Time.at(time))
      d.run
      }

    context do
      let(:config) {
        %[
    host 127.0.0.1
    port 50000
    command is
    command_value_key field1
    interval 0
        ]
      }

      subject {posted}
      it{should_not be_nil}
    end

  end

end