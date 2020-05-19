# frozen_string_literal: true

require 'date'
require 'inflector'

class DateRangeFormatter
  using Inflector
  attr_reader :start_date, :end_date, :start_time, :end_time

  HUMANISE_CONFIG = {
    date_format: '%%s %B %Y',
    time_prefix: 'at',
    time_format: '%H:%M'
  }.freeze

  def initialize(start_date, end_date, start_time = nil, end_time = nil)
    @start_date = parse_date(start_date)
    @end_date = parse_date(end_date)
    @start_time = parse_time(start_time)
    @end_time = parse_time(end_time)
  end

  def to_s
    return humanise_same_day_range if same_day?
    return humanise_same_month_range if same_month?
    return humanise_same_year_range if same_year?
    humanise_date_range
  end

  def same_day?
    start_date == end_date
  end

  def same_month?
    start_date.month == end_date.month && start_date.year == end_date.year
  end

  def same_year?
    start_date.year == end_date.year
  end

  private

  def parse_date(date)
    Date.parse(date)
  end

  def parse_time(time)
    return nil if time.nil?
    Time.parse(time)
  end

  def humanise_date(date, config)
    config = HUMANISE_CONFIG.merge(config)
    return date.day.ordinalize unless config[:date_format]
    date.strftime(config[:date_format]) % date.day.ordinalize
  end

  def humanise_time(time, config)
    config = HUMANISE_CONFIG.merge(config)
    return '' unless time
    "#{config[:time_prefix]} #{time.strftime(config[:time_format])}".strip
  end

  def humanise_date_time(type, config = {})
    config = HUMANISE_CONFIG.merge(config)
    human_date = humanise_date(send("#{type}_date".to_sym), config)
    human_time = humanise_time(send("#{type}_time".to_sym), config)
    "#{human_date} #{human_time}".strip
  end

  def humanise_date_range
    "#{humanise_date_time('start')} - #{humanise_date_time('end')}".strip
  end

  def humanise_same_year_range
    start_time_prefix = if start_time || end_time
                          humanise_date_time('start')
                        else
                          humanise_date(start_date, date_format: '%%s %B')
                        end
    "#{start_time_prefix} - #{humanise_date_time('end')}".strip
  end

  def humanise_same_month_range
    start_time_prefix = if start_time || end_time
                          humanise_date_time('start')
                        else
                          humanise_date(start_date, date_format: nil)
                        end
    "#{start_time_prefix} - #{humanise_date_time('end')}".strip
  end

  def humanise_same_day_range
    end_time_suffix = if start_time
                        humanise_time(end_time, time_prefix: 'to')
                      else
                        humanise_time(end_time, time_prefix: 'until')
                      end
    "#{humanise_date_time('start')} #{end_time_suffix}".strip
  end
end
