class Room < ApplicationRecord
  CREATE_ROOM_PARAMS = [:user_id, :name, :address, :location_id,
    images_attributes: [:id, :image, :_destroy].freeze].freeze

  enum active: {locked: false, opened: true}

  has_many :events, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :images, dependent: :destroy
  has_many :events, dependent: :destroy
  belongs_to :user
  belongs_to :location

  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  delegate :name, to: :location, prefix: :location, allow_nil: true

  validates :user_id, presence: true
  validates :name, presence: true, length: {maximum: Settings.room.name.maximum}
  validates :address, presence: true, length: {maximum: Settings.room.address.maximum}
  validates :location_id, presence: true

  after_update :send_email

  scope :join_location_country, ->{includes location: :country}
  scope :by_name, ->(name){where "rooms.name like ?", "%#{name}%"}
  scope :by_location, ->(id){includes(:location).where(locations: {id: id})}
  scope :by_country, ->(id){join_location_country.where(countries: {id: id})}
  scope :by_created_at, ->(date){where("date(created_at) = ? ", date) if date.present?}
  scope :by_active, ->(status){where(active: status) if status.present?}
  scope :desc_created_at, ->{order created_at: :desc}

  private

  def send_email
    return unless locked?

    @users = User.joins(events: :room).get_user_booking id
    @users.each do |user|
      RoomMailer.room_locking(user, name).deliver_now
    end
  end
end
