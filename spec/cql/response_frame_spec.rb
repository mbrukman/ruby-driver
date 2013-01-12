# encoding: utf-8

require 'spec_helper'


module Cql
  describe ResponseFrame do
    let :frame do
      described_class.new
    end

    context 'when fed no data' do
      it 'has no length' do
        frame.length.should be_nil
      end

      it 'is not complete' do
        frame.should_not be_complete
      end
    end

    context 'when fed a header' do
      before do
        frame << "\x81\x00\x00\x02\x00\x00\x00\x16"
      end

      it 'knows the frame body length' do
        frame.length.should == 22
      end
    end

    context 'when fed a header in pieces' do
      before do
        frame << "\x81\x00"
        frame << "\x00\x02\x00\x00\x00"
        frame << "\x16"
      end

      it 'knows the body length' do
        frame.length.should == 22
      end
    end

    context 'when fed a request frame header' do
      it 'raises an UnsupportedFrameTypeError' do
        expect { frame << "\x01\x00\x00\x00\x00\x00\x00\x00" }.to raise_error(UnsupportedFrameTypeError)
      end
    end

    context 'when fed a header and a partial body' do
      before do
        frame << "\x81\x00"
        frame << "\x00\x06"
        frame << "\x00\x00\x00\x16"
        frame << [rand(255), rand(255), rand(255), rand(255), rand(255), rand(255), rand(255), rand(255)].pack('C')
      end

      it 'knows the body length' do
        frame.length.should == 22
      end

      it 'is not complete' do
        frame.should_not be_complete
      end
    end

    context 'when fed a complete ERROR frame' do
      before do
        frame << "\x81\x00\x00\x00\x00\x00\x00V\x00\x00\x00\n\x00PProvided version 4.0.0 is not supported by this server (supported: 2.0.0, 3.0.0)"
      end

      it 'is complete' do
        frame.should be_complete
      end

      it 'has an error code' do
        frame.body.code.should == 10
      end

      it 'has an error message' do
        frame.body.message.should == 'Provided version 4.0.0 is not supported by this server (supported: 2.0.0, 3.0.0)'
      end
    end

    context 'when fed a complete READY frame' do
      before do
        frame << [0x81, 0, 0, 0x02, 0].pack('C4N')
      end

      it 'is complete' do
        frame.should be_complete
      end
    end

    context 'when fed a complete SUPPORTED frame' do
      before do
        frame << "\x81\x00\x00\x06\x00\x00\x00\x27"
        frame << "\x00\x02\x00\x0bCQL_VERSION\x00\x01\x00\x053.0.0\x00\x0bCOMPRESSION\x00\x00"
      end

      it 'is complete' do
        frame.should be_complete
      end

      it 'has options' do
        frame.body.options.should == {'CQL_VERSION' => ['3.0.0'], 'COMPRESSION' => []}
      end
    end

    context 'when fed a complete RESULT frame' do
      before do
        frame << "\x81\x00\x00\b\x00\x00\x00\f"
        frame << "\x00\x00\x00\x03\x00\x06system"
      end

      it 'is complete' do
        frame.should be_complete
      end

      it 'has a keyspace' do
        frame.body.keyspace.should == 'system'
      end
    end

    context 'when fed an non-existent opcode' do
      it 'raises an UnsupportedOperationError' do
        expect { frame << "\x81\x00\x00\x99\x00\x00\x00\x39" }.to raise_error(UnsupportedOperationError)
      end
    end
  end
end