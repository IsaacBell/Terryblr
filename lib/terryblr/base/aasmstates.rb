module Terryblr
  class Base < ActiveRecord::Base
    module AasmStates

      def self.included(recipient)
        recipient.class_eval do

          require 'aasm'
          include ::AASM
          aasm_column :state
          aasm_initial_state :pending
          aasm_state :pending
          aasm_state :drafted
          aasm_state :queued
          aasm_state :published, :enter => :do_publish

          aasm_event :publish do
            transitions :from => [:pending, :drafted, :queued], :to => :published
          end

          aasm_event :draft do
            transitions :from => [:pending, :published, :queued], :to => :drafted
          end

          aasm_event :queue do
            transitions :from => [:pending, :published, :drafted], :to => :queued
          end

          #
          # Scopes
          #
          aasm_states.map(&:name).each do |state|
            scope state, :conditions => {:state => state.to_s}
          end

          scope :by_state, lambda { |state|
            { :conditions => {:state => state} }
          }

          scope :live, lambda {
            # Needs to be sep variable or AR will cache the first time and it'll never change
            now = Time.now.in_time_zone
            { :conditions => ["#{table_name}.state = 'published' and #{table_name}.published_at < ?", now] }
          }

          def states_for_select
            [
              ["Publish now", :publish_now],
              ["Save as a draft", :drafted],
              # ["Add to queue", :queued],
              ["Publish on date", :published_at]
            ]
          end

          def state=(value)
            case value.to_s.to_sym
            when :publish_now
              self.write_attribute(:state, "published")
              self.published_at = Time.now.in_time_zone
            when :published_at
              self.write_attribute(:state, "published")
            else
puts "self => #{self.inspect}"
              self.write_attribute(:state, value) if self.class.aasm_states.map(&:name).include?(value.to_s.to_sym)
            end
          end

          def live?
            self.published? and self.published_at? and self.published_at < Time.now.in_time_zone
          end

          def publish_on_date?
            self.published? and self.published_at?
          end

          private

          def do_publish
            # Override this in local models
          end
        end
      end
    end
  end
end