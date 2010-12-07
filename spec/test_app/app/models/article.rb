class Article < ActiveRecord::Base
  has_many :comments

  scope :published, :conditions => {:published => true}

  before_save :update_published_at
  def update_published_at
    if self.published_changed? and self.published
      self.published_at = Time.now
    end
  end

end
