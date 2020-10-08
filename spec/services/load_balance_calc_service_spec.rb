# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LoadBalanceCalcService do
  let(:service) { LoadBalanceCalcService.new('test', weight1: 30, weight2: 70) }

  before(:each) do
    REDIS.set('test1_count', 55)
    REDIS.set('test2_count', 80)
  end

  describe 'initialize' do
    it 'should have weights as integers' do
      expect(service.weight1).to eql 30
      expect(service.weight2).to eql 70
    end

    it 'should have a cache name' do
      expect(service.cache_name).to eql 'test'
    end

    it 'should set cache names' do
      expect(service.cache_name1).to eql 'test1_count'
      expect(service.cache_name2).to eql 'test2_count'
    end

    it 'should set cache counts' do
      expect(service.cache1_count).to eql 55
      expect(service.cache2_count).to eql 80
    end

    it 'should set cache ratio' do
      ratio = (REDIS.get('test1_count').to_i.fdiv REDIS.get('test2_count').to_i).round(2)
      expect(service.cached_ratio).to eql ratio
    end

    it 'should set weighted ratio' do
      ratio = (30.fdiv 70).round(2)
      expect(service.weight_ratio).to eql ratio
    end
  end

  describe 'instance_methods' do
    describe 'determine_if_a_weight_has_immediate_priority' do
      it 'should set skip_calculation to true' do
        lb = LoadBalanceCalcService.new('test', weight1: 0, weight2: 1).call

        expect(lb.skip_calculation).to be_truthy
      end

      it 'should select weight1 as priority' do
        lb = LoadBalanceCalcService.new('test', weight1: 1, weight2: 0).call

        expect(lb.send_to_weight1).to be_truthy
      end

      it 'should select weight2 as priority' do
        lb = LoadBalanceCalcService.new('test', weight1: 0, weight2: 1)

        expect(lb.send_to_weight1).to be_falsey
      end
    end

    describe 'determine_weight_with_calculation' do
      it 'should set send_to_weight1 to true if weight1 is greater' do
        lb = LoadBalanceCalcService.new('test', weight1: 45, weight2: 20).call

        expect(lb.send_to_weight1).to be_truthy
      end
    end

    describe 'set_cache_name_to_increment' do
      it 'should set the correct cache name' do
        service.call

        expect(service.cache_name_to_increment).to eql 'test2_count'
      end
    end

    describe 'get_cache_counts' do
      it 'should reset the cache counts to 0' do
        REDIS.set('test2_count', 100000)
        service.call

        expect(service.cache1_count).to eql 0
        expect(service.cache2_count).to eql 0
      end
    end
  end
end