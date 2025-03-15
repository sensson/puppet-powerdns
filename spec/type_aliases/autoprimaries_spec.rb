# frozen_string_literal: true

require 'spec_helper'

describe 'Powerdns::Autoprimaries' do
  describe 'valid types' do
    context 'with valid types' do
      [
        {},
        { '1.2.3.4@ns1.example.org' => {} },
        { '2001:db8::1@ns1.example.org' => { 'account' => 'test' } },
      ].each do |value|
        describe value.inspect do
          it { is_expected.to allow_value(value) }
        end
      end
    end
  end

  describe 'invalid types' do
    context 'with garbage inputs' do
      [
        true,
        nil,
        { 'foo' => 'bar' },
        '55555',
        { '@ns1.example.org' => {} },
        { '1.2.3.4@' => {} },
      ].each do |value|
        describe value.inspect do
          it { is_expected.not_to allow_value(value) }
        end
      end
    end
  end
end
