# frozen_string_literal: true

class LoadBalanceCalcService
  attr_reader :backup, :cache1_count, :cache2_count,  :cache_name1,
              :cache_name2, :cache_name_to_increment, :cached_ratio,
              :send_to_weight1, :skip_calculation,  :weight1, :weight2,
              :weight_name, :weight_ratio, :primary

  def initialize(weight_name:, weight1: 50, weight2: 50)
    @skip_calculation = false
    @weight1 = weight1.to_i
    @weight2 = weight2.to_i
    @weight_name = weight_name
    set_named_counts
    set_weight_counts
    set_cached_ratio
    set_weight_ratio
  end

  def call
    determine_weight_with_calculation unless skip_calculation
    @primary = send_to_weight1 ? 1 : 2
    @backup  = primary == 1 ? 2 : 1
    set_cache_name_to_increment

    self
  end

  def determine_if_a_weight_has_immediate_priority
    # You can't load balance against 0. If either is zero the other has
    # priority. One can't have zero weight and expect to receive anything.
    if weight1 > 0 && weight2.zero?
      @send_to_weight1 = true
      @skip_calculation = true
    elsif weight1.zero? && weight2 > 0
      @send_to_weight1 = false
      @skip_calculation = true
    end
  end

  def determine_weight_with_calculation
    if weights_are_zero?(cache1_count, cache2_count)
      if weight_ratio <= 1.0
        @send_to_weight1 = false
      else
        @send_to_weight1 = true
      end
    else
      r1 = cache1_count.succ.fdiv cache2_count
      r2 = cache1_count.fdiv cache2_count.succ

      if (r1 - weight_ratio).abs <= (r2 - weight_ratio).abs
        @send_to_weight1 = true
      else
        @send_to_weight1 = false
      end
    end
  end

  def set_cache_name_to_increment
    @cache_name_to_increment = primary == 1 ? cache_name1 : cache_name2
  end

  def set_named_counts
    @cache_name1 = "#{weight_name}1_count"
    @cache_name2 = "#{weight_name}2_count"
  end

  def set_ratio(weight_1, weight_2)
    return 0.0 if weights_are_zero?(weight_1, weight_2)

    (weight_1.fdiv weight_2).round(2)
  end

  def set_weight_counts
    count = REDIS.get(cache_name2)

    if count.blank? || count.to_i > 9999
      REDIS.set(cache_name1, 0)
      REDIS.set(cache_name2, 0)
    end

    @cache1_count = REDIS.get(cache_name1).to_i
    @cache2_count = REDIS.get(cache_name2).to_i
  end

  def set_weight_ratio
    determine_if_a_weight_has_immediate_priority

    @weight_ratio = set_ratio(weight1, weight2)
  end

  def weights_are_zero?(weight_1, weight_2)
    weight_1 + weight_2 == 0 ||
      !!((weight_1.fdiv weight_2).infinite?)
  end

  # -----------------------------------------------------------------------

  # This isn't really needed, but nice to see if there is an exiting ratio
  def set_cached_ratio
    @cached_ratio = set_ratio(cache1_count, cache2_count)
  end
end
