class Status < ActiveRecord::Base
  attr_accessible(
    :body,
    :twitter_status_id,
    :twitter_user_id
  )

  belongs_to(
    :user,
    :foreign_key => :twitter_user_id,
    :primary_key => :twitter_user_id
  )

  validates(
    :body,
    :twitter_status_id,
    :twitter_user_id,
    :presence => true
  )

  def self.parse_twitter_status(twitter_status_params)
    Status.new(
      :body => twitter_status_params["text"],
      :twitter_status_id => twitter_status_params["id_str"],
      :twitter_user_id => twitter_status_params["user"]
    )
  end
end
