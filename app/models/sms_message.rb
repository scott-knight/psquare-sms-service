# frozen_string_literal: true

class SmsMessage < ApplicationRecord
  include Discard::Model
  include PgSearch::Model

  before_validation :sanitize_phone_number

  validates :phone_number, :message, presence: true
  validates :phone_number, length: { minimum: 10, maximum: 10 }
  validate  :prefix_is_safe

  pg_search_scope(
    :search_message,
    against: :message,
    using: {
      tsearch: {
        dictionary:      'english',
        tsvector_column: 'tsv'
      }
    }
  )

  scope :failed_submit, -> { where.not(message_id: nil).where.not(status_code: nil).where('status_code != ?', 200) }
  scope :search_message_id, ->(id) { where('message_id iLIKE ?', "%#{id}%") }
  scope :search_phone, ->(number) { where('phone_number LIKE ?', "%#{number}%") }
  scope :search_status, ->(status) { where('status iLIKE ?', "%#{status}%") }
  scope :search_status_code, ->(status_code) { where('status_code = ?', status_code) }
  scope :search_url_domain, ->(domain) { where('url_domain iLIKE ?', "%#{domain}%") }
  scope :search_url_path, ->(path) { where('url_path iLIKE ?', "%#{path}%") }
  scope :unsubmitted, -> { where(message_id: nil).where(status_code: nil) }


  def submitted?
    !message_id.blank?
  end

  private

  def sanitize_phone_number
    return nil if phone_number.blank?

    # remove whitespace
    phone_number.strip!

    # collect the numbers
    number = phone_number.delete('^0-9')

    # remove 1 from the front of the number if it exists
    number.slice!(0) if number.length > 10 && number[0] == '1'

    self.phone_number = number
  end

  def prefix_is_safe
    return nil if phone_number.blank?

    unsafe_list = %w[911 411]
    prefix = phone_number[0..2]
    errors.add(:phone_number, "can't start with #{prefix}") if unsafe_list.include?(prefix)
  end
end
