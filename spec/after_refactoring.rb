# frozen_string_literal: true

require 'date_range_formatter'

describe DateRangeFormatter do
  let(:start_date) { '1996-12-25' }
  let(:end_date) { '2017-12-24' }
  let(:start_time) { '9:30' }
  let(:end_time) { '16:45' }

  describe 'class respond to' do
    subject { described_class }
    it { is_expected.to respond_to :new }
  end

  describe 'instance respond to' do
    subject { described_class.new(start_date, end_date) }
    it { is_expected.to respond_to :to_s }
    it { is_expected.to respond_to :same_day? }
    it { is_expected.to respond_to :same_month? }
    it { is_expected.to respond_to :same_year? }
  end

  describe '#initialize' do
    context 'when initialised with required arguments only' do
      subject { described_class.new(start_date, end_date) }
      it { is_expected.to have_attributes(start_date: Date.parse(start_date)) }
      it { is_expected.to have_attributes(end_date: Date.parse(end_date)) }
      it { is_expected.to have_attributes(start_time: nil) }
      it { is_expected.to have_attributes(end_time: nil) }
    end

    context 'when initialised with required and optional arguments' do
      subject { described_class.new(start_date, end_date, start_time, end_time) }
      it { is_expected.to have_attributes(start_date: Date.parse(start_date)) }
      it { is_expected.to have_attributes(end_date: Date.parse(end_date)) }
      it { is_expected.to have_attributes(start_time: Time.parse(start_time)) }
      it { is_expected.to have_attributes(end_time: Time.parse(end_time)) }
    end
  end

  # rubocop: disable Metrics/LineLength
  describe '#to_s' do
    context 'when range spans multiple years' do
      context 'without start or end times' do
        subject { described_class.new('2009-11-1', '2010-12-8').to_s }
        it { is_expected.to eq('1st November 2009 - 8th December 2010') }
      end

      context 'with start time but no end time' do
        subject { described_class.new('2009-11-1', '2010-12-8', '10:00').to_s }
        it { is_expected.to eq('1st November 2009 at 10:00 - 8th December 2010') }
      end

      context 'without start time but with end time' do
        subject { described_class.new('2009-11-1', '2010-12-8', nil, '11:00').to_s }
        it { is_expected.to eq('1st November 2009 - 8th December 2010 at 11:00') }
      end

      context 'with start and end times' do
        subject { described_class.new('2009-11-1', '2010-12-8', '10:00', '11:00').to_s }
        it { is_expected.to eq('1st November 2009 at 10:00 - 8th December 2010 at 11:00') }
      end
    end

    context 'when range is within the same years' do
      context 'without start or end times' do
        subject { described_class.new('2009-11-1', '2009-12-2').to_s }
        it { is_expected.to eq('1st November - 2nd December 2009') }
      end

      context 'with start time but no end time' do
        subject { described_class.new('2009-11-1', '2009-12-2', '10:00').to_s }
        it { is_expected.to eq('1st November 2009 at 10:00 - 2nd December 2009') }
      end

      context 'without start time but with end time' do
        subject { described_class.new('2009-11-1', '2009-12-2', nil, '11:00').to_s }
        it { is_expected.to eq('1st November 2009 - 2nd December 2009 at 11:00') }
      end

      context 'with start and end times' do
        subject { described_class.new('2009-11-1', '2009-12-2', '10:00', '11:00').to_s }
        it { is_expected.to eq('1st November 2009 at 10:00 - 2nd December 2009 at 11:00') }
      end
    end

    context 'when range is within the same month' do
      context 'without start or end times' do
        subject { described_class.new('2009-11-1', '2009-11-3').to_s }
        it { is_expected.to eq('1st - 3rd November 2009') }
      end

      context 'with start time but no end time' do
        subject { described_class.new('2009-11-1', '2009-11-3', '10:00').to_s }
        it { is_expected.to eq('1st November 2009 at 10:00 - 3rd November 2009') }
      end

      context 'without start time but with end time' do
        subject { described_class.new('2009-11-1', '2009-11-3', nil, '11:00').to_s }
        it { is_expected.to eq('1st November 2009 - 3rd November 2009 at 11:00') }
      end

      context 'with start and end times' do
        subject { described_class.new('2009-11-1', '2009-11-3', '10:00', '11:00').to_s }
        it { is_expected.to eq('1st November 2009 at 10:00 - 3rd November 2009 at 11:00') }
      end
    end

    context 'when range is within the same day' do
      context 'without start or end times' do
        subject { described_class.new('2009-11-1', '2009-11-1').to_s }
        it { is_expected.to eq('1st November 2009') }
      end

      context 'with start time but no end time' do
        subject { described_class.new('2009-11-1', '2009-11-1', '10:00').to_s }
        it { is_expected.to eq('1st November 2009 at 10:00') }
      end

      context 'without start time but with end time' do
        subject { described_class.new('2009-11-1', '2009-11-1', nil, '11:00').to_s }
        it { is_expected.to eq('1st November 2009 until 11:00') }
      end

      context 'with start and end times' do
        subject { described_class.new('2009-11-1', '2009-11-1', '10:00', '11:00').to_s }
        it { is_expected.to eq('1st November 2009 at 10:00 to 11:00') }
      end
    end

    context 'when testing for known issues' do
      it 'correctly detects ranges in the same month' do
        subject = described_class.new('2009-11-1', '2010-11-3').to_s
        expect(subject).to eq('1st November 2009 - 3rd November 2010')
      end

      it 'raises an error for invalid times' do
        subject = ->(s) { s.new('2009-11-1', '2010-11-3', 'A', 'B').to_s }
        expect { subject.call(described_class) }.to raise_error(ArgumentError)
      end
    end
  end
  # rubocop: enable Metrics/LineLength
end
