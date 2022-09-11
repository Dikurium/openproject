class WeekDay < ApplicationRecord
  include Tableless

  DAY_RANGE = (1..7).to_a

  attribute :day, :integer, default: nil

  class << self
    def find_by!(day:)
      raise ActiveRecord::RecordNotFound, "Couldn't find WeekDay with day #{day}" unless day.in?(DAY_RANGE)

      new(day:)
    end

    def all
      DAY_RANGE.map do |day|
        new(day:)
      end
    end
  end

  def name
    day_names = I18n.t('date.day_names')
    day_names[day % 7]
  end

  def working
    Setting.working_days.empty? || day.in?(Setting.working_days)
  end
end
