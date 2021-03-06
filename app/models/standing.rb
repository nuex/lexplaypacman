class Standing < ActiveRecord::Base
	BAD_WORDS = %w(ass cck cnt coc cok coq dck dik dix fag fck fuc fuk fuq kkk kok nig poo tit).freeze

  belongs_to :location
  belongs_to :player
  accepts_nested_attributes_for :player

  validates_presence_of :initials
  validates_exclusion_of :initials, in: BAD_WORDS,
                                    message: "cannot be rude words"
  validates_format_of :initials, with: /\A[a-zA-Z]{3}\z/,
                                 message: 'must be three letters'
  validates_presence_of :score
  validates :image_URL, presence: true
  validates_numericality_of :score, less_than_or_equal_to: 3333360,
                                    greater_than_or_equal_to: 0

  before_save :capitalize_initials

  scope :with_locations, ->{ joins('LEFT OUTER JOIN locations ' +
                                   'ON locations.id=standings.location_id') }

  def rank
    # Add 1 because the index method returns a 0-based ranking.
    Standing.order('score DESC').pluck(:id).index(id) + 1
  end

  # Look up Player by email address, or create a new Player.
  def player_attributes= data
    email = data['email']
    twitter = data['twitter']
    if email.present? || twitter.present?
      self.player = Player.where(email: email).first_or_initialize
      self.player.twitter = twitter if twitter.present?
      self.player.save
    end
  end

  private

  def capitalize_initials
    return unless initials
    self.initials = initials.upcase
  end
end
